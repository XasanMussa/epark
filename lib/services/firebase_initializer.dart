import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';

class FirebaseInitializer {
  static Future<void> initializeCollections() async {
    // Initialize parking packages
    await _initializeParkingPackages();

    // Initialize hotel packages
    await _initializeHotelPackages();
  }

  static Future<void> _initializeParkingPackages() async {
    final packages = [
      {
        'name': 'Basic Parking',
        'description': 'Perfect for short stays',
        'dailyPrice': 10,
        'features': [
          '24/7 Access',
          'Security Surveillance',
          'Basic Support',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Premium Parking',
        'description': 'Best value for frequent visitors',
        'dailyPrice': 25,
        'features': [
          '24/7 Access',
          'Security Surveillance',
          'Priority Support',
          'Car Wash Service',
          'Battery Jump Start',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'VIP Parking',
        'description': 'Luxury experience',
        'dailyPrice': 50,
        'features': [
          '24/7 Access',
          'Security Surveillance',
          '24/7 Support',
          'Car Wash Service',
          'Battery Jump Start',
          'Valet Service',
          'Dedicated Parking Space',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var package in packages) {
      // Check if package already exists
      final querySnapshot = await FirebaseConfig.parkingPackages
          .where('name', isEqualTo: package['name'])
          .get();

      if (querySnapshot.docs.isEmpty) {
        await FirebaseConfig.parkingPackages.add(package);
      }
    }
  }

  static Future<void> _initializeHotelPackages() async {
    final packages = [
      {
        'name': 'Standard Room',
        'description': 'Comfortable room with basic amenities',
        'pricePerNight': 100,
        'features': [
          'Free WiFi',
          'Air Conditioning',
          'Daily Housekeeping',
          '24/7 Reception',
        ],
        'includesParking': true,
        'parkingPrice': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Deluxe Room',
        'description': 'Spacious room with premium amenities',
        'pricePerNight': 150,
        'features': [
          'Free WiFi',
          'Air Conditioning',
          'Daily Housekeeping',
          '24/7 Reception',
          'Mini Bar',
          'Room Service',
        ],
        'includesParking': true,
        'parkingPrice': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Suite',
        'description': 'Luxury suite with all amenities',
        'pricePerNight': 250,
        'features': [
          'Free WiFi',
          'Air Conditioning',
          'Daily Housekeeping',
          '24/7 Reception',
          'Mini Bar',
          'Room Service',
          'Living Room',
          'Premium Bathroom',
        ],
        'includesParking': true,
        'parkingPrice': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var package in packages) {
      // Check if package already exists
      final querySnapshot = await FirebaseConfig.hotelPackages
          .where('name', isEqualTo: package['name'])
          .get();

      if (querySnapshot.docs.isEmpty) {
        await FirebaseConfig.hotelPackages.add(package);
      }
    }
  }
}
