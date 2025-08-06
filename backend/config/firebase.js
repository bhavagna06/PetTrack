const admin = require('firebase-admin');
require('dotenv').config({ path: './config.env' });

// Firebase configuration
const firebaseConfig = {
  type: "service_account",
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: process.env.FIREBASE_AUTH_URI,
  token_uri: process.env.FIREBASE_TOKEN_URI,
  auth_provider_x509_cert_url: process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
  client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL
};

// Initialize Firebase Admin SDK
let firebaseApp;

try {
  firebaseApp = admin.initializeApp({
    credential: admin.credential.cert(firebaseConfig),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET
  });
  console.log('✅ Firebase Admin SDK initialized successfully');
} catch (error) {
  if (error.code === 'app/duplicate-app') {
    firebaseApp = admin.app();
    console.log('✅ Firebase Admin SDK already initialized');
  } else {
    console.error('❌ Firebase Admin SDK initialization error:', error);
    throw error;
  }
}

// Get Firebase Storage bucket
const bucket = firebaseApp.storage().bucket();

// Utility functions for Firebase Storage
const firebaseStorage = {
  // Upload a single file to Firebase Storage
  uploadFile: async (file, folder = 'general') => {
    try {
      const fileName = `${folder}/${Date.now()}-${Math.round(Math.random() * 1E9)}-${file.originalname}`;
      const fileUpload = bucket.file(fileName);
      
      const blobStream = fileUpload.createWriteStream({
        metadata: {
          contentType: file.mimetype,
        },
        resumable: false
      });

      return new Promise((resolve, reject) => {
        blobStream.on('error', (error) => {
          console.error('Firebase upload error:', error);
          reject(error);
        });

        blobStream.on('finish', async () => {
          try {
            // Make the file public
            await fileUpload.makePublic();
            
            // Get the public URL
            const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
            resolve(publicUrl);
          } catch (error) {
            console.error('Error making file public:', error);
            reject(error);
          }
        });

        blobStream.end(file.buffer);
      });
    } catch (error) {
      console.error('Firebase upload error:', error);
      throw error;
    }
  },

  // Upload multiple files to Firebase Storage
  uploadMultipleFiles: async (files, folder = 'general') => {
    try {
      const uploadPromises = files.map(file => firebaseStorage.uploadFile(file, folder));
      const urls = await Promise.all(uploadPromises);
      return urls;
    } catch (error) {
      console.error('Firebase multiple upload error:', error);
      throw error;
    }
  },

  // Delete a file from Firebase Storage
  deleteFile: async (fileUrl) => {
    try {
      if (!fileUrl) return;
      
      // Extract file path from URL
      const urlParts = fileUrl.split('/');
      const fileName = urlParts.slice(-2).join('/'); // Get folder/filename
      
      const file = bucket.file(fileName);
      await file.delete();
      console.log(`File deleted: ${fileName}`);
    } catch (error) {
      console.error('Firebase delete error:', error);
      throw error;
    }
  },

  // Delete multiple files from Firebase Storage
  deleteMultipleFiles: async (fileUrls) => {
    try {
      const deletePromises = fileUrls.map(url => firebaseStorage.deleteFile(url));
      await Promise.all(deletePromises);
    } catch (error) {
      console.error('Firebase multiple delete error:', error);
      throw error;
    }
  }
};

module.exports = {
  firebaseApp,
  bucket,
  firebaseStorage
}; 