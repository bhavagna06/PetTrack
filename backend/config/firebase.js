const admin = require('firebase-admin');
require('dotenv').config({ path: './config.env' });

var serviceAccount = require("../serviceAccountKey.json");

// Firebase configuration
const firebaseConfig = {
  type: "service_account",
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') : undefined,
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: process.env.FIREBASE_AUTH_URI,
  token_uri: process.env.FIREBASE_TOKEN_URI,
  auth_provider_x509_cert_url: process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
  client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL
};

// Validate Firebase configuration
if (!firebaseConfig.private_key) {
  console.error('❌ Firebase private key is missing or invalid');
  throw new Error('Firebase private key is required');
}

if (!firebaseConfig.client_email) {
  console.error('❌ Firebase client email is missing');
  throw new Error('Firebase client email is required');
}

// Log configuration for debugging (without sensitive data)
console.log('Firebase Config Check:', {
  project_id: firebaseConfig.project_id,
  client_email: firebaseConfig.client_email,
  has_private_key: !!firebaseConfig.private_key,
  private_key_length: firebaseConfig.private_key ? firebaseConfig.private_key.length : 0,
  client_x509_cert_url: firebaseConfig.client_x509_cert_url
});

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
      console.log('Starting Firebase upload for file:', file.originalname);
      console.log('File size:', file.size, 'bytes');
      console.log('File mimetype:', file.mimetype);
      
      const fileName = `${folder}/${Date.now()}-${Math.round(Math.random() * 1E9)}-${file.originalname}`;
      console.log('Generated filename:', fileName);
      
      const fileUpload = bucket.file(fileName);
      
      const blobStream = fileUpload.createWriteStream({
        metadata: {
          contentType: file.mimetype,
        },
        resumable: false
      });

      return new Promise((resolve, reject) => {
        blobStream.on('error', (error) => {
          console.error('Firebase upload stream error:', error);
          console.error('Error details:', {
            code: error.code,
            message: error.message,
            stack: error.stack
          });
          reject(error);
        });

        blobStream.on('finish', async () => {
          try {
            console.log('File upload completed, making public...');
            // Make the file public
            await fileUpload.makePublic();
            
            // Get the public URL
            const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
            console.log('File uploaded successfully:', publicUrl);
            resolve(publicUrl);
          } catch (error) {
            console.error('Error making file public:', error);
            reject(error);
          }
        });

        console.log('Starting file buffer upload...');
        blobStream.end(file.buffer);
      });
    } catch (error) {
      console.error('Firebase upload error:', error);
      console.error('Error stack:', error.stack);
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