import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyDdG6pvphC7Qqt6t-AbUoJ_NFbopmvhpyE',
          appId: '1:314273359365:android:5b92cabc3f9cd37296de6c',
          messagingSenderId: '314273359365',
          projectId: 'hotel-parking-system',
        ),
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;

  // Collections
  static CollectionReference get users => firestore.collection('users');
  static CollectionReference get rfidCards => firestore.collection('rfidCards');
  static CollectionReference get parkingPackages =>
      firestore.collection('parkingPackages');
  static CollectionReference get hotelPackages =>
      firestore.collection('hotelPackages');
  static CollectionReference get bookings => firestore.collection('bookings');
  static CollectionReference get payments => firestore.collection('payments');
}
