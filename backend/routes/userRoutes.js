const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { body, validationResult } = require('express-validator');
const multer = require('multer');
const { firebaseStorage } = require('../config/firebase');

// Configure multer for memory storage (for Firebase upload)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: function (req, file, cb) {
    // Accept only images
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

// Validation middleware for user registration
const validateUserRegistration = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters'),
  
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please enter a valid email address'),
  
  body('phone')
    .trim()
    .isLength({ min: 10, max: 15 })
    .withMessage('Phone number must be between 10 and 15 characters'),
  
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long')
];

// Validation middleware for user update
const validateUserUpdate = [
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters'),
  
  body('email')
    .optional()
    .isEmail()
    .normalizeEmail()
    .withMessage('Please enter a valid email address'),
  
  body('phone')
    .optional()
    .trim()
    .isLength({ min: 10, max: 15 })
    .withMessage('Phone number must be between 10 and 15 characters')
];

// Helper function to handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array()
    });
  }
  next();
};

// @route   POST /api/users/google-auth
// @desc    Authenticate or create user with Google
// @access  Public
router.post('/google-auth', async (req, res) => {
  try {
    const {
      firebaseUid,
      email,
      name,
      profileImage
    } = req.body;

    if (!firebaseUid || !email) {
      return res.status(400).json({
        success: false,
        message: 'Firebase UID and email are required'
      });
    }

    // Check if user already exists with this Firebase UID
    let user = await User.findOne({ firebaseUid });

    if (!user) {
      // Check if user exists with this email
      user = await User.findOne({ email: email.toLowerCase() });

      if (user) {
        // User exists with email but no Firebase UID, update it
        user.firebaseUid = firebaseUid;
        if (name && !user.name) user.name = name;
        if (profileImage && !user.profileImage) user.profileImage = profileImage;
        await user.save();
      } else {
        // Create new user
        const userData = {
          firebaseUid,
          email: email.toLowerCase(),
          name: name || 'Google User',
          authProvider: 'google',
          isEmailVerified: true
        };

        if (profileImage) {
          userData.profileImage = profileImage;
        }

        user = new User(userData);
        await user.save();
      }
    } else {
      // User exists, update profile if needed
      let updated = false;
      if (name && user.name !== name) {
        user.name = name;
        updated = true;
      }
      if (profileImage && user.profileImage !== profileImage) {
        user.profileImage = profileImage;
        updated = true;
      }
      if (updated) {
        await user.save();
      }
    }

    // Return user data without password
    const userResponse = user.toObject();
    delete userResponse.password;

    res.status(200).json({
      success: true,
      message: 'Google authentication successful',
      data: userResponse
    });

  } catch (error) {
    console.error('Google auth error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error during Google authentication'
    });
  }
});

// @route   POST /api/users/register
// @desc    Register a new user
// @access  Public
router.post('/register', upload.single('profileImage'), validateUserRegistration, handleValidationErrors, async (req, res) => {
  try {
    const {
      name,
      email,
      phone,
      password,
      address
    } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({
      $or: [{ email: email.toLowerCase() }, { phone }]
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User with this email or phone number already exists'
      });
    }

    // Create user object
    const userData = {
      name,
      email: email.toLowerCase(),
      phone,
      password
    };

    // Add address if provided
    if (address) {
      userData.address = JSON.parse(address);
    }

    // Upload profile image to Firebase if provided
    if (req.file) {
      try {
        const imageUrl = await firebaseStorage.uploadFile(req.file, 'users');
        userData.profileImage = imageUrl;
      } catch (uploadError) {
        console.error('Firebase upload error:', uploadError);
        return res.status(500).json({
          success: false,
          message: 'Error uploading image to Firebase',
          error: uploadError.message
        });
      }
    }

    const user = new User(userData);
    await user.save();

    // Remove password from response
    const userResponse = user.toObject();
    delete userResponse.password;

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: userResponse
    });

  } catch (error) {
    console.error('Error registering user:', error);
    res.status(500).json({
      success: false,
      message: 'Error registering user',
      error: error.message
    });
  }
});

// @route   POST /api/users/login
// @desc    Login user with email
// @access  Public
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check if email and password are provided
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    // Find user by email and include password
    const user = await User.findOne({ email: email.toLowerCase() }).select('+password');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Check if password is correct
    const isPasswordCorrect = await user.correctPassword(password, user.password);

    if (!isPasswordCorrect) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Update last login
    await user.updateLastLogin();

    // Remove password from response
    const userResponse = user.toObject();
    delete userResponse.password;

    res.json({
      success: true,
      message: 'Login successful',
      data: userResponse
    });

  } catch (error) {
    console.error('Error logging in user:', error);
    res.status(500).json({
      success: false,
      message: 'Error logging in user',
      error: error.message
    });
  }
});

// @route   POST /api/users/login-phone
// @desc    Login user with phone number
// @access  Public
router.post('/login-phone', async (req, res) => {
  try {
    const { phone, password } = req.body;

    // Check if phone and password are provided
    if (!phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide phone number and password'
      });
    }

    // Find user by phone and include password
    const user = await User.findOne({ phone: phone }).select('+password');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number or password'
      });
    }

    // Check if password is correct
    const isPasswordCorrect = await user.correctPassword(password, user.password);

    if (!isPasswordCorrect) {
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number or password'
      });
    }

    // Update last login
    await user.updateLastLogin();

    // Remove password from response
    const userResponse = user.toObject();
    delete userResponse.password;

    res.json({
      success: true,
      message: 'Login successful',
      data: userResponse
    });

  } catch (error) {
    console.error('Error logging in user with phone:', error);
    res.status(500).json({
      success: false,
      message: 'Error logging in user',
      error: error.message
    });
  }
});

// @route   GET /api/users
// @desc    Get all users (with pagination)
// @access  Public (will add auth later)
router.get('/', async (req, res) => {
  try {
    const { limit = 20, page = 1 } = req.query;

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const users = await User.find({ isActive: true })
      .select('-password')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(skip);

    const total = await User.countDocuments({ isActive: true });

    res.json({
      success: true,
      data: users,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / parseInt(limit)),
        totalItems: total,
        itemsPerPage: parseInt(limit)
      }
    });

  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching users',
      error: error.message
    });
  }
});

// @route   GET /api/users/:id
// @desc    Get a specific user by ID
// @access  Public (will add auth later)
router.get('/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      data: user
    });

  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching user',
      error: error.message
    });
  }
});

// @route   PUT /api/users/:id
// @desc    Update a user profile
// @access  Public (will add auth later)
router.put('/:id', upload.single('profileImage'), validateUserUpdate, handleValidationErrors, async (req, res) => {
  try {
    const {
      name,
      email,
      phone,
      address,
      notifications
    } = req.body;

    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Store old image URL for deletion
    const oldImageUrl = user.profileImage;

    // Update user data
    if (name) user.name = name;
    if (email) user.email = email.toLowerCase();
    if (phone) user.phone = phone;
    if (address) user.address = JSON.parse(address);
    if (notifications) user.notifications = JSON.parse(notifications);

    // Upload new profile image to Firebase if provided
    if (req.file) {
      try {
        const imageUrl = await firebaseStorage.uploadFile(req.file, 'users');
        user.profileImage = imageUrl;
        
        // Delete old image from Firebase if it exists
        if (oldImageUrl) {
          await firebaseStorage.deleteFile(oldImageUrl);
        }
      } catch (uploadError) {
        console.error('Firebase upload error:', uploadError);
        return res.status(500).json({
          success: false,
          message: 'Error uploading image to Firebase',
          error: uploadError.message
        });
      }
    }

    await user.save();

    // Remove password from response
    const userResponse = user.toObject();
    delete userResponse.password;

    res.json({
      success: true,
      message: 'User profile updated successfully',
      data: userResponse
    });

  } catch (error) {
    console.error('Error updating user profile:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating user profile',
      error: error.message
    });
  }
});

// @route   DELETE /api/users/:id
// @desc    Delete a user (soft delete)
// @access  Public (will add auth later)
router.delete('/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Delete profile image from Firebase before soft deleting
    if (user.profileImage) {
      try {
        await firebaseStorage.deleteFile(user.profileImage);
      } catch (deleteError) {
        console.error('Error deleting image from Firebase:', deleteError);
        // Continue with deletion even if image deletion fails
      }
    }

    // Soft delete - mark as inactive
    user.isActive = false;
    await user.save();

    res.json({
      success: true,
      message: 'User deleted successfully'
    });

  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting user',
      error: error.message
    });
  }
});

// @route   POST /api/users/:id/verify
// @desc    Verify a user account
// @access  Public (will add auth later)
router.post('/:id/verify', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    user.isVerified = true;
    await user.save();

    res.json({
      success: true,
      message: 'User verified successfully',
      data: user
    });

  } catch (error) {
    console.error('Error verifying user:', error);
    res.status(500).json({
      success: false,
      message: 'Error verifying user',
      error: error.message
    });
  }
});

// @route   POST /api/users/:id/update-notifications
// @desc    Update user notification preferences
// @access  Public (will add auth later)
router.post('/:id/update-notifications', async (req, res) => {
  try {
    const { notifications } = req.body;

    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    user.notifications = notifications;
    await user.save();

    res.json({
      success: true,
      message: 'Notification preferences updated successfully',
      data: user.notifications
    });

  } catch (error) {
    console.error('Error updating notification preferences:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating notification preferences',
      error: error.message
    });
  }
});

module.exports = router; 