// this screen is used to display the home screen of the app which display all the lost and found pets

import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'post_lost_pet_screen.dart';
import 'post_found_pet_screen.dart';
import 'pet_details_screen.dart';
import '../services/pet_service.dart';

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
  List<Map<String, dynamic>> _lostPets = [];
  List<Map<String, dynamic>> _foundPets = [];
  bool _isLoading = true;
  String? _error;
  final PetService _petService = PetService();

  final List<String> _searchCategories = [
    'All',
    'Dog',
    'Cat',
    'Bird',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Load lost pets (both reported pets and registered pets marked as lost)
      final lostPets = await _petService.fetchPets(
        isLost: true,
        // Remove registrationType filter to include both reported and registered pets
      );
      // Load found pets (both reported pets and registered pets marked as found)
      final foundPets = await _petService.fetchPets(
        isFound: true,
        // Remove registrationType filter to include both reported and registered pets
      );

      setState(() {
        _lostPets = lostPets;
        _foundPets = foundPets;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get filteredLostPets {
    if (_searchController.text.isEmpty && _selectedSearchCategory == 'All') {
      return _lostPets;
    }
    return _lostPets.where((pet) {
      final type = (pet['petType'] ?? '').toString().toLowerCase();
      final name = (pet['petName'] ?? '').toString().toLowerCase();
      bool matchesCategory = _selectedSearchCategory == 'All' ||
          type.contains(_selectedSearchCategory.toLowerCase());
      bool matchesName = _searchController.text.isEmpty ||
          name.contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesName;
    }).toList();
  }

  List<Map<String, dynamic>> get filteredFoundPets {
    if (_searchController.text.isEmpty && _selectedSearchCategory == 'All') {
      return _foundPets;
    }
    return _foundPets.where((pet) {
      final type = (pet['petType'] ?? '').toString().toLowerCase();
      final name = (pet['petName'] ?? '').toString().toLowerCase();
      bool matchesCategory = _selectedSearchCategory == 'All' ||
          type.contains(_selectedSearchCategory.toLowerCase());
      bool matchesName = _searchController.text.isEmpty ||
          name.contains(_searchController.text.toLowerCase());
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
        ).then((_) => _loadPets()); // Refresh pets when returning
        break;
      case 2: // Post Found
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PostFoundPetScreen(),
          ),
        ).then((_) => _loadPets()); // Refresh pets when returning
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
                              hintText: 'Search for pets by name...',
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

            // Content Area
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadPets,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_error != null
                        ? Center(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        : _buildContent()),
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

  Widget _buildContent() {
    final hasSearchResults =
        _searchController.text.isNotEmpty || _selectedSearchCategory != 'All';

    if (hasSearchResults) {
      final allResults = [...filteredLostPets, ...filteredFoundPets];
      return _buildSearchResults(allResults);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Lost Pets Section
          _buildLostPetsSection(),

          const SizedBox(height: 24),

          // Found Pets Section
          _buildFoundPetsSection(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    return Column(
      children: [
        // Search Results Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Results (${results.length})',
                style: const TextStyle(
                  color: Color(0xFF1C150D),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015,
                ),
              ),
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

        // Search Results List
        results.isEmpty
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
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final pet = results[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildPetCard(pet),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildLostPetsSection() {
    return Column(
      children: [
        // Lost Pets Title
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Lost Pets',
                style: TextStyle(
                  color: Color(0xFF1C150D),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015,
                ),
              ),
            ],
          ),
        ),

        // Lost Pets List
        filteredLostPets.isEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 48,
                        color: Color(0xFF9C7649),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No lost pets reported',
                        style: TextStyle(
                          color: Color(0xFF9C7649),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredLostPets.length,
                itemBuilder: (context, index) {
                  final pet = filteredLostPets[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildPetCard(pet),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildFoundPetsSection() {
    return Column(
      children: [
        // Found Pets Title
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Found Pets',
                style: TextStyle(
                  color: Color(0xFF1C150D),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.015,
                ),
              ),
            ],
          ),
        ),

        // Found Pets List
        filteredFoundPets.isEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 48,
                        color: Color(0xFF9C7649),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No found pets reported',
                        style: TextStyle(
                          color: Color(0xFF9C7649),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredFoundPets.length,
                itemBuilder: (context, index) {
                  final pet = filteredFoundPets[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _buildPetCard(pet),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    final name = pet['petName']?.toString() ?? 'Unknown Pet';
    final type = pet['petType']?.toString() ?? 'Unknown Type';
    final breed = pet['breed']?.toString() ?? 'Unknown Breed';
    final gender = pet['gender']?.toString() ?? 'Unknown Gender';
    final description = '$breed • ${pet['color'] ?? 'Unknown Color'}';
    final imageUrl = pet['profileImage']?.toString() ?? '';
    final isLost = pet['isLost'] == true;
    final isFound = pet['isFound'] == true;
    final registrationType =
        pet['registrationType']?.toString() ?? 'registered';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailsScreen(
              pet: pet,
              onPetStatusChanged: () {
                // Refresh the pets list when status changes
                _loadPets();
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFF4EEE7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pet Information
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                          color: Color(0xFF9C7649),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isLost)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LOST',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isFound)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'FOUND',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        gender,
                        style: const TextStyle(
                          color: Color(0xFF9C7649),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Registration type indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: registrationType == 'registered'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          registrationType == 'registered'
                              ? 'REGISTERED'
                              : 'REPORTED',
                          style: TextStyle(
                            color: registrationType == 'registered'
                                ? Colors.blue
                                : Colors.orange,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
                  color: const Color(0xFFF4EEE7),
                ),
                child: imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.pets,
                              size: 32,
                              color: Color(0xFF9C7649),
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.pets,
                        size: 32,
                        color: Color(0xFF9C7649),
                      ),
              ),
            ),
          ],
        ),
      ),
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
