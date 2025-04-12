import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    print('Initializing notification service...');
    // Initialize timezone database
    tz.initializeTimeZones();
    print('Timezone database initialized');

    // Request notification permissions
    final permission = await FirebaseMessaging.instance.requestPermission();
    print('Notification permission status: ${permission.authorizationStatus}');

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    try {
      await _notifications.initialize(initSettings);
      print('Local notifications initialized successfully');

      // Create notification channel for Android
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            'booking_expiry',
            'Booking Expiry Notifications',
            description: 'Notifications for booking expiry',
            importance: Importance.high,
            enableVibration: true,
            enableLights: true,
            playSound: true,
          ));
      print('Android notification channel created');
    } catch (e) {
      print('Error initializing notifications: $e');
    }

    // Initialize background work manager
    Workmanager().initialize(callbackDispatcher);
    print('Workmanager initialized');
  }

  Future<void> scheduleBookingNotifications(
      String bookingId, DateTime endDate) async {
    print('Scheduling notifications for booking: $bookingId');
    print('End date: $endDate');

    try {
      // Schedule notifications for 5, 10, and 15 minutes from now for testing
      final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
      final tenMinutesFromNow = DateTime.now().add(const Duration(minutes: 10));
      final fifteenMinutesFromNow =
          DateTime.now().add(const Duration(minutes: 15));

      print('Current time: ${DateTime.now()}');
      print('Scheduling first notification for: $fiveMinutesFromNow');
      await _scheduleNotification(
        bookingId,
        'Booking Reminder 1',
        'Your booking will expire in 15 minutes',
        fiveMinutesFromNow,
      );

      print('Scheduling second notification for: $tenMinutesFromNow');
      await _scheduleNotification(
        bookingId,
        'Booking Reminder 2',
        'Your booking will expire in 10 minutes',
        tenMinutesFromNow,
      );

      print('Scheduling third notification for: $fifteenMinutesFromNow');
      await _scheduleNotification(
        bookingId,
        'Booking Reminder 3',
        'Your booking will expire in 5 minutes',
        fifteenMinutesFromNow,
      );

      // Schedule background task
      print('Scheduling background task for: $fifteenMinutesFromNow');
      await Workmanager().registerOneOffTask(
        'update_booking_status_$bookingId',
        'updateBookingStatus',
        inputData: {
          'bookingId': bookingId,
          'endDate': fifteenMinutesFromNow.toIso8601String(),
        },
        initialDelay: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
      );
      print('All notifications and background task scheduled successfully');
    } catch (e) {
      print('Error in scheduleBookingNotifications: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> _scheduleNotification(
    String bookingId,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    print('Creating notification: $title');
    print('Scheduled for: $scheduledDate');

    try {
      // Convert to local timezone
      final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
      print('Converted to timezone: $scheduledTZ');

      final androidDetails = AndroidNotificationDetails(
        'booking_expiry',
        'Booking Expiry Notifications',
        channelDescription: 'Notifications for booking expiry',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        showWhen: true,
        when: scheduledDate.millisecondsSinceEpoch,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Check if notification is already scheduled
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();
      final isAlreadyScheduled = pendingNotifications.any(
        (notification) => notification.id == bookingId.hashCode,
      );

      if (isAlreadyScheduled) {
        print('Notification already scheduled, canceling previous one');
        await _notifications.cancel(bookingId.hashCode);
      }

      await _notifications.zonedSchedule(
        bookingId.hashCode,
        title,
        body,
        scheduledTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: bookingId,
      );
      print('Notification scheduled successfully for: $scheduledTZ');
    } catch (e) {
      print('Error scheduling notification: $e');
      print('Error details: ${e.toString()}');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> updateBookingStatus(String bookingId) async {
    try {
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      // Find and update the booking
      for (var userDoc in usersSnapshot.docs) {
        final bookingDoc =
            await userDoc.reference.collection('bookings').doc(bookingId).get();

        if (bookingDoc.exists) {
          await bookingDoc.reference.update({
            'status': 'inactive',
            'lastActiveDate': DateTime.now(),
          });
          break;
        }
      }
    } catch (e) {
      print('Error updating booking status: $e');
    }
  }
}

// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == 'updateBookingStatus') {
      final notificationService = NotificationService();
      await notificationService.updateBookingStatus(inputData!['bookingId']);
    }
    return true;
  });
}
