import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/post_lost_pet_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDfsiyZxCkAEJ2VLP5autGtoKtWdqRlLKU",
        authDomain: "pettrack-3497f.firebaseapp.com",
        projectId: "pettrack-3497f",
        storageBucket: "pettrack-3497f.firebasestorage.app",
        messagingSenderId: "252754882670",
        appId: "1:252754882670:web:c256bdcb962c8c395df67f",
        measurementId: "G-YPHFTHZ2WQ",
      ),
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading PetTrack...',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle errors
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Restart the app
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppWrapper(),
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Check if user is signed in
        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in
          return const PetTrackingHomeScreen();
        } else {
          // User is not signed in
          return const WelcomeScreen();
        }
      },
    );
  }
}
