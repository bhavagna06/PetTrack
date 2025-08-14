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
      return 'http://${AuthService.getPhysicalDeviceIP()}:3000';
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

  // Check if user has a valid backend session (for Google users)
  Future<bool> hasValidBackendSession() async {
    final backendUser = await _sessionService.getBackendUser();
    if (backendUser != null && backendUser['_id'] != null) {
      print(
          'UserService: Valid backend session found with ID: ${backendUser['_id']}');
      return true;
    }

    // For Google users, try to recover session if no backend session exists
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      print(
          'UserService: Google user detected, attempting session recovery...');
      final success = await forceRefreshBackendSession();
      if (success) {
        print('UserService: Session recovery successful');
        return true;
      }
    }

    print('UserService: No valid backend session found');
    return false;
  }

  // Get user ID (MongoDB _id for backend operations)
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
      // Don't return Firebase UID - we need MongoDB _id for backend operations
      return null;
    }

    return null;
  }

  // Ensure Google users have a backend session
  Future<bool> _ensureBackendSession(User firebaseUser) async {
    try {
      print(
          'UserService: Ensuring backend session for Google user: ${firebaseUser.uid}');

      // Get Google account info from Firebase user
      final email = firebaseUser.email;
      final displayName = firebaseUser.displayName;
      final photoURL = firebaseUser.photoURL;

      if (email != null) {
        print('UserService: Using Firebase user data: $email');

        final response = await http.post(
          Uri.parse('$_backendUrl/api/users/google-auth'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'firebaseUid': firebaseUser.uid,
            'email': email,
            'name': displayName ?? 'Google User',
            'profileImage': photoURL,
          }),
        );

        print('UserService: Backend response status: ${response.statusCode}');
        print('UserService: Backend response body: ${response.body}');

        final data = json.decode(response.body);

        if (response.statusCode == 200 && data['success']) {
          print('UserService: Backend authentication successful');
          print('UserService: User data: ${data['data']}');
          // Store backend session locally
          final userData = (data['data'] as Map).cast<String, dynamic>();
          await _sessionService.saveBackendUser(userData);
          print(
              'UserService: Backend session saved with user ID: ${userData['_id']}');
          return true;
        } else {
          print(
              'UserService: Backend authentication failed: ${data['message']}');
        }
      } else {
        print('UserService: No email found in Firebase user');
      }
    } catch (e) {
      print('UserService: Error ensuring backend session: $e');
      print('UserService: Error type: ${e.runtimeType}');
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

  // Force refresh backend session for Google users
  Future<bool> forceRefreshBackendSession() async {
    try {
      print('UserService: Force refreshing backend session...');

      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) {
        print('UserService: No Firebase user found');
        return false;
      }

      print('UserService: Firebase user found: ${firebaseUser.uid}');
      print('UserService: Firebase user email: ${firebaseUser.email}');

      // Clear existing session
      await _sessionService.clearBackendSession();
      print('UserService: Cleared existing session');

      // Re-authenticate with backend
      final success = await _ensureBackendSession(firebaseUser);

      if (success) {
        print('UserService: Backend session refreshed successfully');
        // Verify the session was actually saved
        final userId = await _sessionService.getBackendUserId();
        print('UserService: Verified session refresh, user ID: $userId');
        return userId != null;
      } else {
        print('UserService: Failed to refresh backend session');
        return false;
      }
    } catch (e) {
      print('UserService: Error refreshing backend session: $e');
      return false;
    }
  }
}
