import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'home_screen.dart';
import 'post_found_pet_screen.dart';
import 'profile_screen.dart'; // Added import for ProfileScreen

class PostLostPetScreen extends StatefulWidget {
  const PostLostPetScreen({super.key});

  @override
  State<PostLostPetScreen> createState() => _PostLostPetScreenState();
}

class _PostLostPetScreenState extends State<PostLostPetScreen> {
  // State variables for dropdowns and navigation
  String? _selectedPetType;
  String? _selectedBreed;
  String? _selectedAge;
  String? _selectedSize;
  String? _selectedCollarColor;
  int _bottomNavIndex = 1; // 'Post Lost' is initially selected

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
                _buildTextField(label: 'Pet Name', hint: 'Enter pet name'),
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
                  label: 'Age',
                  hint: 'Select age',
                  value: _selectedAge,
                  items: ['Puppy', 'Adult', 'Senior'],
                  onChanged: (value) => setState(() => _selectedAge = value),
                ),
                _buildDropdownField(
                  label: 'Size',
                  hint: 'Select size',
                  value: _selectedSize,
                  items: ['Small', 'Medium', 'Large'],
                  onChanged: (value) => setState(() => _selectedSize = value),
                ),
                _buildDropdownField(
                  label: 'Collar Color',
                  hint: 'Select collar color',
                  value: _selectedCollarColor,
                  items: ['Red', 'Blue', 'Black', 'None'],
                  onChanged: (value) =>
                      setState(() => _selectedCollarColor = value),
                ),
                _buildTextField(
                  label: 'Last Known Location',
                  hint: 'Enter last known location',
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
                    onPressed: () {
                      // TODO: Implement post logic
                    },
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
                    child: const Text('Post Lost Pet'),
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
  Widget _buildTextField({required String label, required String hint}) {
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

  // A reusable widget for dropdowns
  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
          DropdownButtonFormField<String>(
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
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
            icon: const Icon(Icons.unfold_more, color: secondaryTextColor),
            style: const TextStyle(color: primaryTextColor, fontSize: 16),
            dropdownColor: inputBgColor,
          ),
        ],
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
}
