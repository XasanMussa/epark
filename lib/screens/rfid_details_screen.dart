import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RFIDDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bookingDetails;

  const RFIDDetailsScreen({
    super.key,
    required this.bookingDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isHotel = bookingDetails['type'] == 'hotel';

    return Scaffold(
      appBar: AppBar(
        title: const Text('RFID Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildBookingTypeCard(),
            const SizedBox(height: 24),
            if (isHotel) _buildHotelDetailsCard(),
            if (!isHotel) _buildParkingDetailsCard(),
            const SizedBox(height: 24),
            _buildPaymentCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              bookingDetails['status'] == 'active'
                  ? Icons.check_circle
                  : Icons.error,
              color: bookingDetails['status'] == 'active'
                  ? Colors.green
                  : Colors.red,
              size: 48,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    bookingDetails['status'].toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: bookingDetails['status'] == 'active'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTypeCard() {
    final isHotel = bookingDetails['type'] == 'hotel';
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Type', isHotel ? 'Hotel + Parking' : 'Parking Only'),
            _buildInfoRow('Package', bookingDetails['packageName']),
            _buildInfoRow('RFID Number', bookingDetails['rfidNumber']),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guest Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Guest Name', bookingDetails['guestName']),
            _buildInfoRow('Email', bookingDetails['email']),
            _buildInfoRow('Phone', bookingDetails['phoneNumber']),
            _buildInfoRow(
              'Check-in',
              DateFormat('MMM dd, yyyy')
                  .format(bookingDetails['checkInDate'].toDate()),
            ),
            _buildInfoRow(
              'Check-out',
              DateFormat('MMM dd, yyyy')
                  .format(bookingDetails['checkOutDate'].toDate()),
            ),
            _buildInfoRow(
                'Guests', bookingDetails['numberOfGuests'].toString()),
            if (bookingDetails['extraParkingSpaces'] > 0)
              _buildInfoRow(
                'Extra Parking',
                bookingDetails['extraParkingSpaces'].toString(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parking Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Phone', bookingDetails['phoneNumber']),
            _buildInfoRow(
              'Start Date',
              DateFormat('MMM dd, yyyy')
                  .format(bookingDetails['startDate'].toDate()),
            ),
            _buildInfoRow(
              'End Date',
              DateFormat('MMM dd, yyyy')
                  .format(bookingDetails['endDate'].toDate()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Total Amount',
              '\$${bookingDetails['totalPrice']}',
              isAmount: true,
            ),
            _buildInfoRow('Payment Method', bookingDetails['paymentMethod']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isAmount ? Colors.green : Colors.black,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
