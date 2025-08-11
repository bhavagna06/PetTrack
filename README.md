# PetTrack - Lost and Found Pet Tracking App

A Flutter application for tracking lost and found pets with a Node.js backend.

## Features

### Core Functionality
- **Post Lost Pets**: Users can report lost pets with detailed information
- **Post Found Pets**: Users can report found pets with detailed information
- **View Lost Pets**: Browse all reported lost pets
- **View Found Pets**: Browse all reported found pets
- **Search and Filter**: Search pets by name and filter by pet type
- **Pet Details**: View detailed information about each pet
- **Photo Upload**: Upload multiple photos for each pet

### User Interface
- **Modern Design**: Clean, intuitive interface with consistent styling
- **Responsive Layout**: Works on various screen sizes
- **Pull-to-Refresh**: Refresh pet listings by pulling down
- **Navigation**: Easy navigation between different sections

## Technical Stack

### Frontend (Flutter)
- **Framework**: Flutter with Dart
- **State Management**: StatefulWidget for local state
- **HTTP Client**: http package for API communication
- **Image Picker**: image_picker for photo selection
- **UI Components**: Material Design with custom styling

### Backend (Node.js)
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **File Storage**: Firebase Storage for images
- **Validation**: express-validator for input validation
- **File Upload**: multer for handling multipart form data

## API Endpoints

### Pets
- `POST /api/pets` - Create a new pet
- `GET /api/pets` - Get all pets (with optional filters)
- `GET /api/pets/:id` - Get a specific pet
- `PUT /api/pets/:id` - Update a pet
- `DELETE /api/pets/:id` - Delete a pet (soft delete)
- `POST /api/pets/:id/mark-lost` - Mark pet as lost
- `POST /api/pets/:id/mark-found` - Mark pet as found
- `POST /api/pets/:id/upload-photos` - Upload additional photos
- `GET /api/pets/owner/:ownerId` - Get pets by owner

### Users
- `POST /api/users/register` - Register a new user
- `POST /api/users/login` - User login
- `GET /api/users` - Get all users
- `DELETE /api/users/:id` - Delete a user

## Data Models

### Pet Schema
```javascript
{
  petName: String (required),
  petType: String (enum: ['Dog', 'Cat', 'Rabbit', 'Hamster', 'Guinea Pig', 'Bird', 'Other']),
  breed: String (required),
  gender: String (enum: ['Male', 'Female']),
  color: String (enum: ['Black', 'White', 'Brown', 'Golden', 'Gray', 'Orange', 'Cream', 'Multi-colored', 'Other']),
  homeLocation: String (required),
  profileImage: String (Firebase URL),
  additionalPhotos: [String] (Firebase URLs),
  ownerId: ObjectId (ref: 'User'),
  isActive: Boolean (default: true),
  isLost: Boolean (default: false),
  isFound: Boolean (default: false),
  createdAt: Date,
  updatedAt: Date
}
```

## Setup Instructions

### Backend Setup
1. Navigate to the backend directory: `cd backend`
2. Install dependencies: `npm install`
3. Create a `.env` file with your configuration:
   ```
   MONGODB_URI=your_mongodb_connection_string
   PORT=3000
   MAX_FILE_SIZE=5242880
   ```
4. Start the server: `npm start`

### Frontend Setup
1. Navigate to the project root: `cd pettrack`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`

### Testing
1. Navigate to the backend directory: `cd backend`
2. Run the API tests: `node test-api.js`

## Usage

### Posting a Lost Pet
1. Navigate to "Post Lost" from the bottom navigation
2. Fill in the required fields:
   - Pet Name
   - Pet Type (Dog, Cat, Bird, Other)
   - Breed
   - Gender
   - Color
   - Last Known Location
3. Optionally upload photos
4. Tap "Post Lost Pet"

### Posting a Found Pet
1. Navigate to "Post Found" from the bottom navigation
2. Fill in the required fields:
   - Pet Name
   - Pet Type (Dog, Cat, Bird, Other)
   - Breed
   - Gender
   - Color
   - Found Location
3. Optionally upload photos
4. Tap "Report Found Pet"

### Viewing Pets
1. The home screen displays two sections:
   - **Lost Pets**: Shows all reported lost pets
   - **Found Pets**: Shows all reported found pets
2. Use the search bar to find pets by name
3. Use the filter to search by pet type
4. Pull down to refresh the listings
5. Tap on any pet card to view detailed information

## Styling

The app uses a consistent color scheme:
- **Background**: `#FCFAF8` (Light cream)
- **Primary Text**: `#1C150D` (Dark brown)
- **Secondary Text**: `#9C7649` (Medium brown)
- **Input Background**: `#F4EEE7` (Light beige)
- **Primary Button**: `#F2870C` (Orange)
- **Border**: `#F4EEE7` (Light beige)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.
