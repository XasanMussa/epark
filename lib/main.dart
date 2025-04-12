import 'package:epark/screens/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'config/firebase_config.dart';
import 'services/firebase_initializer.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/admin/admin_sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  await FirebaseInitializer.initializeCollections();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  Future<void> _checkAuthState() async {
    final isLoggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ePark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Green color for parking theme
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isLoggedIn
              ? const WelcomeScreen()
              : const SignUpScreen(),
      routes: {
        '/admin-sign-in': (context) => const AdminSignInScreen(),
      },
    );
  }
}
