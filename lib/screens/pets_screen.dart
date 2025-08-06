// this screen is used to view the pet profile of the user ie the pet that is laready registered under the user

import 'package:flutter/material.dart';
import 'pet_profile_screen.dart';
import 'home_screen.dart';
import 'post_lost_pet_screen.dart';
import 'post_found_pet_screen.dart';
import 'profile_screen.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({Key? key}) : super(key: key);

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
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
                              'My Pets',
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

                  // Account section
                  // const Padding(
                  //   padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  //   child: Text(
                  //     'Account',
                  //     style: TextStyle(
                  //       color: Color(0xFF1C150D),
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold,
                  //       fontFamily: 'Plus Jakarta Sans',
                  //     ),
                  //   ),
                  // ),

                  // My Pets item (NEW)
                  GestureDetector(
                    onTap: () {
                      // Navigate to Pet Profile Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PetProfileScreen(),
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
                                  'Add New Pet',
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
