// pet_details_screen.dart
// New screen: PetDetailsScreen and PetDetailsWidget
// This re-uses the visual layout from `my_pet_screen.dart` but reads from a passed `pet` Map.
// Place this file next to your other screens (same folder as pets_screen.dart).

import 'package:flutter/material.dart';
import 'pet_profile_screen.dart';

class PetDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> pet;
  const PetDetailsScreen({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      body: SafeArea(
        child: PetDetailsWidget(pet: pet),
      ),
    );
  }
}

class PetDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> pet;
  const PetDetailsWidget({Key? key, required this.pet}) : super(key: key);

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF4EEE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1C150D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      color: Color(0xFF1C150D),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Plus Jakarta Sans',
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      color: Color(0xFF9C7649),
                      fontSize: 14,
                      fontFamily: 'Plus Jakarta Sans',
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = pet['petName'] ?? 'Unknown Pet';
    final profileImage = pet['profileImage'] as String?;
    final petType = pet['petType'] ?? 'Unknown';
    final breed = pet['breed'] ?? 'Unknown breed';
    final color = pet['color'] ?? 'Unknown';
    // final age = pet['age']?.toString() ?? 'Unknown';
    final gender = pet['gender'] ?? 'Unknown';
    // final isVaccinated = pet['isVaccinated'] == true ? 'Yes' : 'No';
    final description = pet['description'] ?? '';
    final address = pet['address'] ?? 'No address provided';
    final isLost = pet['isLost'] == true;

    return Column(
      children: [
        // Header with back button
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: const Icon(Icons.arrow_back, color: Color(0xFF1C150D)),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Pet Details',
                    style: TextStyle(
                      color: Color(0xFF1C150D),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ),
              Container(width: 48, height: 48), // placeholder to center title
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                              child: profileImage != null &&
                                      profileImage.isNotEmpty
                                  ? Image.network(profileImage,
                                      fit: BoxFit.cover,
                                      width: 128,
                                      height: 128,
                                      errorBuilder: (context, error, stack) {
                                      return const Icon(Icons.pets,
                                          size: 56, color: Color(0xFF9C7649));
                                    })
                                  : const Icon(Icons.pets,
                                      size: 56, color: Color(0xFF9C7649)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Color(0xFF1C150D),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isLost)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
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
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF9C7649),
                                fontSize: 14,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ],
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

                _infoRow(Icons.pets, 'Type', '$petType • $breed'),
                _infoRow(Icons.palette_outlined, 'Color', color),
                // _infoRow(Icons.calendar_today, 'Age', age),
                _infoRow(Icons.male, 'Gender', gender),
                // _infoRow(Icons.health_and_safety, 'Vaccinated', isVaccinated),

                // Location / Owner info
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Location',
                    style: TextStyle(
                      color: Color(0xFF1C150D),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
                _infoRow(Icons.location_on, 'Home Location', address),

                // Pet Actions section (partial parity with My Pet screen)
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
                    // Navigate to existing PetProfileScreen for editing (keeps original functionality)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PetProfileScreen(petId: pet['_id']),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                        const Icon(Icons.arrow_forward_ios,
                            color: Color(0xFF9C7649), size: 16),
                      ],
                    ),
                  ),
                ),

                // Pet Photos (UI only, keep consistent with My Pet)
                GestureDetector(
                  onTap: () {
                    // You can wire this to your photos viewer if you have one.
                    // For now keep it as a placeholder to match the My Pet screen UI.
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                        const Icon(Icons.arrow_forward_ios,
                            color: Color(0xFF9C7649), size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
