// this screen is used to view the pet profile of the user ie the pet that is laready registered under the user

import 'package:flutter/material.dart';
import 'pet_profile_screen.dart';
import 'home_screen.dart';
import 'post_lost_pet_screen.dart';
import 'post_found_pet_screen.dart';
import 'profile_screen.dart';
import 'pet_details_screen.dart';
import '../services/pet_service.dart';
import '../services/user_service.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  int _selectedIndex = 3; // Profile is selected (index 3, not 4)
  final PetService _petService = PetService();
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _pets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserPets();
  }

  Future<void> _loadUserPets() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userId = await _userService.getUserId();
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please log in to view your pets';
        });
        return;
      }

      // Only fetch registered pets (not reported pets)
      final pets = await _petService.fetchPets(
        ownerId: userId,
        registrationType: 'registered',
      );
      setState(() {
        _pets = pets;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading pets: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load pets. Please try again.';
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
        break;
    }
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: pet['profileImage'] != null && pet['profileImage'].isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(pet['profileImage']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: pet['profileImage'] == null || pet['profileImage'].isEmpty
              ? const Icon(
                  Icons.pets,
                  size: 30,
                  color: Color(0xFF9C7649),
                )
              : null,
        ),
        title: Text(
          pet['petName'] ?? 'Unknown Pet',
          style: const TextStyle(
            color: Color(0xFF1C150D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${pet['petType'] ?? 'Unknown'} • ${pet['breed'] ?? 'Unknown breed'}',
              style: const TextStyle(
                color: Color(0xFF9C7649),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Color: ${pet['color'] ?? 'Unknown'}',
              style: const TextStyle(
                color: Color(0xFF9C7649),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            if (pet['isLost'] == true)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'LOST',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF9C7649),
          size: 16,
        ),
        onTap: () async {
          // Navigate to pet profile screen for editing
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetDetailsScreen(
                pet: pet,
                onPetStatusChanged: () {
                  // Refresh the pets list when status changes
                  _loadUserPets();
                },
              ),
            ),
          );
          // Refresh the pets list when returning from pet profile screen
          _loadUserPets();
        },
      ),
    );
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
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFF1C150D),
                                fontSize: 16,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUserPets,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1C150D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : Column(
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

                          GestureDetector(
                            onTap: () async {
                              // Navigate to Pet Profile Screen
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PetProfileScreen(),
                                ),
                              );
                              // Refresh the pets list when returning from pet profile screen
                              _loadUserPets();
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

                          // Pets list
                          Expanded(
                            child: _pets.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.pets,
                                          size: 64,
                                          color: Color(0xFF9C7649),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No pets found',
                                          style: TextStyle(
                                            color: Color(0xFF1C150D),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add your first pet to get started',
                                          style: TextStyle(
                                            color: Color(0xFF9C7649),
                                            fontSize: 14,
                                            fontFamily: 'Plus Jakarta Sans',
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _pets.length,
                                    itemBuilder: (context, index) {
                                      return _buildPetCard(_pets[index]);
                                    },
                                  ),
                          ),
                        ],
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
