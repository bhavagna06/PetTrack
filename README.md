# PetTrack 🐾

A mobile app dedicated to helping pet owners reunite with their lost cats and dogs.

## Features

### Current Features ✅
- **Welcome Screen**: Beautiful introduction to the app with feature highlights
- **Authentication**: 
  - Google Sign-In integration
  - Phone number authentication with OTP
  - Modern, pet-themed UI design
- **Home Screen**: Dashboard with main app actions
- **Responsive Design**: Works on multiple screen sizes

### Planned Features 🚧
- **Lost Pet Reporting**: Post details and photos of lost pets
- **Found Pet Reporting**: Report sightings with GPS location
- **Image Similarity Search**: AI-powered pet matching using TensorFlow Lite
- **QR Code Scanning**: Quick identification with digital pet tags
- **Map Integration**: View nearby pets and sightings
- **Real-time Notifications**: Instant alerts for potential matches

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase
- **Authentication**: Firebase Auth
- **Database**: Firestore (planned)
- **Storage**: Firebase Storage (planned)
- **AI/ML**: TensorFlow Lite (planned)
- **Maps**: Google Maps API (planned)

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pettrack
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Follow the instructions in `firebase_setup.md`
   - Configure Firebase Authentication
   - Add configuration files for your platform

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── screens/
│   ├── welcome_screen.dart    # Welcome/intro screen
│   ├── auth_screen.dart       # Authentication screen
│   └── home_screen.dart       # Main dashboard
└── assets/
    ├── images/            # App images
    └── animations/        # Lottie animations
```

## Screenshots

### Welcome Screen
- Modern gradient design with pet-themed elements
- Feature highlights with icons
- Call-to-action button to get started

### Authentication Screen
- Google Sign-In button
- Phone number input with OTP verification
- Clean, modern UI with proper error handling

### Home Screen
- Welcome message with user info
- Grid layout of main actions
- Logout functionality

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you have any questions or need help, please open an issue on GitHub.

---

Made with ❤️ for pets and their families
