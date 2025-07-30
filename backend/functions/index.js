const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

// Create user profile when new user signs up
exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
  try {
    const userProfile = {
      uid: user.uid,
      email: user.email || null,
      phoneNumber: user.phoneNumber || null,
      displayName: user.displayName || null,
      photoURL: user.photoURL || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
      preferences: {
        notifications: true,
        locationSharing: false
      }
    };

    await db.collection('users').doc(user.uid).set(userProfile);
    console.log(`User profile created for: ${user.uid}`);
  } catch (error) {
    console.error('Error creating user profile:', error);
  }
});

// Update user profile
exports.updateUserProfile = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  try {
    const userId = context.auth.uid;
    const updateData = {
      ...data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    await db.collection('users').doc(userId).update(updateData);
    return { success: true, message: 'Profile updated successfully' };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Error updating profile', error);
  }
});

// Get user profile
exports.getUserProfile = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  try {
    const userId = context.auth.uid;
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User profile not found');
    }

    return { success: true, profile: userDoc.data() };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Error fetching profile', error);
  }
});

// Delete user account and associated data
exports.deleteUserAccount = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  try {
    const userId = context.auth.uid;
    
    // Delete user's pets
    const petsSnapshot = await db.collection('pets').where('ownerId', '==', userId).get();
    const petDeletions = petsSnapshot.docs.map(doc => doc.ref.delete());
    
    // Delete user's reports
    const reportsSnapshot = await db.collection('reports').where('userId', '==', userId).get();
    const reportDeletions = reportsSnapshot.docs.map(doc => doc.ref.delete());
    
    // Delete user profile
    await db.collection('users').doc(userId).delete();
    
    // Wait for all deletions to complete
    await Promise.all([...petDeletions, ...reportDeletions]);
    
    // Delete the user from Firebase Auth
    await auth.deleteUser(userId);
    
    return { success: true, message: 'Account deleted successfully' };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Error deleting account', error);
  }
});

// Handle image upload metadata
exports.onImageUpload = functions.storage.object().onFinalize(async (object) => {
  const filePath = object.name;
  const contentType = object.contentType;
  
  if (!contentType.startsWith('image/')) {
    console.log('This is not an image.');
    return;
  }

  try {
    // Extract user ID and type from path
    const pathParts = filePath.split('/');
    const userId = pathParts[1];
    const type = pathParts[0]; // users, pets, reports
    
    if (type === 'users' && pathParts[2] === 'profile') {
      // Update user profile with new image URL
      const imageUrl = `https://storage.googleapis.com/${object.bucket}/${filePath}`;
      await db.collection('users').doc(userId).update({
        photoURL: imageUrl,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
    
    console.log(`Image uploaded: ${filePath}`);
  } catch (error) {
    console.error('Error handling image upload:', error);
  }
});

// Clean up orphaned images when documents are deleted
exports.cleanupOrphanedImages = functions.firestore
  .document('{collection}/{docId}')
  .onDelete(async (snap, context) => {
    const deletedData = snap.data();
    const collection = context.params.collection;
    const docId = context.params.docId;
    
    try {
      if (collection === 'users' && deletedData.photoURL) {
        // Delete user profile image
        const bucket = admin.storage().bucket();
        const imagePath = `users/${docId}/profile/profile.jpg`;
        await bucket.file(imagePath).delete();
      }
      
      console.log(`Cleaned up images for deleted ${collection} document: ${docId}`);
    } catch (error) {
      console.error('Error cleaning up images:', error);
    }
  }); 