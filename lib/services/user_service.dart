import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) return firebaseUser.uid;

    return await _sessionService.getBackendUserId();
  }

  // Get authentication provider
  Future<String?> getAuthProvider() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) return 'google';

    final backendUser = await _sessionService.getBackendUser();
    return backendUser != null ? 'email' : null;
  }
}
