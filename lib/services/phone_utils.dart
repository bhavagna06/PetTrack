class PhoneUtils {
  // Validate Indian phone number format
  static bool isValidIndianPhoneNumber(String phoneNumber) {
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

  // Format phone number for backend API (without country code)
  static String formatPhoneNumberForBackend(String phoneNumber) {
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

  // Format phone number for international format (with country code)
  static String formatPhoneNumberForInternational(String phoneNumber) {
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

  // Check if phone number is a test number (for development)
  static bool isTestPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    // Common test numbers
    return cleanNumber.contains('123456') ||
        cleanNumber.contains('000000') ||
        cleanNumber.contains('111111');
  }

  // Get test OTP for development
  static String getTestOTP(String phoneNumber) {
    // For development, return a fixed OTP
    // In production, this should never be used
    return '123456';
  }
}
