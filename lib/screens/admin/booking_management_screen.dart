import 'package:flutter/material.dart';
import 'package:epark/services/admin_service.dart';
import 'package:intl/intl.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  final _adminService = AdminService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await _adminService.getAllBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_searchQuery.isEmpty) return _bookings;
    return _bookings.where((booking) {
      final query = _searchQuery.toLowerCase();
      final rfidNumber = booking['rfidNumber']?.toString().toLowerCase() ?? '';
      final packageName =
          booking['packageName']?.toString().toLowerCase() ?? '';
      return rfidNumber.contains(query) || packageName.contains(query);
    }).toList();
  }

  Future<void> _updateBookingStatus(
      String userId, String bookingId, String status) async {
    try {
      await _adminService.updateBookingStatus(userId, bookingId, status);
      await _loadBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking status updated to $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Bookings',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadBookings,
                    child: ListView.builder(
                      itemCount: _filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = _filteredBookings[index];
                        final isHotel = booking['type'] == 'hotel';
                        final startDate =
                            booking[isHotel ? 'checkInDate' : 'startDate']
                                ?.toDate();
                        final endDate =
                            booking[isHotel ? 'checkOutDate' : 'endDate']
                                ?.toDate();

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ExpansionTile(
                            leading: Icon(
                              isHotel ? Icons.hotel : Icons.local_parking,
                              color: booking['status'] == 'active'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(
                                booking['packageName'] ?? 'Unknown Package'),
                            subtitle: Text(
                              'RFID: ${booking['rfidNumber']}\n'
                              'Status: ${booking['status']}',
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                        'Type',
                                        isHotel
                                            ? 'Hotel + Parking'
                                            : 'Parking Only'),
                                    if (startDate != null)
                                      _buildInfoRow(
                                        isHotel ? 'Check-in' : 'Start Date',
                                        DateFormat('MMM dd, yyyy')
                                            .format(startDate),
                                      ),
                                    if (endDate != null)
                                      _buildInfoRow(
                                        isHotel ? 'Check-out' : 'End Date',
                                        DateFormat('MMM dd, yyyy')
                                            .format(endDate),
                                      ),
                                    _buildInfoRow('Total Price',
                                        '\$${booking['totalPrice']}'),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _updateBookingStatus(
                                            booking['userId'],
                                            booking['bookingId'],
                                            'active',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: const Text('Activate'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _updateBookingStatus(
                                            booking['userId'],
                                            booking['bookingId'],
                                            'inactive',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Deactivate'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
