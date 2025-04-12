import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as models;

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String adminUid = "BSParFBp30NvfhZiFuH2ZjRT9JW2";

  // Admin login
  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user is the specific admin
      return userCredential.user?.uid == adminUid;
    } catch (e) {
      print('Admin login error: $e');
      return false;
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      return usersSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Get all bookings
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      List<Map<String, dynamic>> allBookings = [];

      for (var userDoc in usersSnapshot.docs) {
        final bookingsSnapshot =
            await userDoc.reference.collection('bookings').get();
        allBookings.addAll(bookingsSnapshot.docs.map((doc) => {
              ...doc.data(),
              'userId': userDoc.id,
              'bookingId': doc.id,
            }));
      }

      return allBookings;
    } catch (e) {
      print('Error getting bookings: $e');
      return [];
    }
  }

  // Update user status
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user status: $e');
      throw Exception('Failed to update user status');
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(
      String userId, String bookingId, String status) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating booking status: $e');
      throw Exception('Failed to update booking status');
    }
  }

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      final activeUsers = usersSnapshot.docs
          .where((doc) => doc.data()['isActive'] == true)
          .length;

      int totalBookings = 0;
      int activeBookings = 0;
      double totalRevenue = 0;

      for (var userDoc in usersSnapshot.docs) {
        final bookingsSnapshot =
            await userDoc.reference.collection('bookings').get();
        totalBookings += bookingsSnapshot.docs.length;
        activeBookings += bookingsSnapshot.docs
            .where((doc) => doc.data()['status'] == 'active')
            .length;

        for (var booking in bookingsSnapshot.docs) {
          totalRevenue += booking.data()['totalPrice'] ?? 0;
        }
      }

      return {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'totalBookings': totalBookings,
        'activeBookings': activeBookings,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'totalUsers': 0,
        'activeUsers': 0,
        'totalBookings': 0,
        'activeBookings': 0,
        'totalRevenue': 0,
      };
    }
  }

  Future<List<models.User>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return models.User.fromMap({
          'id': doc.id,
          'name': data['name'] ?? '',
          'email': data['email'] ?? '',
          'isActive': data['isActive'] ?? false,
        });
      }).toList();
    } catch (e) {
      print('Error getting users: $e');
      throw Exception('Failed to get users');
    }
  }

  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
      });
    } catch (e) {
      print('Error toggling user status: $e');
      throw Exception('Failed to toggle user status');
    }
  }

  // Toggle user activation status
  Future<void> toggleUserActivation(String userId, bool isActive) async {
    try {
      // Update user status
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // If deactivating user, deactivate all their bookings
      if (!isActive) {
        final bookingsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('bookings')
            .get();

        for (var booking in bookingsSnapshot.docs) {
          await booking.reference.update({
            'status': 'inactive',
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('Error toggling user activation: $e');
      throw Exception('Failed to update user status');
    }
  }

  // Toggle individual booking activation status
  Future<void> toggleBookingActivation(
      String userId, String bookingId, bool isActive) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': isActive ? 'active' : 'inactive',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error toggling booking activation: $e');
      throw Exception('Failed to update booking status');
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      // Get total users
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;

      // Get active users
      final activeUsers = usersSnapshot.docs
          .where((doc) => doc.data()['isActive'] == true)
          .length;

      // Get total bookings
      int totalBookings = 0;
      int activeBookings = 0;
      int hotelBookings = 0;
      int parkingBookings = 0;

      for (var userDoc in usersSnapshot.docs) {
        final bookingsSnapshot =
            await userDoc.reference.collection('bookings').get();
        totalBookings += bookingsSnapshot.docs.length;

        for (var booking in bookingsSnapshot.docs) {
          final data = booking.data();
          if (data['status'] == 'active') {
            activeBookings++;
          }
          if (data['type'] == 'hotel') {
            hotelBookings++;
          } else if (data['type'] == 'parking') {
            parkingBookings++;
          }
        }
      }

      // Get total revenue
      double totalRevenue = 0;
      for (var userDoc in usersSnapshot.docs) {
        final bookingsSnapshot =
            await userDoc.reference.collection('bookings').get();
        for (var booking in bookingsSnapshot.docs) {
          final data = booking.data();
          totalRevenue += (data['totalPrice'] ?? 0).toDouble();
        }
      }

      return {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'totalBookings': totalBookings,
        'activeBookings': activeBookings,
        'hotelBookings': hotelBookings,
        'parkingBookings': parkingBookings,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      throw Exception('Failed to get statistics');
    }
  }
}
