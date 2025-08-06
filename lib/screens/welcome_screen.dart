// this screen is used to display the welcome screen of the app which is the first screen that the user sees

import 'package:flutter/material.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero Image Section
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      height: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage(
                            "https://lh3.googleusercontent.com/aida-public/AB6AXuCJNnau4aCwzu3DqHCnWuADL9F2ogtW-mebvn47Es7P5LF3K_noYwiMLGLqmVn7Zz_L0UoSR4U-J4g3Q8BJdgPkiA4yvfBDu4_p_8N5TtCIp00MwznmMXiNvJiUysPMktgciQxeQDIBRjXPOhqlz_g4-I7IZRT51BgjnbnbbjYqB5-W0cu1TwtSffaAtZJyYyAf5EryiZ-7pkK1zsJMo4phKmjYtTtACRckfknAKRbgRBwi7qufchf4DHrxbZ3ZTYrCxwxdvrxc-g",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Title Section
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Text(
                        'Find Your Lost Pet Quickly and Safely',
                        style: TextStyle(
                          color: Color(0xFF1C150D),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Features List
                    _buildFeatureItem(
                      icon: Icons.location_on,
                      title: 'Real-Time Tracking',
                      description:
                          'Track your pet\'s location in real-time with our advanced GPS technology.',
                    ),

                    _buildFeatureItem(
                      icon: Icons.devices,
                      title: 'Live Map Network',
                      description:
                          'Join our network of users to expand your search area and increase your chances of finding your pet.',
                    ),

                    _buildFeatureItem(
                      icon: Icons.qr_code,
                      title: 'QR Code Integration',
                      description:
                          'Use our QR code tags to easily identify your pet and provide contact information to finders.',
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Section with Button
            Container(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle get started action
                    print('Get Started pressed');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF810B),
                    foregroundColor: const Color(0xFF1C150D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.015,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF4EDE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1C150D),
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1C150D),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF9C7449),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example usage in main.dart or app.dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily:
            'Plus Jakarta Sans', // You can add this font to pubspec.yaml
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
