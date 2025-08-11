import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../widgets/image_picker_widget.dart';

class ImageDemoScreen extends StatefulWidget {
  const ImageDemoScreen({Key? key}) : super(key: key);

  @override
  State<ImageDemoScreen> createState() => _ImageDemoScreenState();
}

class _ImageDemoScreenState extends State<ImageDemoScreen> {
  final ImageService _imageService = ImageService();
  List<File> _selectedImages = [];
  bool _isUploading = false;
  List<String> _uploadedUrls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      appBar: AppBar(
        title: const Text(
          'Image Demo',
          style: TextStyle(
            color: Color(0xFF1C150D),
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFCFAF8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1C150D)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Single Image Picker
            const Text(
              'Single Image Selection',
              style: TextStyle(
                color: Color(0xFF1C150D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 12),
            ImagePickerWidget(
              onImageSelected: (File image) {
                setState(() {
                  _selectedImages.clear();
                  _selectedImages.add(image);
                });
              },
              title: 'Select Single Image',
              subtitle: 'Camera or Gallery',
              allowMultiple: false,
            ),
            const SizedBox(height: 24),

            // Multiple Image Picker
            const Text(
              'Multiple Image Selection',
              style: TextStyle(
                color: Color(0xFF1C150D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 12),
            ImagePickerWidget(
              onImageSelected: (File image) {
                setState(() {
                  if (_selectedImages.length < 5) {
                    _selectedImages.add(image);
                  }
                });
              },
              title: 'Select Multiple Images',
              subtitle: 'Up to 5 images',
              allowMultiple: true,
              maxImages: 5,
            ),
            const SizedBox(height: 24),

            // Selected Images Display
            if (_selectedImages.isNotEmpty) ...[
              const Text(
                'Selected Images',
                style: TextStyle(
                  color: Color(0xFF1C150D),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 12),
              SelectedImagesWidget(
                images: _selectedImages,
                onRemoveImage: (File image) {
                  setState(() {
                    _selectedImages.remove(image);
                  });
                },
                height: 120,
              ),
              const SizedBox(height: 24),

              // Upload Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2870C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isUploading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Uploading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Upload to Firebase Storage',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                ),
              ),
            ],

            // Uploaded URLs Display
            if (_uploadedUrls.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Uploaded URLs',
                style: TextStyle(
                  color: Color(0xFF1C150D),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 12),
              ..._uploadedUrls
                  .map((url) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4EEE7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF9C7649).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Firebase Storage URL:',
                              style: TextStyle(
                                color: Color(0xFF1C150D),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              url,
                              style: const TextStyle(
                                color: Color(0xFF9C7649),
                                fontSize: 10,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],

            const SizedBox(height: 24),

            // Image Service Features
            const Text(
              'Image Service Features',
              style: TextStyle(
                color: Color(0xFF1C150D),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: Icons.camera_alt,
              title: 'Camera Capture',
              description: 'Take photos directly with device camera',
            ),
            const SizedBox(height: 8),
            _buildFeatureCard(
              icon: Icons.photo_library,
              title: 'Gallery Selection',
              description: 'Pick images from device gallery',
            ),
            const SizedBox(height: 8),
            _buildFeatureCard(
              icon: Icons.cloud_upload,
              title: 'Firebase Storage',
              description: 'Upload images to Firebase Storage',
            ),
            const SizedBox(height: 8),
            _buildFeatureCard(
              icon: Icons.image,
              title: 'Image Validation',
              description: 'Validate file size and format',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEE7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF9C7649).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF9C7649).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF9C7649),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
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
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: const Color(0xFF1C150D).withOpacity(0.7),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final List<String> urls =
          await _imageService.uploadMultipleImagesToFirebase(
        imageFiles: _selectedImages,
        folder: 'demo',
      );

      setState(() {
        _uploadedUrls.addAll(urls);
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully uploaded ${urls.length} image(s)',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error uploading images: $e',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
