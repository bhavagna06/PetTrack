// this screen is used to view the profile of the user ie the user profile

import 'package:flutter/material.dart';
import 'pet_profile_screen.dart';
import 'pets_screen.dart';
import 'home_screen.dart';
import 'post_lost_pet_screen.dart';
import 'post_found_pet_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3; // Profile is selected (index 3, not 4)

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
            builder: (context) => const PostFindtPetScreen(),
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
            child: SingleChildScrollView(
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuA9aqQrv5YoORK99BofoKx1POXKJa0-P192X4d4_r_SZOHxKNx1EJEcEBzkQVjbvqrB9NdUqxokG-cmYfhUay7GRwKuwnIiV4feZw1e3XKXHqWUfYgks4p_wa0Zd3eL-kPXIhmf6bOkQBtnFVSMzBoc5LoH5i7mWzScKDfBDZRSEpKxLD9Xm1UAYgZ2DOtnt2jQj02SfffAczA5oZLKwh5MjIdyearQNBIJnL0RueoYcZf9Bu3NUIaWhTAYVgkR6KwrmJaQBQdpwg',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Bhaagnyaaaa ❤️',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1C150D),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                color: Color(0xFF1C150D),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            Text(
                              'ethan.carter@email.com',
                              style: TextStyle(
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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone',
                              style: TextStyle(
                                color: Color(0xFF1C150D),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            Text(
                              '+1 (555) 123-4567',
                              style: TextStyle(
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

                  // My Pets item (NEW)
                  GestureDetector(
                    onTap: () {
                      // Navigate to Pet Profile Screen
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
