import 'package:epark/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

class HotelConfirmationScreen extends StatelessWidget {
  const HotelConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your room and parking have been reserved',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.hotel),
                        title: Text('Room Status'),
                        subtitle: Text('Confirmed'),
                      ),
                      ListTile(
                        leading: Icon(Icons.local_parking),
                        title: Text('Parking Status'),
                        subtitle: Text('Included with room'),
                      ),
                      ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text('Check-in Time'),
                        subtitle: Text('From 2:00 PM'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to home or show parking map
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
