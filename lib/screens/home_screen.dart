// this screen is used to display the home screen of the app which display all the lost and found pets

import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'post_lost_pet_screen.dart';
import 'post_found_pet_screen.dart';

class PetTrackingHomeScreen extends StatefulWidget {
  const PetTrackingHomeScreen({Key? key}) : super(key: key);

  @override
  State<PetTrackingHomeScreen> createState() => _PetTrackingHomeScreenState();
}

class _PetTrackingHomeScreenState extends State<PetTrackingHomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _selectedSearchCategory = 'All';
  bool _isSearchExpanded = false;

  final List<String> _searchCategories = [
    'All',
    'Dog',
    'Cat',
    'Bird',
    'Other',
  ];

  final List<Map<String, String>> recentLostPets = [
    {
      'type': 'Lost Dog',
      'name': 'Max',
      'description': 'Golden Retriever, Male, 2 years old',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCuE3DDMhXMOCthVpQZkL_tOdgkue7nXZls-H7TGGcdPGgX68yy0CoN_BNISuJg1tGTi6evYcJYMEczBbGoNkY6gFMsKajGy3tj_4Qlf6N-dvd1kYjXqcXKg2GL5j2x7_OvK2dujWVUGXiEu1KfVK2tU4ZsHhok9_2AQE6ZqIYIwJYN-tFIygdb-ZZjPz7Bz1EevxT8VaMnYpBs21GXXlPDezx0xnysqiX_lrr-u8KT0QqH46GFMPJAz9Soiv09izz8WJUX6gXx6w',
    },
    {
      'type': 'Lost Cat',
      'name': 'Whiskers',
      'description': 'Siamese, Female, 3 years old',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA12yVAhHnXfVNbz9Gtw9Nir7LXPVMPTZKKFOsOFIDlec42RUTM2qE-h-azE0IVNKsrWlA6AgdHq6x9PW0lQlLsOHcEozEhzwc89_BejPtvivDERmtFF8srkp46r3zggxMq9ThJpy9tw8VEGYCERLWH85TwbgUhtKO_EDBTreChCgTlbBwP8N6g_2AYpaa4HXzjGMgpCfMB6ntQfq3C-DmAeGQKBPuCYLMD5PI50yUgWm3n2DciUpXDJKenIomjncBkasSVAbihZw',
    },
    {
      'type': 'Lost Dog',
      'name': 'Buddy',
      'description': 'Labrador, Male, 5 years old',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDtKUcBJF7g2iXoki-MvpnaS3hUaewk8UVWSs5AfllqzKfT_EdeNkX02kH8qTHFk_CiSufU4OF2M-eR9eKE5Y2R06PDiG31bBy-_sQixBldpdZc5K6tF3Yt6FmqdscJOCKOo6us898qJKHvuq_6pljdpyimnao76G2Vx0jOdtDcFJ7a_cf97R278ToDsxDLO0XlnNenA7YLC_ekla2wrq_OtRoA0rK7oh5aJOHESuo15O-s796rUPyyLqRb3_qJWB1VOGVyF_TYVQ',
    },
    {
      'type': 'Lost Cat',
      'name': 'Mittens',
      'description': 'Tabby, Female, 1 year old',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCCToixK_FBjhwXRs_29DlPgJP-FXxAFrcPdviZY_NnyLFobVN_f-ryzkGmCsAzj3-IOqSprknGKQxBrtSZFL4npD7Ai0sEq5M1YVvorKLXfF6QG47-l0uGs3r6uFSltQbEPnMGiBqjA5aCyIVxBA9BaJvKhYxmQ8pw58Id14NqLNZyaTLuKPTr1aoNgSEn_AmNoBi5u8FR8qeu8PBVulkZ9-F4OU82jOvTkyGX0lcaVSgvLxvjaZP7Xy3t7W3MFCZkKsrQYX8sQw',
    },
  ];

  List<Map<String, String>> get filteredPets {
    if (_searchController.text.isEmpty && _selectedSearchCategory == 'All') {
      return recentLostPets;
    }

    return recentLostPets.where((pet) {
      bool matchesCategory = _selectedSearchCategory == 'All' ||
          pet['type']!
              .toLowerCase()
              .contains(_selectedSearchCategory.toLowerCase());

      bool matchesName = _searchController.text.isEmpty ||
          pet['name']!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

      return matchesCategory && matchesName;
    }).toList();
  }

  void _onNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on index
    switch (index) {
      case 0: // Home
        // Already on home screen, no navigation needed
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: const Center(
                child: Text(
                  'PetTrack',
                  style: TextStyle(
                    color: Color(0xFF1C150D),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.015,
                  ),
                ),
              ),
            ),

            // Search Bar with Categories
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Main Search Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4EEE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Icon(
                            Icons.search,
                            color: Color(0xFF9C7649),
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search for lost pets by name...',
                              hintStyle: TextStyle(
                                color: Color(0xFF9C7649),
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(
                              color: Color(0xFF1C150D),
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSearchExpanded = !_isSearchExpanded;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 16, left: 8),
                            child: Icon(
                              Icons.filter_list,
                              color: Color(0xFF9C7649),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Filter (Expandable)
                  if (_isSearchExpanded) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _searchCategories.length,
                        itemBuilder: (context, index) {
                          final category = _searchCategories[index];
                          final isSelected =
                              category == _selectedSearchCategory;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSearchCategory = category;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF2870C)
                                    : const Color(0xFFF4EEE7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFF2870C)
                                      : const Color(0xFFE8DCCE),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF9C7649),
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Recent Lost Pets Title
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchController.text.isNotEmpty ||
                            _selectedSearchCategory != 'All'
                        ? 'Search Results (${filteredPets.length})'
                        : 'Recent Lost Pets',
                    style: const TextStyle(
                      color: Color(0xFF1C150D),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.015,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty ||
                      _selectedSearchCategory != 'All')
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                          _selectedSearchCategory = 'All';
                          _isSearchExpanded = false;
                        });
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Color(0xFFF2870C),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Recent Lost Pets List
            Expanded(
              child: filteredPets.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Color(0xFF9C7649),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No pets found',
                            style: TextStyle(
                              color: Color(0xFF9C7649),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try adjusting your search criteria',
                            style: TextStyle(
                              color: Color(0xFF9C7649),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredPets.length,
                      itemBuilder: (context, index) {
                        final pet = filteredPets[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: _buildPetCard(
                            type: pet['type']!,
                            name: pet['name']!,
                            description: pet['description']!,
                            imageUrl: pet['image']!,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF4EEE7), width: 1)),
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
    );
  }

  Widget _buildPetCard({
    required String type,
    required String name,
    required String description,
    required String imageUrl,
  }) {
    return Row(
      children: [
        // Pet Information
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(
                  color: Color(0xFF9C7649),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF1C150D),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF9C7649),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Pet Image
        Expanded(
          flex: 1,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Example usage in main.dart or app.dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetTrack App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Plus Jakarta Sans', // Add this font to pubspec.yaml
      ),
      home: const PetTrackingHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
