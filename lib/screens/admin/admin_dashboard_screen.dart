import 'package:flutter/material.dart';
import 'package:epark/services/admin_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminService = AdminService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _users = [];
  Map<String, List<Map<String, dynamic>>> _userBookings = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _stats = await _adminService.getStatistics();
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      _users = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'email': data['email'] ?? 'No email',
          'name': data['name'] ?? 'No name',
          'isActive': data['isActive'] ?? true,
          'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
        };
      }).toList();

      for (var user in _users) {
        final bookingsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user['id'])
            .collection('bookings')
            .get();

        _userBookings[user['id']] = bookingsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'type': data['type'] ?? 'Unknown',
            'status': data['status'] ?? 'active',
            'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
            'totalPrice': data['totalPrice'] ?? 0,
            'rfidNumber': data['rfidNumber'] ?? '',
            'paymentMethod': data['paymentMethod'] ?? '',
            'phoneNumber': data['phoneNumber'] ?? '',
            'guestName': data['guestName'] ?? '',
            'email': data['email'] ?? '',
            'numberOfGuests': data['numberOfGuests'] ?? 0,
            'extraParkingSpaces': data['extraParkingSpaces'] ?? 0,
            'startDate': data['startDate']?.toDate(),
            'endDate': data['endDate']?.toDate(),
            'checkInDate': data['checkInDate']?.toDate(),
            'checkOutDate': data['checkOutDate']?.toDate(),
          };
        }).toList();
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
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
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatisticsCard(),
                  const SizedBox(height: 24),
                  _buildUsersList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              Icons.people,
              'Total Users',
              _stats['totalUsers'].toString(),
              Colors.blue,
            ),
            _buildStatCard(
              Icons.person,
              'Active Users',
              _stats['activeUsers'].toString(),
              Colors.green,
            ),
            _buildStatCard(
              Icons.book,
              'Total Bookings',
              _stats['totalBookings'].toString(),
              Colors.orange,
            ),
            _buildStatCard(
              Icons.check_circle,
              'Active Bookings',
              _stats['activeBookings'].toString(),
              Colors.purple,
            ),
            _buildStatCard(
              Icons.hotel,
              'Hotel Bookings',
              _stats['hotelBookings'].toString(),
              Colors.indigo,
            ),
            _buildStatCard(
              Icons.local_parking,
              'Parking Bookings',
              _stats['parkingBookings'].toString(),
              Colors.teal,
            ),
            _buildStatCard(
              Icons.attach_money,
              'Total Revenue',
              '\$${_stats['totalRevenue'].toStringAsFixed(2)}',
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Users',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._users.map((user) => _buildUserCard(user)),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final bookings = _userBookings[user['id']] ?? [];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            user['name'][0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user['email'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: user['isActive']
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user['isActive'] ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: user['isActive'] ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: user['isActive'],
          onChanged: (value) async {
            try {
              await _adminService.toggleUserActivation(user['id'], value);
              setState(() {
                user['isActive'] = value;
              });
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating user: $e')),
                );
              }
            }
          },
        ),
        children: [
          if (bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No bookings found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...bookings
                .map((booking) => _buildBookingTile(user['id'], booking)),
        ],
      ),
    );
  }

  Widget _buildBookingTile(String userId, Map<String, dynamic> booking) {
    final isHotel = booking['type'] == 'hotel';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isHotel ? Colors.blue : Colors.green).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isHotel ? Icons.hotel : Icons.local_parking,
            color: isHotel ? Colors.blue : Colors.green,
          ),
        ),
        title: Text(
          '${booking['type'].toString().toUpperCase()} Booking',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Created: ${DateFormat('MMM dd, yyyy').format(booking['createdAt'] as DateTime)}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: booking['status'] == 'active'
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Switch(
            value: booking['status'] == 'active',
            onChanged: (value) async {
              try {
                await _adminService.toggleBookingActivation(
                  userId,
                  booking['id'],
                  value,
                );
                setState(() {
                  booking['status'] = value ? 'active' : 'inactive';
                });
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating booking: $e')),
                  );
                }
              }
            },
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookingDetailRow('Amount', '\$${booking['totalPrice']}'),
                _buildBookingDetailRow(
                    'RFID Number', booking['rfidNumber'] ?? 'Not provided'),
                _buildBookingDetailRow('Payment Method',
                    booking['paymentMethod'] ?? 'Not provided'),
                if (isHotel) ...[
                  _buildBookingDetailRow(
                      'Guest Name', booking['guestName'] ?? 'Not provided'),
                  _buildBookingDetailRow(
                      'Email', booking['email'] ?? 'Not provided'),
                  _buildBookingDetailRow(
                      'Phone', booking['phoneNumber'] ?? 'Not provided'),
                  _buildBookingDetailRow('Number of Guests',
                      booking['numberOfGuests']?.toString() ?? '0'),
                  _buildBookingDetailRow('Extra Parking Spaces',
                      booking['extraParkingSpaces']?.toString() ?? '0'),
                  _buildBookingDetailRow(
                      'Check-in',
                      booking['checkInDate'] != null
                          ? DateFormat('MMM dd, yyyy')
                              .format(booking['checkInDate'])
                          : 'Not set'),
                  _buildBookingDetailRow(
                      'Check-out',
                      booking['checkOutDate'] != null
                          ? DateFormat('MMM dd, yyyy')
                              .format(booking['checkOutDate'])
                          : 'Not set'),
                ] else ...[
                  _buildBookingDetailRow(
                      'Phone', booking['phoneNumber'] ?? 'Not provided'),
                  _buildBookingDetailRow(
                      'Start Date',
                      booking['startDate'] != null
                          ? DateFormat('MMM dd, yyyy')
                              .format(booking['startDate'])
                          : 'Not set'),
                  _buildBookingDetailRow(
                      'End Date',
                      booking['endDate'] != null
                          ? DateFormat('MMM dd, yyyy')
                              .format(booking['endDate'])
                          : 'Not set'),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: booking['status'] == 'active'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        booking['status'] == 'active'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: booking['status'] == 'active'
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        booking['status'] == 'active'
                            ? 'Booking is Active'
                            : 'Booking is Inactive',
                        style: TextStyle(
                          color: booking['status'] == 'active'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
