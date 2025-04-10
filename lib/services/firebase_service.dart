import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';

class FirebaseService {
  // User Operations
  static Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await FirebaseConfig.auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await FirebaseConfig.auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await FirebaseConfig.auth.signOut();
  }

  // RFID Card Operations
  static Future<void> createRFIDCard(Map<String, dynamic> cardData) async {
    await FirebaseConfig.rfidCards.add(cardData);
  }

  static Future<QuerySnapshot> getRFIDCardsByUser(String userId) async {
    return await FirebaseConfig.rfidCards
        .where('ownerId', isEqualTo: userId)
        .get();
  }

  // Booking Operations
  static Future<void> createBooking(Map<String, dynamic> bookingData) async {
    await FirebaseConfig.bookings.add(bookingData);
  }

  static Future<QuerySnapshot> getBookingsByUser(String userId) async {
    return await FirebaseConfig.bookings
        .where('userId', isEqualTo: userId)
        .get();
  }

  // Package Operations
  static Future<QuerySnapshot> getParkingPackages() async {
    return await FirebaseConfig.parkingPackages.get();
  }

  static Future<QuerySnapshot> getHotelPackages() async {
    return await FirebaseConfig.hotelPackages.get();
  }

  // Payment Operations
  static Future<void> createPayment(Map<String, dynamic> paymentData) async {
    await FirebaseConfig.payments.add(paymentData);
  }

  static Future<QuerySnapshot> getPaymentsByUser(String userId) async {
    return await FirebaseConfig.payments
        .where('userId', isEqualTo: userId)
        .get();
  }

  // User Profile Operations
  static Future<void> createUserProfile(
      String userId, Map<String, dynamic> userData) async {
    await FirebaseConfig.users.doc(userId).set(userData);
  }

  static Future<DocumentSnapshot> getUserProfile(String userId) async {
    return await FirebaseConfig.users.doc(userId).get();
  }

  static Future<void> updateUserProfile(
      String userId, Map<String, dynamic> userData) async {
    await FirebaseConfig.users.doc(userId).update(userData);
  }
}
