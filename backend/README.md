# PetTrack Firebase Backend

A comprehensive Firebase backend for a Flutter-based pet tracking mobile app with authentication and image storage capabilities.

## Features

- **Authentication**: Phone number and Google Sign-In
- **Image Storage**: Upload and manage pet images, user profiles, and report images
- **Real-time Database**: Firestore for pet data, user profiles, and lost/found reports
- **Cloud Functions**: Backend logic for user management and data processing
- **Security Rules**: Comprehensive security rules for Firestore and Storage

## Project Structure

```
├── firebase.json              # Firebase configuration
├── firestore.rules            # Firestore security rules
├── storage.rules              # Firebase Storage security rules
├── firestore.indexes.json     # Firestore indexes for efficient queries
├── functions/                 # Firebase Cloud Functions
│   ├── package.json
│   └── index.js
├── lib/                       # Flutter app code
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── storage_service.dart
│   │   └── firestore_service.dart
│   └── widgets/
│       ├── auth_widgets.dart
│       └── image_upload_widget.dart
├── flutter_config.md          # Flutter setup guide
└── README.md                  # This file
```

## Setup Instructions

### 1. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Enable the following services:
   - Authentication (Phone and Google Sign-In)
   - Firestore Database
   - Storage
   - Functions

### 2. Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### 3. Initialize Firebase Project

```bash
firebase init
```

Select the following services:
- Firestore
- Storage
- Functions
- Hosting (optional)

### 4. Deploy Firebase Configuration

```bash
# Deploy security rules
firebase deploy --only firestore:rules
firebase deploy --only storage

# Deploy functions
cd functions
npm install
firebase deploy --only functions
```

### 5. Flutter Setup

1. Add dependencies to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  google_sign_in: ^6.1.6
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  path: ^1.8.3
```

2. Download Firebase configuration files:
   - `google-services.json` for Android → `android/app/`
   - `GoogleService-Info.plist` for iOS → `ios/Runner/`

3. Initialize Firebase in your Flutter app:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

## Usage Examples

### Authentication

```dart
import 'package:your_app/services/auth_service.dart';

final authService = AuthService();

// Phone authentication
await authService.verifyPhoneNumber(
  phoneNumber: '+1234567890',
  onCodeSent: (verificationId) {
    // Handle code sent
  },
  onVerificationCompleted: (credential) {
    // Handle auto-verification
  },
  onVerificationFailed: (exception) {
    // Handle error
  },
  onCodeAutoRetrievalTimeout: (verificationId) {
    // Handle timeout
  },
);

// Google Sign-In
final userCredential = await authService.signInWithGoogle();

// Sign out
await authService.signOut();
```

### Image Upload

```dart
import 'package:your_app/services/storage_service.dart';

final storageService = StorageService();

// Upload user profile image
final imageUrl = await storageService.uploadUserProfileImage(
  userId: 'user123',
  imageFile: File('path/to/image.jpg'),
);

// Upload pet image
final petImageUrl = await storageService.uploadPetImage(
  petId: 'pet456',
  imageFile: File('path/to/pet.jpg'),
);

// Pick image from gallery
final image = await storageService.pickImageFromGallery();
```

### Firestore Operations

```dart
import 'package:your_app/services/firestore_service.dart';

final firestoreService = FirestoreService();

// Create pet document
final petId = await firestoreService.createPetDocument({
  'name': 'Buddy',
  'type': 'Dog',
  'breed': 'Golden Retriever',
  'age': 3,
  'images': ['url1', 'url2'],
});

// Get user's pets
firestoreService.getUserPets('user123').listen((snapshot) {
  // Handle real-time updates
});

// Create lost/found report
final reportId = await firestoreService.createReportDocument({
  'type': 'lost',
  'petType': 'Dog',
  'location': 'Central Park',
  'description': 'Lost golden retriever',
  'images': ['url1'],
});
```

## Security Rules

### Firestore Rules
- Users can only read/write their own data
- Pet owners can manage their pets
- Reports are readable by all authenticated users
- Users can only modify their own reports

### Storage Rules
- User profile images: Owner only
- Pet images: Readable by all, writable by owner
- Report images: Readable by all, writable by report creator

## Cloud Functions

The backend includes several Cloud Functions:

1. **createUserProfile**: Automatically creates user profile on signup
2. **updateUserProfile**: Updates user profile information
3. **getUserProfile**: Retrieves user profile data
4. **deleteUserAccount**: Deletes user account and associated data
5. **onImageUpload**: Handles image upload metadata
6. **cleanupOrphanedImages**: Cleans up images when documents are deleted

## Data Models

### User Document
```json
{
  "uid": "user123",
  "email": "user@example.com",
  "phoneNumber": "+1234567890",
  "displayName": "John Doe",
  "photoURL": "https://...",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "isActive": true,
  "preferences": {
    "notifications": true,
    "locationSharing": false
  }
}
```

### Pet Document
```json
{
  "id": "pet456",
  "ownerId": "user123",
  "name": "Buddy",
  "type": "Dog",
  "breed": "Golden Retriever",
  "age": 3,
  "images": ["url1", "url2"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Report Document
```json
{
  "id": "report789",
  "userId": "user123",
  "type": "lost",
  "petType": "Dog",
  "location": "Central Park",
  "description": "Lost golden retriever",
  "images": ["url1"],
  "status": "active",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Ensure phone authentication is enabled in Firebase Console
   - Add SHA-1 fingerprint for Android
   - Configure OAuth consent screen for Google Sign-In

2. **Storage Permission Errors**
   - Check storage rules are properly deployed
   - Verify user authentication status

3. **Firestore Permission Errors**
   - Ensure Firestore rules are deployed
   - Check user authentication and document ownership

### Debug Commands

```bash
# View Firebase logs
firebase functions:log

# Test security rules
firebase firestore:rules:test

# Emulate locally
firebase emulators:start
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 