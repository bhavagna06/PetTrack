// pet_details_screen.dart
// New screen: PetDetailsScreen and PetDetailsWidget
// This re-uses the visual layout from `my_pet_screen.dart` but reads from a passed `pet` Map.
// Place this file next to your other screens (same folder as pets_screen.dart).

import 'package:flutter/material.dart';
import 'pet_profile_screen.dart';
import '../services/pet_service.dart';

class PetDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> pet;
  final VoidCallback? onPetStatusChanged; // Add callback for status changes
  const PetDetailsScreen({Key? key, required this.pet, this.onPetStatusChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      body: SafeArea(
        child:
            PetDetailsWidget(pet: pet, onPetStatusChanged: onPetStatusChanged),
      ),
    );
  }
}

class PetDetailsWidget extends StatefulWidget {
  final Map<String, dynamic> pet;
  final VoidCallback? onPetStatusChanged; // Add callback for status changes
  const PetDetailsWidget({Key? key, required this.pet, this.onPetStatusChanged})
      : super(key: key);

  @override
  State<PetDetailsWidget> createState() => _PetDetailsWidgetState();
}

class _PetDetailsWidgetState extends State<PetDetailsWidget> {
  final PetService _petService = PetService();
  bool _isUpdatingStatus = false;

  Future<void> _markPetAsLost() async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await _petService.markPetAsLost(widget.pet['_id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet marked as lost successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        // Update the local pet data
        setState(() {
          widget.pet['isLost'] = true;
          widget.pet['isFound'] = false;
        });
        widget.onPetStatusChanged?.call(); // Call the callback
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark pet as lost: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _markPetAsFound() async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await _petService.markPetAsFound(widget.pet['_id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet marked as found successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Update the local pet data
        setState(() {
          widget.pet['isFound'] = true;
          widget.pet['isLost'] = false;
        });
        widget.onPetStatusChanged?.call(); // Call the callback
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark pet as found: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

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
    final name = widget.pet['petName'] ?? 'Unknown Pet';
    final profileImage = widget.pet['profileImage'] as String?;
    final petType = widget.pet['petType'] ?? 'Unknown';
    final breed = widget.pet['breed'] ?? 'Unknown breed';
    final color = widget.pet['color'] ?? 'Unknown';
    // final age = widget.pet['age']?.toString() ?? 'Unknown';
    final gender = widget.pet['gender'] ?? 'Unknown';
    // final isVaccinated = widget.pet['isVaccinated'] == true ? 'Yes' : 'No';
    final description = widget.pet['description'] ?? '';
    final address = widget.pet['address'] ?? 'No address provided';
    final isLost = widget.pet['isLost'] == true;

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
                            PetProfileScreen(petId: widget.pet['_id']),
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

                // Report Lost button
                GestureDetector(
                  onTap: _markPetAsLost,
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
                            Icons.warning_amber_outlined,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Report Lost',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                        if (_isUpdatingStatus)
                          const SizedBox(
                              width: 16,
                              child:
                                  CircularProgressIndicator(color: Colors.red)),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.red, size: 16),
                      ],
                    ),
                  ),
                ),

                // Report Found button
                GestureDetector(
                  onTap: _markPetAsFound,
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
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Report Found',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                        if (_isUpdatingStatus)
                          const SizedBox(
                              width: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.green)),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.green, size: 16),
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
