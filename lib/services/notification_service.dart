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
    // Initialize timezone database
    tz.initializeTimeZones();

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission();

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _notifications.initialize(initSettings);

    // Initialize background work manager
    Workmanager().initialize(callbackDispatcher);
  }

  Future<void> scheduleBookingNotifications(
      String bookingId, DateTime endDate) async {
    // Schedule notifications for 3 days, 2 days, and 1 day before end date
    final threeDaysBefore = endDate.subtract(const Duration(days: 3));
    final twoDaysBefore = endDate.subtract(const Duration(days: 2));
    final oneDayBefore = endDate.subtract(const Duration(days: 1));

    // Schedule notifications
    await _scheduleNotification(
      bookingId,
      'Your parking booking expires in 3 days',
      'Please renew your booking to continue using the parking facility',
      threeDaysBefore,
    );

    await _scheduleNotification(
      bookingId,
      'Your parking booking expires in 2 days',
      'Please renew your booking to continue using the parking facility',
      twoDaysBefore,
    );

    await _scheduleNotification(
      bookingId,
      'Your parking booking expires tomorrow',
      'This is your last day of parking access',
      oneDayBefore,
    );

    // Schedule status update for the last day
    await Workmanager().registerOneOffTask(
      'update_booking_status_$bookingId',
      'updateBookingStatus',
      inputData: {
        'bookingId': bookingId,
        'endDate': endDate.toIso8601String(),
      },
      initialDelay: endDate.difference(DateTime.now()),
    );
  }

  Future<void> _scheduleNotification(
    String bookingId,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      'booking_expiry',
      'Booking Expiry Notifications',
      channelDescription: 'Notifications for booking expiry',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.zonedSchedule(
      bookingId.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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
