import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick multiple images from gallery
  Future<List<File>> pickMultipleImagesFromGallery({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (images.isNotEmpty) {
        // Limit the number of images
        final limitedImages = images.take(maxImages).toList();
        return limitedImages.map((image) => File(image.path)).toList();
      }
      return [];
    } catch (e) {
      print('Error picking multiple images from gallery: $e');
      return [];
    }
  }

  // Upload single image to Firebase Storage
  Future<String?> uploadImageToFirebase({
    required File imageFile,
    required String folder,
    String? customFileName,
  }) async {
    try {
      // Generate unique filename
      final String fileName = customFileName ?? 
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      
      // Create reference to Firebase Storage
      final Reference ref = _storage.ref().child('$folder/$fileName');
      
      // Upload file
      final UploadTask uploadTask = ref.putFile(imageFile);
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Firebase: $e');
      return null;
    }
  }

  // Upload multiple images to Firebase Storage
  Future<List<String>> uploadMultipleImagesToFirebase({
    required List<File> imageFiles,
    required String folder,
  }) async {
    try {
      final List<String> downloadUrls = [];
      
      for (final File imageFile in imageFiles) {
        final String? downloadUrl = await uploadImageToFirebase(
          imageFile: imageFile,
          folder: folder,
        );
        
        if (downloadUrl != null) {
          downloadUrls.add(downloadUrl);
        }
      }
      
      return downloadUrls;
    } catch (e) {
      print('Error uploading multiple images to Firebase: $e');
      return [];
    }
  }

  // Delete image from Firebase Storage
  Future<bool> deleteImageFromFirebase(String imageUrl) async {
    try {
      // Extract the file path from the URL
      final Uri uri = Uri.parse(imageUrl);
      final String path = uri.pathSegments.join('/');
      
      // Create reference and delete
      final Reference ref = _storage.ref().child(path);
      await ref.delete();
      
      return true;
    } catch (e) {
      print('Error deleting image from Firebase: $e');
      return false;
    }
  }

  // Show image picker dialog (camera or gallery)
  Future<File?> showImagePickerDialog() async {
    // This method can be used to show a dialog with options
    // For now, we'll return null as the UI will handle the choice
    return null;
  }

  // Get image size in MB
  double getImageSizeInMB(File imageFile) {
    try {
      final int bytes = imageFile.lengthSync();
      return bytes / (1024 * 1024); // Convert to MB
    } catch (e) {
      print('Error getting image size: $e');
      return 0.0;
    }
  }

  // Validate image file
  bool isValidImageFile(File imageFile) {
    try {
      final double sizeInMB = getImageSizeInMB(imageFile);
      final String extension = imageFile.path.split('.').last.toLowerCase();
      
      // Check file size (max 10MB)
      if (sizeInMB > 10) {
        return false;
      }
      
      // Check file extension
      final List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!allowedExtensions.contains(extension)) {
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error validating image file: $e');
      return false;
    }
  }
}
