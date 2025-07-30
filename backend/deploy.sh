#!/bin/bash

# PetTrack Firebase Backend Deployment Script

echo "🚀 Starting PetTrack Firebase Backend Deployment..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Please login to Firebase first:"
    echo "firebase login"
    exit 1
fi

echo "✅ Firebase CLI is ready"

# Deploy Firestore rules
echo "📝 Deploying Firestore security rules..."
firebase deploy --only firestore:rules

if [ $? -eq 0 ]; then
    echo "✅ Firestore rules deployed successfully"
else
    echo "❌ Failed to deploy Firestore rules"
    exit 1
fi

# Deploy Storage rules
echo "📁 Deploying Storage security rules..."
firebase deploy --only storage

if [ $? -eq 0 ]; then
    echo "✅ Storage rules deployed successfully"
else
    echo "❌ Failed to deploy Storage rules"
    exit 1
fi

# Deploy Functions
echo "⚡ Deploying Cloud Functions..."
cd functions

# Install dependencies
echo "📦 Installing function dependencies..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Deploy functions
firebase deploy --only functions

if [ $? -eq 0 ]; then
    echo "✅ Cloud Functions deployed successfully"
else
    echo "❌ Failed to deploy Cloud Functions"
    exit 1
fi

cd ..

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Add Firebase configuration files to your Flutter project:"
echo "   - google-services.json → android/app/"
echo "   - GoogleService-Info.plist → ios/Runner/"
echo ""
echo "2. Add Firebase dependencies to pubspec.yaml"
echo ""
echo "3. Initialize Firebase in your Flutter app"
echo ""
echo "4. Test authentication and image upload features"
echo ""
 