import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_service.dart';

class ImagePickerWidget extends StatelessWidget {
  final Function(File) onImageSelected;
  final String title;
  final String? subtitle;
  final bool allowMultiple;
  final int maxImages;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const ImagePickerWidget({
    Key? key,
    required this.onImageSelected,
    this.title = 'Select Image',
    this.subtitle,
    this.allowMultiple = false,
    this.maxImages = 5,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImageService imageService = ImageService();
    final Color bgColor = backgroundColor ?? const Color(0xFFF4EEE7);
    final Color txtColor = textColor ?? const Color(0xFF1C150D);

    return GestureDetector(
      onTap: () => _showImagePickerDialog(context, imageService),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 120,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF9C7649).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.add_a_photo_outlined,
              size: 32,
              color: txtColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: txtColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  color: txtColor.withOpacity(0.7),
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context, ImageService imageService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFCFAF8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C7649).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Select Image',
                style: TextStyle(
                  color: const Color(0xFF1C150D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),

              const SizedBox(height: 20),

              // Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Camera option
                    _buildOptionTile(
                      context,
                      icon: Icons.camera_alt_outlined,
                      title: 'Take Photo',
                      subtitle: 'Use camera to capture image',
                      onTap: () async {
                        Navigator.pop(context);
                        final File? image =
                            await imageService.pickImageFromCamera();
                        if (image != null) {
                          onImageSelected(image);
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // Gallery option
                    _buildOptionTile(
                      context,
                      icon: Icons.photo_library_outlined,
                      title: allowMultiple ? 'Choose Photos' : 'Choose Photo',
                      subtitle: allowMultiple
                          ? 'Select multiple images from gallery'
                          : 'Select image from gallery',
                      onTap: () async {
                        Navigator.pop(context);
                        if (allowMultiple) {
                          final List<File> images =
                              await imageService.pickMultipleImagesFromGallery(
                            maxImages: maxImages,
                          );
                          for (final File image in images) {
                            onImageSelected(image);
                          }
                        } else {
                          final File? image =
                              await imageService.pickImageFromGallery();
                          if (image != null) {
                            onImageSelected(image);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Cancel button
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: const Color(0xFF9C7649),
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EEE7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF9C7649).withOpacity(0.2),
            width: 1,
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF1C150D).withOpacity(0.7),
                      fontSize: 12,
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
    );
  }
}

// Widget for displaying selected images
class SelectedImagesWidget extends StatelessWidget {
  final List<File> images;
  final Function(File) onRemoveImage;
  final double? width;
  final double? height;

  const SelectedImagesWidget({
    Key? key,
    required this.images,
    required this.onRemoveImage,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: width ?? double.infinity,
      height: height ?? 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    images[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onRemoveImage(images[index]),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
