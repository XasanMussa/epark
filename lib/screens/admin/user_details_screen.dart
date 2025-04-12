import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epark/models/user_model.dart';
import 'package:intl/intl.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;

  const UserDetailsScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  List<Map<String, dynamic>> _bookings = [];
  bool _isUserActive = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadBookings();
  }

  Future<void> _loadUserDetails() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        setState(() {
          _isUserActive = userDoc.data()?['isActive'] ?? true;
        });
      }
    } catch (e) {
      print('Error loading user details: $e');
    }
  }

  Future<void> _loadBookings() async {
    try {
      final bookingsSnapshot = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _bookings = bookingsSnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print('Error loading bookings: $e');
    }
  }

  Future<void> _deactivateUser() async {
    setState(() => _isLoading = true);

    try {
      // Update user status
      await _firestore.collection('users').doc(widget.userId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Deactivate all user's bookings
      final batch = _firestore.batch();
      final bookingsSnapshot = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('bookings')
          .where('status', isEqualTo: 'active')
          .get();

      for (var doc in bookingsSnapshot.docs) {
        batch.update(doc.reference, {
          'status': 'inactive',
          'lastActiveDate': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      setState(() {
        _isUserActive = false;
        _bookings = _bookings.map((booking) {
          if (booking['status'] == 'active') {
            return {
              ...booking,
              'status': 'inactive',
              'lastActiveDate': DateTime.now(),
            };
          }
          return booking;
        }).toList();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User and bookings deactivated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deactivating user: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoCard(),
                  const SizedBox(height: 24),
                  _buildBookingsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(_isUserActive ? 'Active' : 'Inactive'),
                  backgroundColor: _isUserActive ? Colors.green : Colors.red,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Email', widget.userEmail),
            _buildInfoRow('Phone', widget.userPhone),
            const SizedBox(height: 16),
            if (_isUserActive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _deactivateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Deactivate User',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    if (_bookings.isEmpty) {
      return const Center(
        child: Text(
          'No bookings found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bookings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._bookings.map((booking) => _buildBookingCard(booking)),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final isActive = booking['status'] == 'active';
    final startDate = (booking['startDate'] ?? booking['checkInDate']).toDate();
    final endDate = (booking['endDate'] ?? booking['checkOutDate']).toDate();
    final type = booking['type'] ?? 'unknown';
    final packageName = booking['packageName'] ?? 'Unknown Package';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  packageName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(isActive ? 'Active' : 'Inactive'),
                  backgroundColor: isActive ? Colors.green : Colors.red,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Type', type.toUpperCase()),
            _buildInfoRow(
              'Start Date',
              DateFormat('MMM dd, yyyy').format(startDate),
            ),
            _buildInfoRow(
              'End Date',
              DateFormat('MMM dd, yyyy').format(endDate),
            ),
            if (type == 'hotel') ...[
              _buildInfoRow('Guests', booking['numberOfGuests'].toString()),
              if (booking['extraParkingSpaces'] > 0)
                _buildInfoRow(
                  'Extra Parking',
                  booking['extraParkingSpaces'].toString(),
                ),
            ],
            _buildInfoRow(
              'Total Price',
              '\$${booking['totalPrice']}',
            ),
            _buildInfoRow(
              'Payment Method',
              booking['paymentMethod'] ?? 'Unknown',
            ),
          ],
        ),
      ),
    );
  }
}
