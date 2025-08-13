import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Check and request permissions for image operations
  Future<bool> checkAndRequestPermissions() async {
    try {
      print('ImageService: Checking permissions...');

      // Check camera permission
      PermissionStatus cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        print('ImageService: Requesting camera permission...');
        cameraStatus = await Permission.camera.request();
      }

      // Check storage permissions
      PermissionStatus storageStatus;
      if (Platform.isAndroid) {
        if (await _isAndroid13OrHigher()) {
          // For Android 13+ (API 33+)
          storageStatus = await Permission.photos.status;
          if (storageStatus.isDenied) {
            print('ImageService: Requesting photos permission...');
            storageStatus = await Permission.photos.request();
          }
        } else {
          // For Android 12 and below
          storageStatus = await Permission.storage.status;
          if (storageStatus.isDenied) {
            print('ImageService: Requesting storage permission...');
            storageStatus = await Permission.storage.request();
          }
        }
      } else {
        // For iOS
        storageStatus = await Permission.photos.status;
        if (storageStatus.isDenied) {
          print('ImageService: Requesting photos permission...');
          storageStatus = await Permission.photos.request();
        }
      }

      final bool hasPermissions =
          cameraStatus.isGranted && storageStatus.isGranted;
      print('ImageService: Camera permission: ${cameraStatus.isGranted}');
      print('ImageService: Storage permission: ${storageStatus.isGranted}');
      print('ImageService: All permissions granted: $hasPermissions');

      return hasPermissions;
    } catch (e) {
      print('ImageService: Error checking permissions: $e');
      return false;
    }
  }

  // Check if device is running Android 13 or higher
  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      // This is a simple check - in a real app you might want to use device_info_plus package
      return true; // Assume Android 13+ for now
    }
    return false;
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      print('ImageService: Attempting to pick image from camera...');

      // Check permissions first
      final bool hasPermissions = await checkAndRequestPermissions();
      if (!hasPermissions) {
        print('ImageService: Camera permissions not granted');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        print('ImageService: Image picked from camera: ${image.path}');
        final file = File(image.path);

        // Verify file exists and is readable
        if (await file.exists()) {
          print('ImageService: File exists and is readable');
          return file;
        } else {
          print('ImageService: File does not exist after picking');
          return null;
        }
      }
      print('ImageService: No image selected from camera');
      return null;
    } catch (e) {
      print('ImageService: Error picking image from camera: $e');
      print('ImageService: Error type: ${e.runtimeType}');
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      print('ImageService: Attempting to pick image from gallery...');

      // Check permissions first
      final bool hasPermissions = await checkAndRequestPermissions();
      if (!hasPermissions) {
        print('ImageService: Gallery permissions not granted');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        print('ImageService: Image picked from gallery: ${image.path}');
        final file = File(image.path);

        // Verify file exists and is readable
        if (await file.exists()) {
          print('ImageService: File exists and is readable');
          return file;
        } else {
          print('ImageService: File does not exist after picking');
          return null;
        }
      }
      print('ImageService: No image selected from gallery');
      return null;
    } catch (e) {
      print('ImageService: Error picking image from gallery: $e');
      print('ImageService: Error type: ${e.runtimeType}');
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
      print('ImageService: Starting Firebase upload...');
      print('ImageService: File path: ${imageFile.path}');
      print('ImageService: File exists: ${await imageFile.exists()}');
      print('ImageService: File size: ${await imageFile.length()} bytes');

      // Generate unique filename
      final String fileName = customFileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

      print('ImageService: Generated filename: $fileName');

      // Create reference to Firebase Storage
      final Reference ref = _storage.ref().child('$folder/$fileName');

      // Upload file
      print('ImageService: Starting upload task...');
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      print('ImageService: Upload completed successfully');

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('ImageService: Download URL obtained: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('ImageService: Error uploading image to Firebase: $e');
      print('ImageService: Error type: ${e.runtimeType}');
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
      final List<String> allowedExtensions = [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp'
      ];
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
