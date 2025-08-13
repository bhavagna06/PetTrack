import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _backendUserKey = 'backend_user';

  Future<void> saveBackendUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user);
    await prefs.setString(_backendUserKey, userJson);
    print('SessionService: Saved backend user with ID: ${user['_id']}');
    print('SessionService: User data: $userJson');
  }

  Future<Map<String, dynamic>?> getBackendUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_backendUserKey);
    if (raw == null || raw.isEmpty) {
      print('SessionService: No backend user data found');
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        print('SessionService: Retrieved backend user with ID: ${decoded['_id']}');
        return decoded;
      }
      print('SessionService: Invalid user data format');
      return null;
    } catch (e) {
      print('SessionService: Error decoding user data: $e');
      return null;
    }
  }

  Future<String?> getBackendUserId() async {
    final user = await getBackendUser();
    final userId = user != null ? user['_id'] as String? : null;
    print('SessionService: getBackendUserId() returned: $userId');
    return userId;
  }

  Future<bool> hasBackendSession() async {
    final user = await getBackendUser();
    return user != null && (user['_id'] as String?) != null;
  }

  Future<bool> isBackendSessionValid() async {
    final user = await getBackendUser();
    if (user == null || user['_id'] == null) return false;

    // Check if the session has expired (optional - you can add expiration logic here)
    // For now, we'll just check if the user data exists
    return true;
  }

  Future<void> clearBackendSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_backendUserKey);
    print('SessionService: Backend session cleared');
  }
}
