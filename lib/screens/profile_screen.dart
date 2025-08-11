// this screen is used to view the profile of the user ie the user profile

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'pets_screen.dart';
import 'home_screen.dart';
import 'post_lost_pet_screen.dart';
import 'post_found_pet_screen.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3; // Profile is selected (index 3, not 4)
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userData = await _userService.getCurrentUser();

      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on index
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PetTrackingHomeScreen(),
          ),
        );
        break;
      case 1: // Post Lost
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PostLostPetScreen(),
          ),
        );
        break;
      case 2: // Post Found
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PostFoundPetScreen(),
          ),
        );
        break;
      case 3: // Profile
        // Already on profile screen, no navigation needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      body: Column(
        children: [
          // Main content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1C150D),
                    ),
                  )
                : _userData == null
                    ? const Center(
                        child: Text(
                          'Please log in to view your profile',
                          style: TextStyle(
                            color: Color(0xFF1C150D),
                            fontSize: 16,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with back arrow and title
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back,
                                        color: Color(0xFF1C150D),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(right: 48),
                                      child: const Text(
                                        'Profile',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF1C150D),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Profile section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Profile image and name - centered
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 128,
                                        height: 128,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: _userData!['profileImage'] !=
                                                      null &&
                                                  _userData!['profileImage']
                                                      .isNotEmpty
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      _userData![
                                                          'profileImage']),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: _userData!['profileImage'] ==
                                                    null ||
                                                _userData!['profileImage']
                                                    .isEmpty
                                            ? const Icon(
                                                Icons.person,
                                                size: 64,
                                                color: Color(0xFF9C7649),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _userData!['name'] ?? 'Unknown User',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF1C150D),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                      if (_userData!['authProvider'] != null)
                                        Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _userData!['authProvider'] ==
                                                    'google'
                                                ? const Color(0xFF4285F4)
                                                : const Color(0xFF34A853),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _userData!['authProvider'] ==
                                                    'google'
                                                ? 'Google Account'
                                                : 'Email Account',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Account section
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                'Account',
                                style: TextStyle(
                                  color: Color(0xFF1C150D),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ),

                            // Email item
                            if (_userData!['email'] != null &&
                                _userData!['email'].isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4EEE7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.email_outlined,
                                        color: Color(0xFF1C150D),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Email',
                                          style: TextStyle(
                                            color: Color(0xFF1C150D),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                        Text(
                                          _userData!['email'],
                                          style: const TextStyle(
                                            color: Color(0xFF9C7649),
                                            fontSize: 14,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            // Phone item
                            if (_userData!['phone'] != null &&
                                _userData!['phone'].isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4EEE7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.phone_outlined,
                                        color: Color(0xFF1C150D),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Phone',
                                          style: TextStyle(
                                            color: Color(0xFF1C150D),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                        Text(
                                          _userData!['phone'],
                                          style: const TextStyle(
                                            color: Color(0xFF9C7649),
                                            fontSize: 14,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            // My Pets item
                            GestureDetector(
                              onTap: () {
                                // Navigate to Pets Screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PetsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4EEE7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.pets,
                                        color: Color(0xFF1C150D),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'My Pets',
                                            style: TextStyle(
                                              color: Color(0xFF1C150D),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                          Text(
                                            'Manage your pet profiles',
                                            style: TextStyle(
                                              color: Color(0xFF9C7649),
                                              fontSize: 14,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFF9C7649),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Posts section
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                'Posts',
                                style: TextStyle(
                                  color: Color(0xFF1C150D),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ),

                            // My Posts item
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4EEE7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.description_outlined,
                                      color: Color(0xFF1C150D),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'My Posts',
                                      style: TextStyle(
                                        color: Color(0xFF1C150D),
                                        fontSize: 16,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Settings section
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                'Settings',
                                style: TextStyle(
                                  color: Color(0xFF1C150D),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ),

                            // Notifications item
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4EEE7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.notifications_outlined,
                                      color: Color(0xFF1C150D),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Notifications',
                                      style: TextStyle(
                                        color: Color(0xFF1C150D),
                                        fontSize: 16,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Privacy item
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4EEE7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.shield_outlined,
                                      color: Color(0xFF1C150D),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Privacy',
                                      style: TextStyle(
                                        color: Color(0xFF1C150D),
                                        fontSize: 16,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SwitchListTile(
                              title: const Text(
                                'Dark Mode',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                ),
                              ),
                              value: Provider.of<ThemeProvider>(context)
                                  .isDarkMode,
                              onChanged: (value) {
                                Provider.of<ThemeProvider>(context,
                                        listen: false)
                                    .toggleTheme(value);
                              },
                              activeColor: const Color(0xFF9C7649),
                            ),

                            // Logout button
                            const SizedBox(height: 16),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Show confirmation dialog
                                  final bool? shouldLogout =
                                      await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: Color(0xFF1C150D),
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: const Text(
                                          'Are you sure you want to logout?',
                                          style: TextStyle(
                                            color: Color(0xFF1C150D),
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Color(0xFF9C7649),
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.redAccent.shade700,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            child: const Text(
                                              'Logout',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Plus Jakarta Sans',
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldLogout == true) {
                                    try {
                                      // Show loading indicator
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF1C150D),
                                            ),
                                          );
                                        },
                                      );

                                      // Perform logout
                                      await _authService.signOut();

                                      // Close loading dialog
                                      Navigator.of(context).pop();

                                      // Navigate to welcome screen
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const WelcomeScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    } catch (e) {
                                      // Close loading dialog
                                      Navigator.of(context).pop();

                                      // Show error message
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error logging out: $e',
                                            style: const TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 25),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),

          // Bottom Navigation Bar
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF4EEE7), width: 1),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFFFCFAF8),
              selectedItemColor: const Color(0xFF1C150D),
              unselectedItemColor: const Color(0xFF9C7649),
              currentIndex: _selectedIndex,
              onTap: _onNavigationTap,
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.015,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.015,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 24),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_box_outlined, size: 24),
                  label: 'Post Lost',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_box_outlined, size: 24),
                  label: 'Post Found',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline, size: 24),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
