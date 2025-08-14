import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'session_service.dart';
import 'phone_utils.dart';

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
      // For mobile devices, use your computer's IP address
      return 'http://${getPhysicalDeviceIP()}:3000';
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Validate Indian phone number format

  bool isValidIndianPhoneNumber(String phoneNumber) {
    return PhoneUtils.isValidIndianPhoneNumber(phoneNumber);
  }

  // Format phone number to international format
  String formatPhoneNumber(String phoneNumber) {
    return PhoneUtils.formatPhoneNumberForBackend(phoneNumber);
  }

  // Sign in with Google using unified approach
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('AuthService: Starting Google sign-in process...');
      print('AuthService: Current backend URL: $_backendUrl');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('AuthService: Google sign-in was cancelled by user');
        return null;
      }

      print('AuthService: Google user obtained: ${googleUser.email}');
      final userCredential = await _getCredentialFromGoogleAccount(googleUser);
      print('AuthService: Firebase authentication successful');

      // After successful Firebase authentication, authenticate with backend
      final backendSuccess =
          await _authenticateWithBackend(googleUser, userCredential.user!);

      if (!backendSuccess) {
        print(
            'AuthService: WARNING - Backend authentication failed, but Firebase auth succeeded');
        // Try to recover the session later
        print('AuthService: Will attempt session recovery on next operation');
      } else {
        print('AuthService: Backend authentication successful');
      }

      return userCredential;
    } catch (e) {
      print('AuthService: Google sign-in error: $e');
      print('AuthService: Error type: ${e.runtimeType}');
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

  // Helper method to authenticate with backend after Google sign-in
  Future<bool> _authenticateWithBackend(
      GoogleSignInAccount googleUser, User firebaseUser) async {
    try {
      print('AuthService: Attempting backend authentication for Google user');
      print('AuthService: Backend URL: $_backendUrl');
      print('AuthService: Firebase UID: ${firebaseUser.uid}');
      print('AuthService: Google email: ${googleUser.email}');

      final requestBody = {
        'firebaseUid': firebaseUser.uid,
        'email': googleUser.email,
        'name': googleUser.displayName,
        'profileImage': googleUser.photoUrl,
      };

      print('AuthService: Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/users/google-auth'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      print('AuthService: Backend response status: ${response.statusCode}');
      print('AuthService: Backend response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        print('AuthService: Backend authentication successful');
        // Store backend session locally
        try {
          final userData = (data['data'] as Map).cast<String, dynamic>();
          await SessionService().saveBackendUser(userData);
          print(
              'AuthService: Backend session saved locally with user ID: ${userData['_id']}');
          return true;
        } catch (e) {
          print('AuthService: Error saving backend session: $e');
          return false;
        }
      } else {
        print('AuthService: Backend Google auth failed: ${data['message']}');
        return false;
      }
    } catch (e) {
      print('AuthService: Error authenticating with backend: $e');
      print('AuthService: Error type: ${e.runtimeType}');
      // Don't throw here as Firebase auth was successful
      return false;
    }
  }

  // Email authentication with MongoDB backend
  Future<Map<String, dynamic>> signInWithEmail(
      String email, String password) async {
    try {
      print('AuthService: Attempting email login for: ${email.trim()}');
      print('AuthService: Backend URL: $_backendUrl');

      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/users/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('AuthService: Email login response status: ${response.statusCode}');
      print('AuthService: Email login response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        // Store backend session locally for later (ownerId, etc.)
        try {
          await SessionService()
              .saveBackendUser((data['data'] as Map).cast<String, dynamic>());
        } catch (_) {}
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
      print('AuthService: Email login error: $e');
      print('AuthService: Error type: ${e.runtimeType}');
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
        try {
          await SessionService()
              .saveBackendUser((data['data'] as Map).cast<String, dynamic>());
        } catch (_) {}
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
        try {
          await SessionService()
              .saveBackendUser((data['data'] as Map).cast<String, dynamic>());
        } catch (_) {}
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
      print('AuthService: Starting sign out process...');
      await _googleSignIn.signOut();
      await _auth.signOut();
      // Clear any local user data here
      try {
        await SessionService().clearBackendSession();
        print('AuthService: Backend session cleared');
      } catch (e) {
        print('AuthService: Error clearing backend session: $e');
      }
      print('AuthService: Sign out completed successfully');
    } catch (e) {
      print('AuthService: Sign out error: $e');
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
    return PhoneUtils.isTestPhoneNumber(phoneNumber);
  }

  // Get test OTP for development
  String getTestOTP(String phoneNumber) {
    return PhoneUtils.getTestOTP(phoneNumber);
  }

  // Get current backend URL for debugging
  String get currentBackendUrl => _backendUrl;

  // Helper method to get your computer's IP address for physical device testing
  static String getPhysicalDeviceIP() {
    // Replace this with your computer's actual IP address
    // You can find it by running 'ipconfig' on Windows
    // return '192.168.110.45'; // Your computer's IP address //phone ip address
    return '192.168.29.159'; // Your computer's IP address //phone ip address
  }

  // Simple method to test if the app can reach the backend
  static Future<bool> canReachBackend() async {
    try {
      final url = 'http://${getPhysicalDeviceIP()}:3000/health';
      print('Testing connection to: $url');

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      print('Connection test result: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
