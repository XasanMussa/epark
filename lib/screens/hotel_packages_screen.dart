import 'package:flutter/material.dart';
import 'package:epark/models/hotel_package.dart';
import 'package:epark/screens/hotel_payment_screen.dart';
import 'package:intl/intl.dart';

class HotelPackagesScreen extends StatefulWidget {
  const HotelPackagesScreen({super.key});

  @override
  State<HotelPackagesScreen> createState() => _HotelPackagesScreenState();
}

class _HotelPackagesScreenState extends State<HotelPackagesScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  String? _selectedPackage;
  int _totalPrice = 0;
  int _numberOfGuests = 1;
  int _extraParkingSpaces = 0;

  final Map<String, HotelPackage> _hotelPackages = {
    'Standard Room': HotelPackage(
      name: 'Standard Room',
      description: 'Comfortable room with basic amenities',
      pricePerNight: 100,
      features: [
        'Free WiFi',
        'Air Conditioning',
        'Daily Housekeeping',
        '24/7 Reception',
      ],
      includesParking: true,
      parkingPrice: 0,
    ),
    'Deluxe Room': HotelPackage(
      name: 'Deluxe Room',
      description: 'Spacious room with premium amenities',
      pricePerNight: 150,
      features: [
        'Free WiFi',
        'Air Conditioning',
        'Daily Housekeeping',
        '24/7 Reception',
        'Mini Bar',
        'Room Service',
      ],
      includesParking: true,
      parkingPrice: 0,
    ),
    'Suite': HotelPackage(
      name: 'Suite',
      description: 'Luxury suite with all amenities',
      pricePerNight: 250,
      features: [
        'Free WiFi',
        'Air Conditioning',
        'Daily Housekeeping',
        '24/7 Reception',
        'Mini Bar',
        'Room Service',
        'Living Room',
        'Premium Bathroom',
      ],
      includesParking: true,
      parkingPrice: 0,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Packages'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDateSelection(),
          const SizedBox(height: 24),
          _buildGuestSelection(),
          const SizedBox(height: 24),
          _buildPackageCard(
            context,
            'Standard Room',
            'Comfortable room with basic amenities',
            '\$${_hotelPackages['Standard Room']!.pricePerNight}/night',
            _hotelPackages['Standard Room']!.features,
            'Standard Room',
          ),
          const SizedBox(height: 16),
          _buildPackageCard(
            context,
            'Deluxe Room',
            'Spacious room with premium amenities',
            '\$${_hotelPackages['Deluxe Room']!.pricePerNight}/night',
            _hotelPackages['Deluxe Room']!.features,
            'Deluxe Room',
          ),
          const SizedBox(height: 16),
          _buildPackageCard(
            context,
            'Suite',
            'Luxury suite with all amenities',
            '\$${_hotelPackages['Suite']!.pricePerNight}/night',
            _hotelPackages['Suite']!.features,
            'Suite',
          ),
          if (_selectedPackage != null &&
              _checkInDate != null &&
              _checkOutDate != null)
            _buildPaymentSummary(),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
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
              'Select Dates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateButton(
                    'Check-in',
                    _checkInDate,
                    () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateButton(
                    'Check-out',
                    _checkOutDate,
                    () => _selectDate(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSelection() {
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
              'Number of Guests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_numberOfGuests > 1) {
                      setState(() {
                        _numberOfGuests--;
                      });
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$_numberOfGuests',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _numberOfGuests++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Extra Parking Spaces',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_extraParkingSpaces > 0) {
                      setState(() {
                        _extraParkingSpaces--;
                      });
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  '$_extraParkingSpaces',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _extraParkingSpaces++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('MMM dd, yyyy').format(date)
                  : 'Select Date',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    final package = _hotelPackages[_selectedPackage]!;
    final roomPrice = nights * package.pricePerNight;
    final extraParkingPrice = _extraParkingSpaces * 10 * nights;
    _totalPrice = roomPrice + extraParkingPrice;

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
              'Booking Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Room Type', _selectedPackage!),
            _buildSummaryRow(
                'Check-in', DateFormat('MMM dd, yyyy').format(_checkInDate!)),
            _buildSummaryRow(
                'Check-out', DateFormat('MMM dd, yyyy').format(_checkOutDate!)),
            _buildSummaryRow('Duration', '$nights nights'),
            _buildSummaryRow('Guests', '$_numberOfGuests'),
            if (_extraParkingSpaces > 0)
              _buildSummaryRow('Extra Parking Spaces', '$_extraParkingSpaces'),
            _buildSummaryRow('Room Price', '\$$roomPrice'),
            if (_extraParkingSpaces > 0)
              _buildSummaryRow('Extra Parking', '\$$extraParkingPrice'),
            const Divider(height: 32),
            _buildSummaryRow(
              'Total Price',
              '\$$_totalPrice',
              isTotal: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HotelPaymentScreen(
                        packageName: _selectedPackage!,
                        checkInDate: _checkInDate!,
                        checkOutDate: _checkOutDate!,
                        numberOfGuests: _numberOfGuests,
                        extraParkingSpaces: _extraParkingSpaces,
                        totalPrice: _totalPrice,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(
                    fontSize: 18,
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

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isTotal ? Colors.green : Colors.grey.shade700,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isTotal ? Colors.green : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isCheckIn ? DateTime.now() : (_checkInDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = _checkInDate;
          }
        } else {
          if (_checkInDate != null) {
            if (picked.isBefore(_checkInDate!)) {
              _checkOutDate = _checkInDate;
            } else {
              _checkOutDate = picked;
            }
          }
        }
      });
    }
  }

  Widget _buildPackageCard(
    BuildContext context,
    String title,
    String subtitle,
    String price,
    List<String> features,
    String packageName,
  ) {
    return Card(
      elevation: _selectedPackage == packageName ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedPackage == packageName
              ? Colors.green
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPackage = packageName;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Features:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(feature),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
