// this screen is used to view the pet profile of the user ie the pet that is laready registered under the user

import 'package:flutter/material.dart';
import 'pet_profile_screen.dart';
import 'home_screen.dart';
import 'post_lost_pet_screen.dart';
import 'post_found_pet_screen.dart';
import 'profile_screen.dart'; // Added import for ProfileScreen

class MyPetScreen extends StatefulWidget {
  const MyPetScreen({Key? key}) : super(key: key);

  @override
  State<MyPetScreen> createState() => _MyPetScreenState();
}

class _MyPetScreenState extends State<MyPetScreen> {
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
                              'My Pet',
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

                  // Pet Profile section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Pet image and name - centered
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF4EEE7),
                                border: Border.all(
                                  color: const Color(0xFFF4EEE7),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: Stack(
                                  children: [
                                    // Pet image placeholder or actual image
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: const Color(0xFFF4EEE7),
                                      child: const Icon(
                                        Icons.pets,
                                        size: 48,
                                        color: Color(0xFF9C7649),
                                      ),
                                    ),
                                    // Edit overlay (optional)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigate to edit pet profile
                                        },
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF2870C),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Buddy 🐕',
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

                  // Pet Information section
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Pet Information',
                      style: TextStyle(
                        color: Color(0xFF1C150D),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ),

                  // Pet Type item
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
                            Icons.pets,
                            color: Color(0xFF1C150D),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pet Type',
                              style: TextStyle(
                                color: Color(0xFF1C150D),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            Text(
                              'Dog',
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

                  // Breed item
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
                            Icons.category_outlined,
                            color: Color(0xFF1C150D),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Breed',
                              style: TextStyle(
                                color: Color(0xFF1C150D),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            Text(
                              'Golden Retriever',
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

                  // Color item
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
                            Icons.palette_outlined,
                            color: Color(0xFF1C150D),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Color',
                              style: TextStyle(
                                color: Color(0xFF1C150D),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            Text(
                              'Golden',
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

                  // Home Location item
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
                            Icons.location_on_outlined,
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
                                'Home Location',
                                style: TextStyle(
                                  color: Color(0xFF1C150D),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                              Text(
                                '123 Pet Street, Dog City, DC 12345',
                                style: TextStyle(
                                  color: Color(0xFF9C7649),
                                  fontSize: 14,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pet Actions section
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Pet Actions',
                      style: TextStyle(
                        color: Color(0xFF1C150D),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ),

                  // Edit Pet Profile item
                  GestureDetector(
                    onTap: () {
                      // Navigate to edit pet profile
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4EEE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF1C150D),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Edit Pet Profile',
                              style: TextStyle(
                                color: Color(0xFF1C150D),
                                fontSize: 16,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
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

                  // Pet Photos item
                  GestureDetector(
                    onTap: () {
                      // Navigate to pet photos gallery
                    },
                    child: Container(
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
                              Icons.photo_library_outlined,
                              color: Color(0xFF1C150D),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Pet Photos',
                              style: TextStyle(
                                color: Color(0xFF1C150D),
                                fontSize: 16,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
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

                  // Pet Notifications item
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
                            'Pet Alerts',
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

                  // Delete Pet item (with warning color)
                  GestureDetector(
                    onTap: () {
                      _showDeleteConfirmation(context);
                    },
                    child: Container(
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
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Delete Pet Profile',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
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

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFCFAF8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Pet Profile',
            style: TextStyle(
              color: Color(0xFF1C150D),
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this pet profile? This action cannot be undone.',
            style: TextStyle(
              color: Color(0xFF9C7649),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF9C7649),
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement delete logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pet profile deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
              ),
            ),
          ],
        );
      },
    );
  }
}
