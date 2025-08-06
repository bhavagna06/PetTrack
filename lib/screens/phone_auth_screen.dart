// this screen is used to authenticate the user via phone number

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _verificationId;
  String? _formattedPhoneNumber;
  ConfirmationResult? _confirmationResult;

  @override
  void initState() {
    super.initState();
    print('PhoneAuthScreen: Initialized with Firebase Phone Auth for Web');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Validate Indian phone number format
  bool isValidIndianPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

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

  Future<void> _sendOTP() async {
    print('PhoneAuthScreen: Sending OTP via Firebase Phone Auth for Web');

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate Indian phone number format
    if (!isValidIndianPhoneNumber(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Indian phone number (10 digits)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String formattedNumber = formatPhoneNumber(_phoneController.text);
      print('PhoneAuthScreen: Formatted phone number: $formattedNumber');

      // Use Firebase Phone Auth for Web
      _confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(
        formattedNumber,
      );

      print('PhoneAuthScreen: SMS code sent successfully');
      setState(() {
        _formattedPhoneNumber = formattedNumber;
        _isOtpSent = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'OTP sent successfully! Check your phone for the verification code.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('PhoneAuthScreen: Send OTP error: $e');
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Failed to send OTP';
      if (e.toString().contains('invalid-phone-number')) {
        errorMessage = 'Invalid phone number format';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many requests. Please try again later.';
      } else if (e.toString().contains('quota-exceeded')) {
        errorMessage = 'SMS quota exceeded. Please try again later.';
      } else if (e.toString().contains('recaptcha')) {
        errorMessage = 'reCAPTCHA verification failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _verifyOTP() async {
    print('PhoneAuthScreen: Verifying OTP via Firebase Phone Auth for Web');

    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_confirmationResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification session expired. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Confirm the OTP
      UserCredential userCredential =
          await _confirmationResult!.confirm(_otpController.text);

      print('PhoneAuthScreen: OTP verification successful');
      print('User ID: ${userCredential.user?.uid}');
      print('Phone Number: ${userCredential.user?.phoneNumber}');
      print('User Name: ${_nameController.text.trim()}');

      // Update user display name if provided
      if (_nameController.text.trim().isNotEmpty) {
        await userCredential.user
            ?.updateDisplayName(_nameController.text.trim());
      }

      // Navigate to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const PetTrackingHomeScreen()),
        );
      }
    } catch (e) {
      print('PhoneAuthScreen: OTP verification error: $e');
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Invalid OTP. Please try again.';
      if (e.toString().contains('invalid-verification-code')) {
        errorMessage = 'Invalid verification code. Please check and try again.';
      } else if (e.toString().contains('session-expired')) {
        errorMessage =
            'Verification session expired. Please request a new OTP.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('PhoneAuthScreen: Building phone auth screen');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6B73FF), Color(0xFF000DFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Header Text
                const Text(
                  'Phone Authentication',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Sign in with your phone number',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),

                const SizedBox(height: 50),

                if (!_isOtpSent) ...[
                  // Name Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person, color: Colors.white70),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Phone Number Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _phoneController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Enter Indian phone number (10 digits)',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.phone, color: Colors.white70),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Send OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6B73FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF6B73FF),
                                ),
                              ),
                            )
                          : const Text(
                              'Send OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  // OTP Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _otpController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter 6-digit OTP',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.lock, color: Colors.white70),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Verify OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6B73FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF6B73FF),
                                ),
                              ),
                            )
                          : const Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Change phone number button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                        _confirmationResult = null;
                      });
                    },
                    child: const Text(
                      'Change phone number',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Terms and Privacy
                const Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
