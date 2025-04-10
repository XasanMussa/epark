import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;

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
