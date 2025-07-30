# Flutter Firebase Configuration Guide

## 1. Add Firebase Dependencies

Add these dependencies to your `pubspec.yaml`:

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
```

## 2. Firebase Configuration Files

### Android (`android/app/google-services.json`)
Download from Firebase Console and place in `android/app/`

### iOS (`ios/Runner/GoogleService-Info.plist`)
Download from Firebase Console and place in `ios/Runner/`

### Web (`web/index.html`)
Add Firebase SDK to your web index.html:

```html
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-storage.js"></script>
```

## 3. Initialize Firebase

In your `main.dart`:

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

## 4. Authentication Setup

### Phone Authentication
- Enable Phone Authentication in Firebase Console
- Add your app's SHA-1 fingerprint for Android
- Configure reCAPTCHA for web

### Google Sign-In
- Enable Google Sign-In in Firebase Console
- Configure OAuth consent screen
- Add your app's bundle ID/package name

## 5. Storage Setup

- Enable Firebase Storage in Firebase Console
- Set up security rules (already provided)
- Configure CORS if needed for web

## 6. Firestore Setup

- Enable Firestore Database in Firebase Console
- Set up security rules (already provided)
- Configure indexes (already provided) 