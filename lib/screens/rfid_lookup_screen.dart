import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:epark/services/rfid_service.dart';
import 'package:epark/screens/rfid_details_screen.dart';

class RFIDLookupScreen extends StatefulWidget {
  const RFIDLookupScreen({super.key});

  @override
  State<RFIDLookupScreen> createState() => _RFIDLookupScreenState();
}

class _RFIDLookupScreenState extends State<RFIDLookupScreen> {
  final _rfidController = TextEditingController();
  final _rfidService = RFIDService();
  bool _isLoading = false;

  @override
  void dispose() {
    _rfidController.dispose();
    super.dispose();
  }

  Future<void> _lookupRFID() async {
    if (_rfidController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Remove spaces and convert to uppercase for database lookup
      // final formattedRFID =
      //     _rfidController.text.replaceAll(' ', '').toUpperCase();
      print("rfidNumber is equal to : $_rfidController.text");
      final details =
          await _rfidService.getBookingDetails(_rfidController.text);

      if (!mounted) return;

      if (details != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RFIDDetailsScreen(bookingDetails: details),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No booking found for this RFID number')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
        title: const Text('RFID Lookup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _lookupRFID,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Lookup',
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
    );
  }
}
