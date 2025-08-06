// This screen is used to add a pet profile to the database ie to add a new pet to the database

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'home_screen.dart';
import 'post_lost_pet_screen.dart';
import 'post_found_pet_screen.dart';
import 'profile_screen.dart'; // Added import for ProfileScreen

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  // Text controllers for form fields
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _homeLocationController = TextEditingController();

  // State variables for dropdowns
  String? _selectedPetType;
  String? _selectedBreed;
  String? _selectedColor;
  int _bottomNavIndex = 4; // Profile is selected

  // --- Style Constants ---
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
  void dispose() {
    _petNameController.dispose();
    _homeLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(
            'Pet Profile',
            style: textTheme.titleLarge?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: const [SizedBox(width: 56)],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Pet Profile Image Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: inputBgColor,
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: ClipOval(
                          child: Stack(
                            children: [
                              // Placeholder pet image
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: inputBgColor,
                                child: const Icon(
                                  Icons.pets,
                                  size: 48,
                                  color: secondaryTextColor,
                                ),
                              ),
                              // Camera overlay
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: primaryButtonColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement image picker
                        },
                        child: Text(
                          'Change Photo',
                          style: textTheme.bodyMedium?.copyWith(
                            color: primaryButtonColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Pet Information Section
                Text(
                  'Pet Information',
                  style: textTheme.titleLarge?.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Form Fields
                _buildTextField(
                  label: 'Pet Name',
                  hint: 'Enter your pet\'s name',
                  controller: _petNameController,
                ),

                _buildDropdownField(
                  label: 'Pet Type',
                  hint: 'Select pet type',
                  value: _selectedPetType,
                  items: [
                    'Dog',
                    'Cat',
                    'Rabbit',
                    'Hamster',
                    'Guinea Pig',
                    'Bird',
                    'Other',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPetType = value;
                      // Reset breed when pet type changes
                      _selectedBreed = null;
                    });
                  },
                ),

                _buildDropdownField(
                  label: 'Breed',
                  hint: 'Select breed',
                  value: _selectedBreed,
                  items: _getBreedOptions(),
                  onChanged: (value) => setState(() => _selectedBreed = value),
                ),

                _buildDropdownField(
                  label: 'Color',
                  hint: 'Select primary color',
                  value: _selectedColor,
                  items: [
                    'Black',
                    'White',
                    'Brown',
                    'Golden',
                    'Gray',
                    'Orange',
                    'Cream',
                    'Multi-colored',
                    'Other',
                  ],
                  onChanged: (value) => setState(() => _selectedColor = value),
                ),

                _buildTextField(
                  label: 'Default Home Location',
                  hint: 'Enter your home address',
                  controller: _homeLocationController,
                ),
                _buildPhotoUploader(),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _savePetProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      textStyle: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Add My Pet'),
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
              onPressed: () {
                // TODO: Implement image picking logic
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
          ],
        ),
      ),
    );
  }

  // Get breed options based on selected pet type
  List<String> _getBreedOptions() {
    switch (_selectedPetType) {
      case 'Dog':
        return [
          'Golden Retriever',
          'Labrador Retriever',
          'German Shepherd',
          'Bulldog',
          'Poodle',
          'Beagle',
          'Rottweiler',
          'Yorkshire Terrier',
          'Mixed Breed',
          'Other',
        ];
      case 'Cat':
        return [
          'Persian',
          'Siamese',
          'Maine Coon',
          'British Shorthair',
          'Ragdoll',
          'Bengal',
          'Abyssinian',
          'Russian Blue',
          'Mixed Breed',
          'Other',
        ];
      case 'Hamster':
        return [
          "Syrian (Golden Hamster)",
          "Dwarf Campbell Russian",
          "Dwarf Winter White Russian",
          "Roborovski Dwarf",
          "Chinese",
        ];
      case 'Guinea Pig':
        return [
          "American",
          "Abyssinian",
          "Peruvian",
          "Silkie (Sheltie)",
          "Teddy",
          "Texel",
          "Skinny Pig",
        ];
      case 'Bird':
        return [
          'Parrot',
          'Canary',
          'Budgie',
          'Cockatiel',
          'Finch',
          'Lovebird',
          'Other',
        ];
      case 'Rabbit':
        return [
          'Holland Lop',
          'Netherland Dwarf',
          'Lionhead',
          'Mini Rex',
          'Flemish Giant',
          'Other',
        ];
      default:
        return ['Mixed Breed', 'Other'];
    }
  }

  // Save pet profile logic
  void _savePetProfile() {
    if (_petNameController.text.isEmpty) {
      _showErrorSnackBar('Please enter your pet\'s name');
      return;
    }

    if (_selectedPetType == null) {
      _showErrorSnackBar('Please select a pet type');
      return;
    }

    // TODO: Implement actual save logic (database, API, etc.)
    _showSuccessSnackBar('Pet profile saved successfully!');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // Reusable text field widget
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
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
}
