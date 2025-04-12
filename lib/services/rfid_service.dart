import 'package:cloud_firestore/cloud_firestore.dart';

class RFIDService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getBookingDetails(String rfidNumber) async {
    try {
      // Format the RFID number (remove spaces and convert to uppercase)
      final formattedRFID = rfidNumber.replaceAll(' ', '').toUpperCase();
      print('Searching for RFID: $formattedRFID');

      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      // For each user, check their bookings subcollection
      for (var userDoc in usersSnapshot.docs) {
        // Get all booking documents in the user's bookings subcollection
        final bookingsSnapshot =
            await userDoc.reference.collection('bookings').get();
        print('Found ${bookingsSnapshot.docs.length} bookings for user');

        // Check each booking document for matching RFID
        for (var bookingDoc in bookingsSnapshot.docs) {
          final bookingData = bookingDoc.data();
          final bookingRFID = bookingData['rfidNumber']
              ?.toString()
              .replaceAll(' ', '')
              .toUpperCase();
          print('Comparing RFID: $bookingRFID with $formattedRFID');

          if (bookingRFID == formattedRFID) {
            print('Found booking for RFID: $formattedRFID');
            return bookingData;
          }
        }
      }

      print('No booking found for RFID: $formattedRFID');
      return null;
    } catch (e) {
      print('Error in getBookingDetails: $e');
      throw Exception('Error retrieving booking details: $e');
    }
  }
}
