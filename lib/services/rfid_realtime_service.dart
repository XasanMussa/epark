import 'package:firebase_database/firebase_database.dart';

class RFIDRealtimeService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Store RFID information
  Future<void> storeRFIDInfo({
    required String rfidNumber,
    required bool isActive,
    required DateTime endDate,
  }) async {
    try {
      // Format RFID number (remove spaces and convert to uppercase)
      final formattedRFID = rfidNumber.replaceAll(' ', '').toUpperCase();

      // Store in Realtime Database
      await _database.child('rfids').child(formattedRFID).set({
        'status': isActive ? 1 : 0,
        'endDate': endDate.millisecondsSinceEpoch,
      });

      print('RFID info stored successfully for: $formattedRFID');
    } catch (e) {
      print('Error storing RFID info: $e');
      throw Exception('Failed to store RFID information');
    }
  }

  // Update RFID status
  Future<void> updateRFIDStatus(String rfidNumber, bool isActive) async {
    try {
      final formattedRFID = rfidNumber.replaceAll(' ', '').toUpperCase();
      await _database.child('rfids').child(formattedRFID).update({
        'status': isActive ? 1 : 0,
      });
      print('RFID status updated for: $formattedRFID');
    } catch (e) {
      print('Error updating RFID status: $e');
      throw Exception('Failed to update RFID status');
    }
  }

  // Get RFID information
  Future<Map<String, dynamic>?> getRFIDInfo(String rfidNumber) async {
    try {
      final formattedRFID = rfidNumber.replaceAll(' ', '').toUpperCase();
      final snapshot =
          await _database.child('rfids').child(formattedRFID).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return {
          'status': data['status'],
          'endDate': DateTime.fromMillisecondsSinceEpoch(data['endDate']),
        };
      }
      return null;
    } catch (e) {
      print('Error getting RFID info: $e');
      throw Exception('Failed to get RFID information');
    }
  }
}
