import 'package:cloud_firestore/cloud_firestore.dart';

class RFIDService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getBookingDetails(String rfidNumber) async {
    try {
      print('Searching for RFID: $rfidNumber');

      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      // For each user, check their bookings subcollection
      for (var userDoc in usersSnapshot.docs) {
        // Get all booking documents in the user's bookings subcollection
        final bookingsSnapshot =
            await userDoc.reference.collection('bookings').get();
        print('the bookingsSnapshotData has : $bookingsSnapshot');

        // Check each booking document for matching RFID
        for (var bookingDoc in bookingsSnapshot.docs) {
          final bookingData = bookingDoc.data();
          print('the bookingData is: $bookingData');
          if (bookingData['rfidNumber'] == rfidNumber) {
            print('Found booking for RFID: $rfidNumber');
            return bookingData;
          }
        }
      }

      print('No booking found for RFID: $rfidNumber');
      return null;
    } catch (e) {
      print('Error in getBookingDetails: $e');
      throw Exception('Error retrieving booking details: $e');
    }
  }
}
