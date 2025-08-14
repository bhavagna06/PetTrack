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
          print('ImageService: File size: ${await file.length()} bytes');
          print('ImageService: File path: ${file.path}');
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
      print('ImageService: Error stack trace: ${e.toString()}');
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
          print('ImageService: File size: ${await file.length()} bytes');
          print('ImageService: File path: ${file.path}');
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
      print('ImageService: Error stack trace: ${e.toString()}');
      return null;
    }
  }

  // Pick multiple images from gallery
  Future<List<File>> pickMultipleImagesFromGallery({int maxImages = 2}) async {
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

  // Upload single image to Firebase Storage with progress tracking
  Future<String?> uploadImageToFirebase({
    required File imageFile,
    required String folder,
    String? customFileName,
    Function(double)? onProgress,
  }) async {
    try {
      print('ImageService: Starting Firebase upload...');
      print('ImageService: File path: ${imageFile.path}');
      print('ImageService: File exists: ${await imageFile.exists()}');
      print('ImageService: File size: ${await imageFile.length()} bytes');

      // Validate file before upload
      if (!await imageFile.exists()) {
        print('ImageService: Error - File does not exist');
        return null;
      }

      final int fileSize = await imageFile.length();
      if (fileSize == 0) {
        print('ImageService: Error - File is empty');
        return null;
      }

      // Generate unique filename
      final String fileName = customFileName ??
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

      print('ImageService: Generated filename: $fileName');

      // Create reference to Firebase Storage
      final Reference ref = _storage.ref().child('$folder/$fileName');

      // Upload file with progress tracking
      print('ImageService: Starting upload task...');
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print(
            'ImageService: Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
        if (onProgress != null) {
          onProgress(progress);
        }
      });

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
      print('ImageService: Error details: ${e.toString()}');
      print('ImageService: Firebase Storage upload failed');
      return null;
    }
  }

  // Upload multiple images to Firebase Storage in parallel
  Future<List<String>> uploadMultipleImagesToFirebase({
    required List<File> imageFiles,
    required String folder,
    Function(int, double)? onProgress,
  }) async {
    try {
      final List<String> downloadUrls = [];
      final int totalImages = imageFiles.length;
      int completedImages = 0;

      print('ImageService: Starting parallel upload of $totalImages images');

      // Upload images in parallel with progress tracking
      final List<Future<String?>> uploadFutures =
          imageFiles.asMap().entries.map((entry) {
        final int index = entry.key;
        final File imageFile = entry.value;

        return uploadImageToFirebase(
          imageFile: imageFile,
          folder: folder,
          onProgress: (progress) {
            if (onProgress != null) {
              onProgress(index, progress);
            }
          },
        ).then((url) {
          completedImages++;
          print('ImageService: Completed $completedImages/$totalImages images');
          return url;
        });
      }).toList();

      // Wait for all uploads to complete in parallel
      final List<String?> results = await Future.wait(uploadFutures);

      // Filter out null results
      for (final String? result in results) {
        if (result != null) {
          downloadUrls.add(result);
        }
      }

      print(
          'ImageService: Successfully uploaded ${downloadUrls.length}/$totalImages images');
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
        print('ImageService: File too large: ${sizeInMB.toStringAsFixed(2)}MB');
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
        print('ImageService: Invalid file extension: $extension');
        return false;
      }

      print(
          'ImageService: File validation passed - Size: ${sizeInMB.toStringAsFixed(2)}MB, Extension: $extension');
      return true;
    } catch (e) {
      print('Error validating image file: $e');
      return false;
    }
  }
}
