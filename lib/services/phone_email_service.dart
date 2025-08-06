import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PhoneEmailService {
  // Phone.Email API configuration
  static const String _baseUrl = 'https://api.phone.email';
  static const String _apiKey =
      'yOee4EFBjPVdtyi9qwd976aoIR9W5l94'; // You'll need to get this from Phone.Email

  // Validate Indian phone number format
  bool isValidIndianPhoneNumber(String phoneNumber) {
    // Remove any spaces, dashes, or other characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Indian phone number patterns:
    // +91 9876543210 (with country code)
    // 9876543210 (without country code, 10 digits)
    // 09876543210 (with leading 0, 11 digits)

    if (cleanNumber.startsWith('91') && cleanNumber.length == 12) {
      return true;
    } else if (cleanNumber.length == 10) {
      return true;
    } else if (cleanNumber.startsWith('0') && cleanNumber.length == 11) {
      return true;
    }

    return false;
  }

  // Format phone number to international format
  String formatPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.startsWith('91') && cleanNumber.length == 12) {
      return '+$cleanNumber';
    } else if (cleanNumber.length == 10) {
      return '+91$cleanNumber';
    } else if (cleanNumber.startsWith('0') && cleanNumber.length == 11) {
      return '+91${cleanNumber.substring(1)}';
    }

    return phoneNumber;
  }

  // Send OTP using Phone.Email
  Future<Map<String, dynamic>> sendOTP({
    required String phoneNumber,
    required String name,
  }) async {
    try {
      // Validate phone number
      if (!isValidIndianPhoneNumber(phoneNumber)) {
        throw Exception('Please enter a valid Indian phone number (10 digits)');
      }

      String formattedNumber = formatPhoneNumber(phoneNumber);

      // Phone.Email API endpoint for sending OTP
      final url = Uri.parse('$_baseUrl/send-otp');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'phone_number': formattedNumber,
          'user_name': name,
          'country_code': 'IN',
          'template': 'Your PetTrack verification code is: {otp}',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'OTP sent successfully',
          'request_id': data['request_id'],
          'phone_number': formattedNumber,
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      print('Phone.Email send OTP error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Verify OTP using Phone.Email
  Future<Map<String, dynamic>> verifyOTP({
    required String requestId,
    required String otp,
    required String phoneNumber,
  }) async {
    try {
      // Phone.Email API endpoint for verifying OTP
      final url = Uri.parse('$_baseUrl/verify-otp');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'request_id': requestId,
          'otp': otp,
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'OTP verified successfully',
          'user_data': {
            'phone_number': phoneNumber,
            'verified': true,
            'verification_time': DateTime.now().toIso8601String(),
          },
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      print('Phone.Email verify OTP error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Resend OTP using Phone.Email
  Future<Map<String, dynamic>> resendOTP({
    required String requestId,
    required String phoneNumber,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/resend-otp');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'request_id': requestId,
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'OTP resent successfully',
          'request_id': data['request_id'],
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      print('Phone.Email resend OTP error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Check OTP status
  Future<Map<String, dynamic>> checkOTPStatus({
    required String requestId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/check-status/$requestId');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_apiKey'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to check status');
      }
    } catch (e) {
      print('Phone.Email check status error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // For development/testing - simulate OTP without API calls
  Future<Map<String, dynamic>> sendTestOTP({
    required String phoneNumber,
    required String name,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    return {
      'success': true,
      'message': 'Test OTP sent successfully',
      'request_id': 'test_${DateTime.now().millisecondsSinceEpoch}',
      'phone_number': formatPhoneNumber(phoneNumber),
      'test_otp': '123456', // Fixed test OTP
    };
  }

  Future<Map<String, dynamic>> verifyTestOTP({
    required String requestId,
    required String otp,
    required String phoneNumber,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    if (otp == '123456') {
      return {
        'success': true,
        'message': 'Test OTP verified successfully',
        'user_data': {
          'phone_number': phoneNumber,
          'verified': true,
          'verification_time': DateTime.now().toIso8601String(),
        },
      };
    } else {
      return {'success': false, 'message': 'Invalid test OTP. Use 123456'};
    }
  }
}
