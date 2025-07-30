import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Upload user profile image
  Future<String?> uploadUserProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile/profile.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading user profile image: $e');
      return null;
    }
  }

  // Upload pet image
  Future<String?> uploadPetImage({
    required String petId,
    required File imageFile,
    String? imageName,
  }) async {
    try {
      final fileName =
          imageName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('pets/$petId/images/$fileName');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading pet image: $e');
      return null;
    }
  }

  // Upload report image (lost/found)
  Future<String?> uploadReportImage({
    required String reportId,
    required File imageFile,
    String? imageName,
  }) async {
    try {
      final fileName =
          imageName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('reports/$reportId/images/$fileName');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading report image: $e');
      return null;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required String collection,
    required String documentId,
    required List<File> imageFiles,
    String? subfolder,
  }) async {
    try {
      List<String> downloadUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final storagePath = subfolder != null
            ? '$collection/$documentId/$subfolder/$fileName'
            : '$collection/$documentId/images/$fileName';

        final ref = _storage.ref().child(storagePath);
        final uploadTask = ref.putFile(imageFiles[i]);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      return downloadUrls;
    } catch (e) {
      print('Error uploading multiple images: $e');
      return [];
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Take photo with camera
  Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      print('Error taking photo with camera: $e');
      return null;
    }
  }

  // Pick multiple images
  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // Delete image
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Delete multiple images
  Future<bool> deleteMultipleImages(List<String> imageUrls) async {
    try {
      for (String url in imageUrls) {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      }
      return true;
    } catch (e) {
      print('Error deleting multiple images: $e');
      return false;
    }
  }

  // Get image download URL
  Future<String?> getImageDownloadUrl(String imagePath) async {
    try {
      final ref = _storage.ref().child(imagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      return null;
    }
  }

  // Download image as bytes
  Future<Uint8List?> downloadImageAsBytes(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      final data = await ref.getData();
      return data;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  // Get file size
  Future<int?> getFileSize(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      final metadata = await ref.getMetadata();
      return metadata.size;
    } catch (e) {
      print('Error getting file size: $e');
      return null;
    }
  }

  // Compress image before upload
  Future<File?> compressImage(File imageFile) async {
    try {
      // This is a basic implementation
      // For better compression, consider using packages like 'flutter_image_compress'
      return imageFile;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  // Generate unique filename
  String generateUniqueFileName(String originalName) {
    final extension = path.extension(originalName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return '${timestamp}_$random$extension';
  }

  // Validate image file
  bool isValidImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension);
  }

  // Get storage reference for a path
  Reference getStorageReference(String path) {
    return _storage.ref().child(path);
  }
}
