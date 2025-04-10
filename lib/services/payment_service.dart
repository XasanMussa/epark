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
  Future<void> makePayment(number, amount, description) async {
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
          "accountNo": number.text.trim(),
        },
        "transactionInfo": {
          "referenceId": DateTime.now()
              .millisecondsSinceEpoch
              .toString(), // Unique reference ID
          "invoiceId": "154", // Replace with your invoice ID
          "amount": double.tryParse(amount.text.trim()) ??
              0.0, // Ensure amount is a valid number
          "currency": "USD",
          "description": description.text.trim(),
        }
      }
    };

    // Debugging: print the request payload
    print("Request Payload: ${json.encode(requestPayLoad)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestPayLoad),
      );

      // Debugging: print the response status and body
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final responseMsg = responseData['responseMsg'];
        final transactionId = responseData['params']['transactionId'];
        return responseMsg;
      } else {
        throw Exception('Payment failed');
      }
    } catch (error) {
      print("Error: $error"); // Debugging: print the error
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
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Create booking document
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

      // Schedule notifications for the booking
      await _notificationService.scheduleBookingNotifications(
          bookingDoc.id, checkOutDate);
    } catch (e) {
      throw Exception('Error storing payment: $e');
    }
  }

  // Store parking payment
  Future<void> storeParkingPayment(
      {required String packageName,
      required DateTime startDate,
      required DateTime endDate,
      required int totalPrice,
      required String phoneNumber,
      required String rfidNumber,
      required String paymentMethod,
      required String status}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Create booking document
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

      // Schedule notifications for the booking
      await _notificationService.scheduleBookingNotifications(
          bookingDoc.id, endDate);
    } catch (e) {
      throw Exception('Error storing payment: $e');
    }
  }
}
