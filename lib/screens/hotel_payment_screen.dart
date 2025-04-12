import 'package:flutter/material.dart';
import 'package:epark/screens/hotel_confirmation_screen.dart';
import 'package:epark/services/payment_service.dart';
import 'package:intl/intl.dart';

class HotelPaymentScreen extends StatefulWidget {
  final String packageName;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final int extraParkingSpaces;
  final int totalPrice;

  const HotelPaymentScreen({
    super.key,
    required this.packageName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.extraParkingSpaces,
    required this.totalPrice,
  });

  @override
  State<HotelPaymentScreen> createState() => _HotelPaymentScreenState();
}

class _HotelPaymentScreenState extends State<HotelPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _rfidController = TextEditingController();
  final _guestNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _paymentService = PaymentService();
  String _selectedPaymentMethod = 'EVC-Plus';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _rfidController.dispose();
    _guestNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Remove spaces and convert to uppercase for database storage
        final formattedRFID =
            _rfidController.text.replaceAll(' ', '').toUpperCase();
        print("processing the payment");
        final message = await _paymentService.makePayment(
            _phoneNumberController.text.trim(),
            widget.totalPrice.toDouble(),
            "purchasing hotel service");
        print("message: $message");

        if (message == "RCS_USER_REJECTED") {
          print("user rejected to pay");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment was rejected by user")),
          );
          return;
        }

        if (message == "RCS_SUCCESS") {
          await _paymentService.storeHotelPayment(
            packageName: widget.packageName,
            checkInDate: widget.checkInDate,
            checkOutDate: widget.checkOutDate,
            numberOfGuests: widget.numberOfGuests,
            extraParkingSpaces: widget.extraParkingSpaces,
            totalPrice: widget.totalPrice,
            guestName: _guestNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            rfidNumber: formattedRFID,
            paymentMethod: _selectedPaymentMethod,
          );

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HotelConfirmationScreen(),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBookingSummary(),
              const SizedBox(height: 24),
              const Text(
                'Guest Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guestNameController,
                decoration: const InputDecoration(
                  labelText: 'Guest Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter guest name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: const OutlineInputBorder(),
                  prefixText: '+252 ',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length != 9) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentMethodCard(
                'EVC-Plus',
                'Send money to: 252 61 1234567',
                Icons.phone_android,
                'EVC-Plus',
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodCard(
                'Zaad',
                'Send money to: 252 63 1234567',
                Icons.account_balance_wallet,
                'Zaad',
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodCard(
                'E-Dahab',
                'Send money to: 252 65 1234567',
                Icons.credit_card,
                'E-Dahab',
              ),
              const SizedBox(height: 24),
              const Text(
                'RFID Card Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rfidController,
                decoration: const InputDecoration(
                  labelText: 'RFID Card Number',
                  border: OutlineInputBorder(),
                  helperText: 'Enter the RFID card number provided at check-in',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter RFID card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Complete Booking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    final nights = widget.checkOutDate.difference(widget.checkInDate).inDays;

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
            _buildSummaryRow('Room Type', widget.packageName),
            _buildSummaryRow('Check-in',
                DateFormat('MMM dd, yyyy').format(widget.checkInDate)),
            _buildSummaryRow('Check-out',
                DateFormat('MMM dd, yyyy').format(widget.checkOutDate)),
            _buildSummaryRow('Duration', '$nights nights'),
            _buildSummaryRow('Guests', '${widget.numberOfGuests}'),
            if (widget.extraParkingSpaces > 0)
              _buildSummaryRow(
                  'Extra Parking Spaces', '${widget.extraParkingSpaces}'),
            const Divider(height: 32),
            _buildSummaryRow(
              'Total Amount',
              '\$${widget.totalPrice}',
              isTotal: true,
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

  Widget _buildPaymentMethodCard(
    String title,
    String description,
    IconData icon,
    String paymentMethod,
  ) {
    return Card(
      elevation: _selectedPaymentMethod == paymentMethod ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedPaymentMethod == paymentMethod
              ? Colors.green
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = paymentMethod;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: _selectedPaymentMethod == paymentMethod
                    ? Colors.green
                    : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _selectedPaymentMethod == paymentMethod
                            ? Colors.green
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
