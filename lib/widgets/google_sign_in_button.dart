import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onSignInSuccess;
  final VoidCallback? onSignInError;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    this.onSignInSuccess,
    this.onSignInError,
    this.isLoading = false,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '252754882670-9tqn146j6ip3rds704r7sabdjn6m7h7t.apps.googleusercontent.com'
        : null,
    scopes: ['email', 'profile'],
  );

  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    // Sign out any existing sessions to prevent conflicts
    _googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: (widget.isLoading || _isSigningIn) ? null : _handleSignIn,
        icon: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.g_mobiledata, color: Colors.red, size: 20),
        ),
        label: (widget.isLoading || _isSigningIn)
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                ),
              )
            : Text(
                'Continue with Google',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (_isSigningIn) return;

    setState(() {
      _isSigningIn = true;
    });

    try {
      // Check if user is already signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Attempt to sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        await _signInWithGoogleAccount(googleUser);
      } else {
        // User cancelled the sign-in
        widget.onSignInError?.call();
      }
    } catch (e) {
      print('Google Sign-In error: $e');

      // Handle specific web errors
      if (kIsWeb && e.toString().contains('popup_closed')) {
        _showErrorSnackBar('Sign in was cancelled. Please try again.');
      } else {
        _showErrorSnackBar('Sign in failed: ${e.toString()}');
      }

      widget.onSignInError?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogleAccount(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      widget.onSignInSuccess?.call();
    } catch (e) {
      print('Firebase sign-in error: $e');
      _showErrorSnackBar('Authentication failed: ${e.toString()}');
      widget.onSignInError?.call();
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
