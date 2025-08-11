# Image Service Documentation

This document explains how to use the image service functionality in the PetTrack app.

## Overview

The image service provides functionality for:
- Picking images from camera or gallery
- Uploading images to Firebase Storage
- Validating image files
- Managing multiple image selections

## Components

### 1. ImageService (`lib/services/image_service.dart`)

The main service class that handles all image-related operations.

#### Key Methods:

```dart
// Pick image from camera
Future<File?> pickImageFromCamera()

// Pick image from gallery
Future<File?> pickImageFromGallery()

// Pick multiple images from gallery
Future<List<File>> pickMultipleImagesFromGallery({int maxImages = 5})

// Upload single image to Firebase Storage
Future<String?> uploadImageToFirebase({
  required File imageFile,
  required String folder,
  String? customFileName,
})

// Upload multiple images to Firebase Storage
Future<List<String>> uploadMultipleImagesToFirebase({
  required List<File> imageFiles,
  required String folder,
})

// Delete image from Firebase Storage
Future<bool> deleteImageFromFirebase(String imageUrl)

// Validate image file
bool isValidImageFile(File imageFile)
```

### 2. ImagePickerWidget (`lib/widgets/image_picker_widget.dart`)

A reusable widget that provides a user-friendly interface for image selection.

#### Usage:

```dart
ImagePickerWidget(
  onImageSelected: (File image) {
    // Handle selected image
    setState(() {
      _selectedImage = image;
    });
  },
  title: 'Select Image',
  subtitle: 'Camera or Gallery',
  allowMultiple: false,
)
```

#### Properties:

- `onImageSelected`: Callback function when image is selected
- `title`: Title text for the widget
- `subtitle`: Subtitle text (optional)
- `allowMultiple`: Whether to allow multiple image selection
- `maxImages`: Maximum number of images (default: 5)
- `width`, `height`: Custom dimensions
- `backgroundColor`, `textColor`: Custom colors
- `icon`: Custom icon

### 3. SelectedImagesWidget

A widget for displaying selected images with remove functionality.

#### Usage:

```dart
SelectedImagesWidget(
  images: _selectedImages,
  onRemoveImage: (File image) {
    setState(() {
      _selectedImages.remove(image);
    });
  },
)
```

## Implementation Examples

### Basic Single Image Selection

```dart
import '../services/image_service.dart';
import '../widgets/image_picker_widget.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final ImageService _imageService = ImageService();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImagePickerWidget(
          onImageSelected: (File image) {
            setState(() {
              _selectedImage = image;
            });
          },
          title: 'Select Photo',
          subtitle: 'Camera or Gallery',
        ),
        
        if (_selectedImage != null)
          Image.file(
            _selectedImage!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
      ],
    );
  }
}
```

### Multiple Image Selection with Upload

```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final ImageService _imageService = ImageService();
  List<File> _selectedImages = [];
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImagePickerWidget(
          onImageSelected: (File image) {
            setState(() {
              if (_selectedImages.length < 5) {
                _selectedImages.add(image);
              }
            });
          },
          title: 'Select Photos',
          subtitle: 'Up to 5 images',
          allowMultiple: true,
          maxImages: 5,
        ),
        
        if (_selectedImages.isNotEmpty) ...[
          SelectedImagesWidget(
            images: _selectedImages,
            onRemoveImage: (File image) {
              setState(() {
                _selectedImages.remove(image);
              });
            },
          ),
          
          ElevatedButton(
            onPressed: _isUploading ? null : _uploadImages,
            child: Text(_isUploading ? 'Uploading...' : 'Upload'),
          ),
        ],
      ],
    );
  }

  Future<void> _uploadImages() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final List<String> urls = await _imageService.uploadMultipleImagesToFirebase(
        imageFiles: _selectedImages,
        folder: 'pets',
      );
      
      print('Uploaded URLs: $urls');
    } catch (e) {
      print('Upload error: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
```

### Direct Service Usage

```dart
// Pick image from camera
File? cameraImage = await _imageService.pickImageFromCamera();

// Pick image from gallery
File? galleryImage = await _imageService.pickImageFromGallery();

// Validate image
if (cameraImage != null && _imageService.isValidImageFile(cameraImage)) {
  // Upload to Firebase
  String? downloadUrl = await _imageService.uploadImageToFirebase(
    imageFile: cameraImage,
    folder: 'users',
  );
  
  if (downloadUrl != null) {
    // Save URL to database
    print('Image uploaded: $downloadUrl');
  }
}
```

## Database Integration

### MongoDB (Information Storage)
- Store image URLs in MongoDB documents
- Keep metadata like upload date, file size, etc.
- Associate images with user/pet records

### Firebase Storage (Image Storage)
- Store actual image files in Firebase Storage
- Organize by folders (users, pets, posts, etc.)
- Generate public URLs for access

### Example Database Schema

```javascript
// Pet document in MongoDB
{
  _id: ObjectId,
  petName: "Buddy",
  petType: "Dog",
  profileImage: "https://firebasestorage.googleapis.com/...", // Firebase URL
  additionalPhotos: [
    "https://firebasestorage.googleapis.com/...",
    "https://firebasestorage.googleapis.com/..."
  ],
  ownerId: ObjectId,
  createdAt: Date,
  updatedAt: Date
}
```

## Error Handling

The service includes comprehensive error handling:

```dart
try {
  final File? image = await _imageService.pickImageFromCamera();
  if (image != null) {
    if (_imageService.isValidImageFile(image)) {
      final String? url = await _imageService.uploadImageToFirebase(
        imageFile: image,
        folder: 'pets',
      );
      if (url != null) {
        // Success
      } else {
        // Upload failed
      }
    } else {
      // Invalid file
    }
  } else {
    // No image selected
  }
} catch (e) {
  // Handle error
  print('Error: $e');
}
```

## File Validation

The service validates:
- File size (max 10MB)
- File format (jpg, jpeg, png, gif, webp)
- File existence and readability

## Firebase Storage Structure

```
firebase-storage/
├── users/
│   ├── profile-images/
│   └── documents/
├── pets/
│   ├── profile-images/
│   └── additional-photos/
├── posts/
│   ├── lost-pets/
│   └── found-pets/
└── demo/
    └── test-images/
```

## Permissions

Make sure to add the following permissions to your app:

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos of pets</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select pet photos</string>
```

## Testing

Use the `ImageDemoScreen` to test all image functionality:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ImageDemoScreen()),
);
```

This screen demonstrates:
- Single image selection
- Multiple image selection
- Image upload to Firebase
- URL display
- Feature overview
