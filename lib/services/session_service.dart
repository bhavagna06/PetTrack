import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _backendUserKey = 'backend_user';

  Future<void> saveBackendUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendUserKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getBackendUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_backendUserKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getBackendUserId() async {
    final user = await getBackendUser();
    return user != null ? user['_id'] as String? : null;
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
  }
}


