import 'package:flutter/material.dart';
import 'package:epark/screens/confirmation_screen.dart';
import 'package:epark/services/payment_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class PaymentScreen extends StatefulWidget {
  final String packageName;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.packageName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _rfidController = TextEditingController();
  final _paymentService = PaymentService();
  String _selectedPaymentMethod = 'EVC-Plus'; // Default payment method
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _rfidController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Remove spaces and convert to uppercase for database storage
        final formattedRFID =
            _rfidController.text.replaceAll(' ', '').toUpperCase();
        print("Processing payment with RFID: $formattedRFID");

        final message = await _paymentService.makePayment(
            _phoneNumberController.text.trim(),
            widget.totalPrice,
            "purchasing parking service");
        print("Payment response message: $message");

        if (message == "RCS_USER_REJECTED") {
          print("User rejected payment");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment was rejected by user")),
          );
          return;
        }

        if (message == "RCS_SUCCESS") {
          print("Payment successful, storing booking details...");
          await _paymentService.storeParkingPayment(
              packageName: widget.packageName,
              startDate: widget.startDate,
              endDate: widget.endDate,
              totalPrice: widget.totalPrice,
              phoneNumber: _phoneNumberController.text.trim(),
              rfidNumber: formattedRFID,
              paymentMethod: _selectedPaymentMethod,
              status: "active");
          print("Booking stored successfully");

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmationScreen(endDate: widget.endDate),
            ),
          );
        }
      } catch (e) {
        print("Error in payment process: $e");
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
        title: const Text('Payment Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOrderSummary(),
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
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Your Phone Number',
                  border: const OutlineInputBorder(),
                  prefixText: '+252 ',
                  helperText:
                      'Enter your phone number for payment confirmation',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length != 9) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
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
                  helperText:
                      'Enter RFID in format: XX XX XX XX (e.g., 45 92 16 9B)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter RFID card number';
                  }
                  // Remove spaces and check format
                  final cleanValue = value.replaceAll(' ', '');
                  if (cleanValue.length != 8) {
                    return 'RFID must be 8 characters (e.g., 4592169B)';
                  }
                  // Check if it's valid hexadecimal
                  if (!RegExp(r'^[0-9A-Fa-f]{8}$').hasMatch(cleanValue)) {
                    return 'Invalid RFID format. Use hex characters (0-9, A-F)';
                  }
                  return null;
                },
                inputFormatters: [
                  // Format as user types: XX XX XX XX
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) return newValue;
                    final text = newValue.text.replaceAll(' ', '');
                    final buffer = StringBuffer();
                    for (int i = 0; i < text.length; i++) {
                      if (i > 0 && i % 2 == 0) buffer.write(' ');
                      buffer.write(text[i]);
                    }
                    return TextEditingValue(
                      text: buffer.toString().toUpperCase(),
                      selection: TextSelection.collapsed(offset: buffer.length),
                    );
                  }),
                ],
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
                        'Complete Payment',
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

  Widget _buildOrderSummary() {
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
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Package', widget.packageName),
            _buildSummaryRow('Start Date',
                DateFormat('MMM dd, yyyy').format(widget.startDate)),
            _buildSummaryRow(
                'End Date', DateFormat('MMM dd, yyyy').format(widget.endDate)),
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
