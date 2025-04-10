import 'package:flutter/material.dart';
import 'package:epark/screens/payment_screen.dart';
import 'package:intl/intl.dart';

class ParkingPackagesScreen extends StatefulWidget {
  const ParkingPackagesScreen({super.key});

  @override
  State<ParkingPackagesScreen> createState() => _ParkingPackagesScreenState();
}

class _ParkingPackagesScreenState extends State<ParkingPackagesScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedPackage;
  int _totalPrice = 0;

  final Map<String, int> _packagePrices = {
    'Basic Parking': 10,
    'Premium Parking': 25,
    'VIP Parking': 50,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Packages'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDateSelection(),
          const SizedBox(height: 24),
          _buildPackageCard(
            context,
            'Basic Parking',
            'Perfect for short stays',
            '\$${_packagePrices['Basic Parking']}/day',
            [
              '24/7 Access',
              'Security Surveillance',
              'Basic Support',
            ],
            'Basic Parking',
          ),
          const SizedBox(height: 16),
          _buildPackageCard(
            context,
            'Premium Parking',
            'Best value for frequent visitors',
            '\$${_packagePrices['Premium Parking']}/day',
            [
              '24/7 Access',
              'Security Surveillance',
              'Priority Support',
              'Car Wash Service',
              'Battery Jump Start',
            ],
            'Premium Parking',
          ),
          const SizedBox(height: 16),
          _buildPackageCard(
            context,
            'VIP Parking',
            'Luxury experience',
            '\$${_packagePrices['VIP Parking']}/day',
            [
              '24/7 Access',
              'Security Surveillance',
              '24/7 Support',
              'Car Wash Service',
              'Battery Jump Start',
              'Valet Service',
              'Dedicated Parking Space',
            ],
            'VIP Parking',
          ),
          if (_selectedPackage != null &&
              _startDate != null &&
              _endDate != null)
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
                    'Start Date',
                    _startDate,
                    () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateButton(
                    'End Date',
                    _endDate,
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
    final days = _endDate!.difference(_startDate!).inDays + 1;
    final dailyPrice = _packagePrices[_selectedPackage]!;
    _totalPrice = days * dailyPrice;

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
              'Payment Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Package', _selectedPackage!),
            _buildSummaryRow(
                'Start Date', DateFormat('MMM dd, yyyy').format(_startDate!)),
            _buildSummaryRow(
                'End Date', DateFormat('MMM dd, yyyy').format(_endDate!)),
            _buildSummaryRow('Duration', '$days days'),
            _buildSummaryRow('Daily Rate', '\$$dailyPrice'),
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
                      builder: (context) => PaymentScreen(
                        packageName: _selectedPackage!,
                        startDate: _startDate!,
                        endDate: _endDate!,
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

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          if (_startDate != null) {
            if (picked.isBefore(_startDate!)) {
              _endDate = _startDate;
            } else {
              _endDate = picked;
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
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
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
