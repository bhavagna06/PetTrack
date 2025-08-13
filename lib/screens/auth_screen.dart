// this screen is used to authenticate the user ie to login or sign up

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
// Removed unused imports
import 'home_screen.dart';
// Session is stored via AuthService on success

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;
  late AnimationController _formController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _formAnimation;

  // Style constants
  static const Color bgColor = Color(0xFFFCFAF8);
  static const Color primaryTextColor = Color(0xFF1C150D);
  static const Color secondaryTextColor = Color(0xFF9C7649);
  static const Color inputBgColor = Color(0xFFF4EEE7);
  static const Color primaryButtonColor = Color(0xFFF2870C);
  static const Color googleButtonColor = Color(0xFF4285F4);

  @override
  void initState() {
    super.initState();
    print('AuthScreen: Initialized');
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Fade animation for the main content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Slide animation for form elements
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Floating animation for decorative elements
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Form transition animation
    _formController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();

    // Test backend connection on init
    _testBackendConnection();

    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _formController.forward();
    });
    _floatingController.repeat(reverse: true);
  }

  // Test backend connection
  Future<void> _testBackendConnection() async {
    try {
      print('AuthScreen: Testing backend connection...');
      final results = await AuthService.comprehensiveConnectionTest();

      if (results['success'] == true) {
        print('AuthScreen: ✅ Backend connection successful');
      } else {
        print('AuthScreen: ❌ Backend connection failed');
        print('AuthScreen: Error: ${results['error']}');
      }
    } catch (e) {
      print('AuthScreen: Connection test error: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    _formController.reset();
    _formController.forward();
  }

  @override
  Widget build(BuildContext context) {
    print('AuthScreen: Building auth screen');

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      Theme.of(context).textTheme,
    );

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Top section with logo and floating elements
                        Expanded(flex: 2, child: _buildTopSection()),

                        // Form section
                        _buildFormSection(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        child: Stack(
          children: [
            // Floating decorative elements
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 50 + _floatingAnimation.value,
                  right: 30,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: primaryButtonColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: primaryButtonColor,
                      size: 30,
                    ),
                  ),
                );
              },
            ),

            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 100 - _floatingAnimation.value,
                  left: 40,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: secondaryTextColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),

            // Main logo and title
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: primaryButtonColor,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: primaryButtonColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.pets,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'PetTrack',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reuniting pets with their families',
                    style: TextStyle(fontSize: 16, color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _formAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Auth mode toggle
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!_isLogin) _toggleAuthMode();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _isLogin
                                      ? primaryButtonColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _isLogin
                                    ? primaryButtonColor
                                    : secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_isLogin) _toggleAuthMode();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: !_isLogin
                                      ? primaryButtonColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Sign Up',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: !_isLogin
                                    ? primaryButtonColor
                                    : secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Form fields
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        if (!_isLogin) ...[
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildTextField(
                          controller: _emailController,
                          label: _isLogin ? 'Email or Phone' : 'Email',
                          hint: _isLogin
                              ? 'Enter your email or phone number'
                              : 'Enter your email',
                          icon: Icons.email_outlined,
                          keyboardType: _isLogin
                              ? TextInputType.text
                              : TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        if (!_isLogin) ...[
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: 'Enter your phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: secondaryTextColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Confirm your password',
                            icon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: secondaryTextColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (_isLogin) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                          _showMessage(
                              'Forgot password functionality to be implemented');
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: primaryButtonColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Email Auth Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryButtonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isLogin ? 'Login' : 'Create Account',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Google Auth Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleAuth,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryTextColor,
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: googleButtonColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      label: Text(
                        _isLogin
                            ? 'Continue with Google'
                            : 'Sign up with Google',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Extra padding at bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: secondaryTextColor.withOpacity(0.7),
              fontSize: 16,
            ),
            prefixIcon: Icon(icon, color: secondaryTextColor),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: inputBgColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryButtonColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(color: primaryTextColor, fontSize: 16),
        ),
      ],
    );
  }

  void _handleEmailAuth() async {
    if (_isLogin) {
      await _handleEmailLogin();
    } else {
      await _handleEmailSignup();
    }
  }

  Future<void> _handleEmailLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Please fill in all fields', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if input is email or phone number
      final input = _emailController.text.trim();
      final isEmail = input.contains('@');

      if (isEmail) {
        // Email login
        final result = await _authService.signInWithEmail(
          input,
          _passwordController.text,
        );

        if (result['success']) {
          if (mounted) {
            // Ensure backend session is stored (already stored in service), then navigate
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const PetTrackingHomeScreen()),
            );
          }
        } else {
          _showMessage(result['message'] ?? 'Login failed', isError: true);
        }
      } else {
        // Phone number login
        final result = await _authService.signInWithPhone(
          input, // Phone number
          _passwordController.text, // Password
        );

        if (result['success']) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const PetTrackingHomeScreen()),
            );
          }
        } else {
          _showMessage('Phone number or password incorrect', isError: true);
        }
      }
    } catch (e) {
      _showMessage('Login failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleEmailSignup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showMessage('Please fill in all fields', isError: true);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Passwords do not match', isError: true);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showMessage('Password must be at least 6 characters', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signUpWithEmail(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );

      if (result['success']) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const PetTrackingHomeScreen()),
          );
        }
      } else {
        _showMessage(result['message'] ?? 'Sign up failed', isError: true);
      }
    } catch (e) {
      _showMessage('Sign up failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleGoogleAuth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithGoogle();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const PetTrackingHomeScreen()),
        );
      }
    } catch (e) {
      _showMessage('Google sign in failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryButtonColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
