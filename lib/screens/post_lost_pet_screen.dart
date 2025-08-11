import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'home_screen.dart';
import 'post_found_pet_screen.dart';
import 'profile_screen.dart'; // Added import for ProfileScreen
import 'package:image_picker/image_picker.dart';
import '../services/pet_service.dart';
import '../services/session_service.dart';
import 'dart:io';

class PostLostPetScreen extends StatefulWidget {
  const PostLostPetScreen({super.key});

  @override
  State<PostLostPetScreen> createState() => _PostLostPetScreenState();
}

class _PostLostPetScreenState extends State<PostLostPetScreen> {
  // State variables for dropdowns and navigation
  String? _selectedPetType;
  String? _selectedBreed;
  String? _selectedGender;
  String? _selectedCollarColor;
  int _bottomNavIndex = 1; // 'Post Lost' is initially selected
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _pickedPhotos = [];
  bool _isPosting = false;

  // Form controllers
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _lastKnownLocationController =
      TextEditingController();

  // --- Style Constants ---
  // Extracted from the CSS for easy reuse and maintenance
  static const Color bgColor = Color(0xFFFCFAF8);
  static const Color primaryTextColor = Color(0xFF1C150D);
  static const Color secondaryTextColor = Color(0xFF9C7649);
  static const Color inputBgColor = Color(0xFFF4EEE7);
  static const Color primaryButtonColor = Color(0xFFF2870C);
  static const Color borderColor = Color(0xFFF4EEE7);
  static const Color dashedBorderColor = Color(0xFFE8DCCE);

  void _onNavigationTap(int index) {
    setState(() {
      _bottomNavIndex = index;
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
        // Already on post lost screen, no navigation needed
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

  @override
  Widget build(BuildContext context) {
    // Using GoogleFonts requires the google_fonts package
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      Theme.of(context).textTheme,
    );

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          // The back arrow icon
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: primaryTextColor,
              size: 24,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          // The title "Post Lost"
          title: Text(
            'Post Lost',
            style: textTheme.titleLarge?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          // This empty container ensures the title is perfectly centered
          // as the leading icon takes up space.
          actions: const [SizedBox(width: 56)],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Form Fields ---
                _buildTextField(
                  label: 'Pet Name',
                  hint: 'Enter pet name',
                  controller: _petNameController,
                ),
                _buildDropdownField(
                  label: 'Pet Type',
                  hint: 'Select pet type',
                  value: _selectedPetType,
                  items: ['Dog', 'Cat', 'Bird', 'Other'],
                  onChanged: (value) =>
                      setState(() => _selectedPetType = value),
                ),
                _buildDropdownField(
                  label: 'Breed',
                  hint: 'Select breed',
                  value: _selectedBreed,
                  items: ['Golden Retriever', 'Poodle', 'Siamese', 'Other'],
                  onChanged: (value) => setState(() => _selectedBreed = value),
                ),

                _buildDropdownField(
                  label: 'Gender',
                  hint: 'Select Gender',
                  value: _selectedGender,
                  items: ['Male', 'Female'],
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                _buildDropdownField(
                  label: 'Color',
                  hint: 'Select collar color',
                  value: _selectedCollarColor,
                  items: [
                    'Black',
                    'White',
                    'Brown',
                    'Golden',
                    'Gray',
                    'Orange',
                    'Cream',
                    'Multi-colored',
                    'Other'
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedCollarColor = value),
                ),
                _buildTextField(
                  label: 'Last Known Location',
                  hint: 'Enter last known location',
                  controller: _lastKnownLocationController,
                ),

                // --- Photo Upload Section ---
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    'Photos',
                    style: textTheme.titleLarge?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildPhotoUploader(),

                const SizedBox(height: 24), // Spacer before the button
                // --- Post Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPosting ? null : _postLostPet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      foregroundColor: primaryTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      textStyle: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isPosting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Post Lost Pet'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: bgColor,
            border: Border(top: BorderSide(color: borderColor, width: 1.0)),
          ),
          child: BottomNavigationBar(
            currentIndex: _bottomNavIndex,
            onTap: _onNavigationTap,
            backgroundColor: bgColor,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: primaryTextColor,
            unselectedItemColor: secondaryTextColor,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            elevation: 0,
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
      ),
    );
  }

  // A reusable widget for text fields to avoid code duplication
  Widget _buildTextField({
    required String label,
    required String hint,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: secondaryTextColor,
                fontSize: 16,
              ),
              filled: true,
              fillColor: inputBgColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(color: primaryTextColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Updated modern card-style dropdown field widget
  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: value != null ? 4 : 2,
          shadowColor: value != null
              ? primaryButtonColor.withOpacity(0.2)
              : Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: value != null
                    ? primaryButtonColor.withOpacity(0.3)
                    : borderColor.withOpacity(0.5),
                width: value != null ? 2.0 : 1.0,
              ),
              gradient: value != null
                  ? LinearGradient(
                      colors: [
                        Colors.white,
                        primaryButtonColor.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (value != null)
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: primaryButtonColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        margin: const EdgeInsets.only(right: 8),
                      ),
                    Text(
                      label,
                      style: TextStyle(
                        color: value != null
                            ? primaryButtonColor
                            : primaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: value != null
                          ? primaryButtonColor.withOpacity(0.2)
                          : Colors.transparent,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: value,
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            item,
                            style: const TextStyle(
                              color: primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: secondaryTextColor.withOpacity(0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: value != null
                            ? primaryButtonColor.withOpacity(0.15)
                            : secondaryTextColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: value != null
                            ? primaryButtonColor
                            : secondaryTextColor,
                        size: 20,
                      ),
                    ),
                    style: const TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    menuMaxHeight: 240,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for the dashed border photo uploader
  Widget _buildPhotoUploader() {
    return DottedBorder(
      color: dashedBorderColor,
      strokeWidth: 2,
      dashPattern: const [6, 6],
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        width: double.infinity,
        child: Column(
          children: [
            Text(
              'Upload Photos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add photos of your pet to help identify them.',
              textAlign: TextAlign.center,
              style: TextStyle(color: primaryTextColor, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                final photos = await _picker.pickMultiImage(imageQuality: 85);
                if (photos.isNotEmpty) {
                  setState(() {
                    _pickedPhotos
                      ..clear()
                      ..addAll(photos);
                  });
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: inputBgColor,
                foregroundColor: primaryTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Upload',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (_pickedPhotos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pickedPhotos
                    .map((x) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(x.path),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ))
                    .toList(),
              )
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _postLostPet() async {
    if (_selectedPetType == null ||
        _selectedBreed == null ||
        _selectedGender == null ||
        _petNameController.text.trim().isEmpty ||
        _lastKnownLocationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please complete all required fields'),
          backgroundColor: Colors.red));
      return;
    }
    setState(() => _isPosting = true);
    try {
      final ownerId = await SessionService().getBackendUserId();
      if (ownerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please login first'), backgroundColor: Colors.red));
        return;
      }
      final petService = PetService();
      // Create pet with actual form data
      final created = await petService.createPet(
        petName: _petNameController.text.trim(),
        petType: _selectedPetType!,
        breed: _selectedBreed!,
        gender: _selectedGender!,
        color: _selectedCollarColor ?? 'Other',
        homeLocation: _lastKnownLocationController.text.trim(),
        ownerId: ownerId,
      );
      final petId = (created['data'] as Map)['_id'] as String;
      if (_pickedPhotos.isNotEmpty) {
        await petService.uploadAdditionalPhotos(
          petId: petId,
          files: _pickedPhotos.map((x) => File(x.path)).toList(),
        );
      }
      // Mark as lost
      await petService.markLost(petId);
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Lost pet posted successfully'),
          backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _lastKnownLocationController.dispose();
    super.dispose();
  }
}
