import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_service.dart';
import 'session_service.dart';

class UserService {
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();

  // Get the appropriate backend URL based on platform
  String get _backendUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return Platform.isAndroid
          ? 'http://10.0.2.2:3000'
          : 'http://localhost:3000';
    }
  }

  // Get current user data (from Firebase or MongoDB)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      // First check if user is logged in with Google (Firebase)
      final firebaseUser = _authService.currentUser;

      if (firebaseUser != null) {
        // User is logged in with Google
        return {
          'id': firebaseUser.uid,
          'name': firebaseUser.displayName ?? 'Unknown User',
          'email': firebaseUser.email ?? '',
          'phone': firebaseUser.phoneNumber ?? '',
          'profileImage': firebaseUser.photoURL ?? '',
          'authProvider': 'google',
          'isEmailVerified': firebaseUser.emailVerified,
        };
      }

      // Check if user is logged in with email/phone (MongoDB)
      final backendUser = await _sessionService.getBackendUser();
      if (backendUser != null) {
        return {
          'id': backendUser['_id'],
          'name': backendUser['name'] ?? 'Unknown User',
          'email': backendUser['email'] ?? '',
          'phone': backendUser['phone'] ?? '',
          'profileImage': backendUser['profileImage'] ?? '',
          'authProvider': 'email',
          'isEmailVerified': backendUser['isVerified'] ?? false,
          'address': backendUser['address'],
          'notifications': backendUser['notifications'],
        };
      }

      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Get user by ID from MongoDB backend
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
    Map<String, dynamic>? address,
    Map<String, dynamic>? notifications,
  }) async {
    try {
      final requestBody = <String, dynamic>{};
      if (name != null) requestBody['name'] = name;
      if (email != null) requestBody['email'] = email;
      if (phone != null) requestBody['phone'] = phone;
      if (address != null) requestBody['address'] = json.encode(address);
      if (notifications != null)
        requestBody['notifications'] = json.encode(notifications);

      final response = await http.put(
        Uri.parse('$_backendUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        // Update local session data
        await _sessionService.saveBackendUser(data['data']);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Update failed',
        };
      }
    } catch (e) {
      print('Error updating user profile: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) return true;

    final backendUser = await _sessionService.getBackendUser();
    return backendUser != null;
  }

  // Get user ID (Firebase UID or MongoDB _id)
  Future<String?> getUserId() async {
    // First check if we have a backend session (for Google users or email/phone users)
    final backendUserId = await _sessionService.getBackendUserId();
    if (backendUserId != null) {
      return backendUserId;
    }

    // For Google users, try to authenticate with backend if no session exists
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      // Check if this is a Google user and try to authenticate with backend
      final hasBackendSession = await _sessionService.hasBackendSession();
      if (!hasBackendSession) {
        // Try to authenticate with backend
        final success = await _ensureBackendSession(firebaseUser);
        if (success) {
          return await _sessionService.getBackendUserId();
        }
      }
      return firebaseUser.uid;
    }

    return null;
  }

  // Ensure Google users have a backend session
  Future<bool> _ensureBackendSession(User firebaseUser) async {
    try {
      print(
          'UserService: Ensuring backend session for Google user: ${firebaseUser.uid}');

      // Get Google account info
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signInSilently();

      if (googleUser != null) {
        print('UserService: Found Google account: ${googleUser.email}');

        final response = await http.post(
          Uri.parse('$_backendUrl/api/users/google-auth'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'firebaseUid': firebaseUser.uid,
            'email': googleUser.email,
            'name': googleUser.displayName,
            'profileImage': googleUser.photoUrl,
          }),
        );

        print('UserService: Backend response status: ${response.statusCode}');
        final data = json.decode(response.body);

        if (response.statusCode == 200 && data['success']) {
          print('UserService: Backend authentication successful');
          // Store backend session locally
          await _sessionService
              .saveBackendUser((data['data'] as Map).cast<String, dynamic>());
          return true;
        } else {
          print(
              'UserService: Backend authentication failed: ${data['message']}');
        }
      } else {
        print('UserService: No Google account found for silent sign-in');
      }
    } catch (e) {
      print('UserService: Error ensuring backend session: $e');
    }
    return false;
  }

  // Get authentication provider
  Future<String?> getAuthProvider() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) return 'google';

    final backendUser = await _sessionService.getBackendUser();
    return backendUser != null ? 'email' : null;
  }
}
