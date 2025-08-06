import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '252754882670-9tqn146j6ip3rds704r7sabdjn6m7h7t.apps.googleusercontent.com'
        : null,
    scopes: ['email', 'profile'],
  );

  // Get the appropriate backend URL based on platform
  String get _backendUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      // For mobile, use 10.0.2.2 for Android emulator or actual IP for device
      return Platform.isAndroid
          ? 'http://10.0.2.2:3000'
          : 'http://localhost:3000';
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Validate Indian phone number format
  bool isValidIndianPhoneNumber(String phoneNumber) {
    // Remove any spaces, dashes, or other characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Indian phone number patterns:
    // +91 9876543210 (with country code)
    // 9876543210 (without country code, 10 digits)
    // 09876543210 (with leading 0, 11 digits)

    if (cleanNumber.startsWith('91') && cleanNumber.length == 12) {
      // +91 followed by 10 digits
      return true;
    } else if (cleanNumber.length == 10) {
      // 10 digits without country code
      return true;
    } else if (cleanNumber.startsWith('0') && cleanNumber.length == 11) {
      // 0 followed by 10 digits
      return true;
    }

    return false;
  }

  // Format phone number to international format
  String formatPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // For backend API, we need to send the phone number without country code
    // The backend validation expects 10-15 characters
    if (cleanNumber.startsWith('91') && cleanNumber.length == 12) {
      return cleanNumber.substring(2); // Remove 91 prefix
    } else if (cleanNumber.length == 10) {
      return cleanNumber; // Keep as is
    } else if (cleanNumber.startsWith('0') && cleanNumber.length == 11) {
      return cleanNumber.substring(1); // Remove leading 0
    }

    return cleanNumber; // Return cleaned number
  }

  // Sign in with Google using unified approach
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      return await _getCredentialFromGoogleAccount(googleUser);
    } catch (e) {
      print('AuthService: Google sign-in error: $e');
      rethrow;
    }
  }

  // Helper method to get Firebase credential from Google account
  Future<UserCredential> _getCredentialFromGoogleAccount(
    GoogleSignInAccount googleUser,
  ) async {
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  // Email authentication with MongoDB backend
  Future<Map<String, dynamic>> signInWithEmail(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/users/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        // Store user data locally (you might want to use SharedPreferences or secure storage)
        return {
          'success': true,
          'user': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Email login error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Phone number authentication with MongoDB backend
  Future<Map<String, dynamic>> signInWithPhone(
      String phone, String password) async {
    try {
      final formattedPhone = formatPhoneNumber(phone.trim());
      final response = await http.post(
        Uri.parse('$_backendUrl/api/users/login-phone'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone': formattedPhone,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'user': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Phone login error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Test backend connectivity
  Future<bool> testBackendConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/health'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('AuthService: Backend health check status: ${response.statusCode}');
      print('AuthService: Backend health check response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('AuthService: Backend connection test failed: $e');
      return false;
    }
  }

  // Email registration with MongoDB backend
  Future<Map<String, dynamic>> signUpWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final formattedPhone = formatPhoneNumber(phone.trim());
      final requestBody = {
        'name': name.trim(),
        'email': email.trim(),
        'phone': formattedPhone,
        'password': password,
      };

      print(
          'AuthService: Sending registration request with data: $requestBody');

      final response = await http.post(
        Uri.parse('$_backendUrl/api/users/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('AuthService: Response status: ${response.statusCode}');
      print('AuthService: Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'user': data['data'],
          'message': data['message'],
        };
      } else {
        // Handle validation errors specifically
        if (data['errors'] != null) {
          final errors = data['errors'] as List;
          final errorMessages =
              errors.map((e) => e['msg'] ?? 'Validation error').join(', ');
          return {
            'success': false,
            'message': errorMessages,
          };
        }

        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('Email registration error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Sign out from both Firebase and clear local data
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      // Clear any local user data here
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Phone authentication with platform-specific implementation
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    // Validate and format the phone number
    if (!isValidIndianPhoneNumber(phoneNumber)) {
      verificationFailed(
        FirebaseAuthException(
          code: 'invalid-phone-number',
          message: 'Please enter a valid Indian phone number (10 digits)',
        ),
      );
      return;
    }

    String formattedNumber = formatPhoneNumber(phoneNumber);

    if (kIsWeb) {
      // Web implementation using signInWithPhoneNumber
      await _verifyPhoneNumberWeb(
        phoneNumber: formattedNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } else {
      // Mobile implementation using verifyPhoneNumber
      await _verifyPhoneNumberMobile(
        phoneNumber: formattedNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    }
  }

  // Web-specific phone authentication implementation
  Future<void> _verifyPhoneNumberWeb({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      // For web, we use signInWithPhoneNumber which handles reCAPTCHA automatically
      final ConfirmationResult confirmationResult =
          await _auth.signInWithPhoneNumber(phoneNumber);

      // Store the confirmation result for later use
      _confirmationResult = confirmationResult;

      // Simulate codeSent callback for web
      codeSent('web-verification-id', null);
    } catch (e) {
      print('Web phone verification error: $e');

      // Check if it's a billing error
      if (e.toString().contains('billing-not-enabled')) {
        verificationFailed(
          FirebaseAuthException(
            code: 'billing-not-enabled',
            message:
                'Phone authentication requires billing to be enabled. Please enable billing in Firebase Console or test on mobile device.',
          ),
        );
      } else if (e is FirebaseAuthException) {
        verificationFailed(e);
      } else {
        verificationFailed(
          FirebaseAuthException(code: 'unknown-error', message: e.toString()),
        );
      }
    }
  }

  // Mobile-specific phone authentication implementation
  Future<void> _verifyPhoneNumberMobile({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      // For mobile, use the traditional verifyPhoneNumber method
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('Mobile phone verification error: $e');
      if (e is FirebaseAuthException) {
        verificationFailed(e);
      } else {
        verificationFailed(
          FirebaseAuthException(code: 'unknown-error', message: e.toString()),
        );
      }
    }
  }

  // Store confirmation result for web phone auth
  ConfirmationResult? _confirmationResult;

  // Verify OTP with platform-specific implementation
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    if (kIsWeb && _confirmationResult != null) {
      // Web implementation
      try {
        return await _confirmationResult!.confirm(smsCode);
      } finally {
        _confirmationResult = null; // Clear after use
      }
    } else {
      // Mobile implementation
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    }
  }

  // Check if phone number is a test number (for development)
  bool isTestPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    // Common test numbers
    return cleanNumber.contains('123456') ||
        cleanNumber.contains('000000') ||
        cleanNumber.contains('111111');
  }

  // Get test OTP for development
  String getTestOTP(String phoneNumber) {
    // For development, return a fixed OTP
    // In production, this should never be used
    return '123456';
  }
}
