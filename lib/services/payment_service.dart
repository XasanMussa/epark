import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:epark/services/notification_service.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _notificationService = NotificationService();
  final String merchantUid = "M0910291";
  final String apiUserId = "1000416";
  final String apiKey = "API-675418888AHX";
  Future<String> makePayment(
      String number, double amount, String description) async {
    final url = Uri.parse('https://api.waafipay.net/asm');

    final requestPayLoad = {
      "schemaVersion": "1.0",
      "requestId": DateTime.now().millisecondsSinceEpoch.toString(),
      "timestamp": DateTime.now().toIso8601String(),
      "channelName": "WEB",
      "serviceName": "API_PURCHASE",
      "serviceParams": {
        "merchantUid": merchantUid,
        "apiUserId": apiUserId,
        "apiKey": apiKey,
        "paymentMethod": "MWALLET_ACCOUNT",
        "payerInfo": {
          "accountNo": number,
        },
        "transactionInfo": {
          "referenceId": DateTime.now().millisecondsSinceEpoch.toString(),
          "invoiceId": "154",
          "amount": amount,
          "currency": "USD",
          "description": description,
        }
      }
    };

    print("Request Payload: ${json.encode(requestPayLoad)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestPayLoad),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final responseMsg = responseData['responseMsg'];
        return responseMsg;
      } else {
        throw Exception('Payment failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print("Error: $error");
      throw Exception('Payment failed: $error');
    }
  }

  // Store hotel booking payment
  Future<void> storeHotelPayment({
    required String packageName,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    required int extraParkingSpaces,
    required int totalPrice,
    required String guestName,
    required String email,
    required String phoneNumber,
    required String rfidNumber,
    required String paymentMethod,
  }) async {
    try {
      print("Starting to store hotel payment...");
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print("Error: User not authenticated");
        throw Exception('User not authenticated');
      }
      print("User ID: $userId");

      // Create booking document
      print("Creating booking document...");
      final bookingDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookings')
          .add({
        'type': 'hotel',
        'packageName': packageName,
        'checkInDate': checkInDate,
        'checkOutDate': checkOutDate,
        'numberOfGuests': numberOfGuests,
        'extraParkingSpaces': extraParkingSpaces,
        'totalPrice': totalPrice,
        'guestName': guestName,
        'email': email,
        'phoneNumber': phoneNumber,
        'rfidNumber': rfidNumber,
        'paymentMethod': paymentMethod,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Booking document created with ID: ${bookingDoc.id}");

      // Schedule notifications for the booking
      print("Scheduling notifications for booking ID: ${bookingDoc.id}");
      print("Check-out date for notifications: $checkOutDate");
      try {
        await _notificationService.scheduleBookingNotifications(
            bookingDoc.id, checkOutDate);
        print("Notifications scheduled successfully");
      } catch (e) {
        print("Error scheduling notifications: $e");
        print("Error details: ${e.toString()}");
        // Don't throw the error here, as we don't want to fail the payment process
      }
    } catch (e) {
      print("Error storing payment: $e");
      print("Error details: ${e.toString()}");
      throw Exception('Error storing payment: $e');
    }
  }

  // Store parking payment
  Future<void> storeParkingPayment({
    required String packageName,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
    required String phoneNumber,
    required String rfidNumber,
    required String paymentMethod,
    required String status,
  }) async {
    try {
      print("Starting to store parking payment...");
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print("Error: User not authenticated");
        throw Exception('User not authenticated');
      }
      print("User ID: $userId");

      // Create booking document
      print("Creating booking document...");
      final bookingDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookings')
          .add({
        'type': 'parking',
        'packageName': packageName,
        'startDate': startDate,
        'endDate': endDate,
        'totalPrice': totalPrice,
        'phoneNumber': phoneNumber,
        'rfidNumber': rfidNumber,
        'paymentMethod': paymentMethod,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Booking document created with ID: ${bookingDoc.id}");

      // Schedule notifications for the booking
      print("Scheduling notifications for booking ID: ${bookingDoc.id}");
      print("End date for notifications: $endDate");
      try {
        await _notificationService.scheduleBookingNotifications(
            bookingDoc.id, endDate);
        print("Notifications scheduled successfully");
      } catch (e) {
        print("Error scheduling notifications: $e");
        print("Error details: ${e.toString()}");
        // Don't throw the error here, as we don't want to fail the payment process
      }
    } catch (e) {
      print("Error storing payment: $e");
      print("Error details: ${e.toString()}");
      throw Exception('Error storing payment: $e');
    }
  }
}
