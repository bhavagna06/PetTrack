const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const multer = require('multer');
const Pet = require('../models/Pet');
const { body } = require('express-validator');
const { firebaseStorage } = require('../config/firebase');
const { upload, handleValidationErrors } = require('../utils/middleware');

// Validation middleware
const validatePetData = [
  body('petName')
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Pet name must be between 1 and 50 characters'),
  
  body('petType')
    .isIn(['Dog', 'Cat', 'Rabbit', 'Hamster', 'Guinea Pig', 'Bird', 'Other'])
    .withMessage('Please select a valid pet type'),
  
  body('breed')
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Breed must be between 1 and 100 characters'),

  body('gender')
    .isIn(['Male', 'Female'])
    .withMessage('Please select a valid gender'),
  
  body('color')
    .isIn(['Black', 'White', 'Brown', 'Golden', 'Gray', 'Orange', 'Cream', 'Multi-colored', 'Other'])
    .withMessage('Please select a valid color'),
  
  body('homeLocation')
    .trim()
    .isLength({ min: 1, max: 200 })
    .withMessage('Home location must be between 1 and 200 characters'),
  
  body('ownerId')
    .isMongoId()
    .withMessage('Valid owner ID is required')
];



// @route   POST /api/pets
// @desc    Create a new pet profile
// @access  Public (for now, will add auth later)
router.post('/', upload.single('profileImage'), validatePetData, handleValidationErrors, async (req, res) => {
  try {
    const {
      petName,
      petType,
      breed,
      gender,
      color,
      homeLocation,
      ownerId,
      registrationType = 'registered' // Default to registered
    } = req.body;

    // Create pet object
    const petData = {
      petName,
      petType,
      breed,
      gender,
      color,
      homeLocation,
      ownerId,
      registrationType
    };

    // Upload profile image to Firebase if provided
    if (req.file) {
      try {
        console.log('Uploading profile image to Firebase Storage...');
        const imageUrl = await firebaseStorage.uploadFile(req.file, 'pets');
        petData.profileImage = imageUrl;
        console.log('Profile image uploaded successfully to Firebase:', imageUrl);
      } catch (uploadError) {
        console.error('Firebase upload error:', uploadError);
        return res.status(500).json({
          success: false,
          message: 'Error uploading image to Firebase Storage',
          error: uploadError.message
        });
      }
    }

    const pet = new Pet(petData);
    await pet.save();

    res.status(201).json({
      success: true,
      message: 'Pet profile created successfully',
      data: pet
    });

  } catch (error) {
    console.error('Error creating pet profile:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating pet profile',
      error: error.message
    });
  }
});

// @route   GET /api/pets
// @desc    Get all pets (with optional filters)
// @access  Public
router.get('/', async (req, res) => {
  try {
    const {
      ownerId,
      petType,
      isLost,
      isFound,
      registrationType,
      limit = 20,
      page = 1
    } = req.query;

    // Build filter object
    const filter = { isActive: true };
    
    // Validate ownerId is a valid MongoDB ObjectId before adding to filter
    if (ownerId) {
      if (mongoose.Types.ObjectId.isValid(ownerId)) {
        filter.ownerId = ownerId;
      } else {
        console.log('Invalid ownerId format, skipping ownerId filter:', ownerId);
        // Don't add invalid ownerId to filter - this allows public access
      }
    }
    if (petType) filter.petType = petType;
    if (isLost !== undefined) filter.isLost = isLost === 'true';
    if (isFound !== undefined) filter.isFound = isFound === 'true';
    if (registrationType) filter.registrationType = registrationType;

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const pets = await Pet.find(filter)
      .populate('ownerId', 'name email phone')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(skip);

    const total = await Pet.countDocuments(filter);

    res.json({
      success: true,
      data: pets,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / parseInt(limit)),
        totalItems: total,
        itemsPerPage: parseInt(limit)
      }
    });

  } catch (error) {
    console.error('Error fetching pets:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching pets',
      error: error.message
    });
  }
});

// @route   GET /api/pets/:id
// @desc    Get a specific pet by ID
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const pet = await Pet.findById(req.params.id)
      .populate('ownerId', 'name email phone');

    if (!pet) {
      return res.status(404).json({
        success: false,
        message: 'Pet not found'
      });
    }

    res.json({
      success: true,
      data: pet
    });

  } catch (error) {
    console.error('Error fetching pet:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching pet',
      error: error.message
    });
  }
});

// @route   PUT /api/pets/:id
// @desc    Update a pet profile
// @access  Public (will add auth later)
router.put('/:id', upload.single('profileImage'), validatePetData, handleValidationErrors, async (req, res) => {
  try {
    const {
      petName,
      petType,
      breed,
      gender,
      color,
      homeLocation,
      ownerId
    } = req.body;

    const pet = await Pet.findById(req.params.id);

    if (!pet) {
      return res.status(404).json({
        success: false,
        message: 'Pet not found'
      });
    }

    // Store old image URL for deletion
    const oldImageUrl = pet.profileImage;

    // Update pet data
    pet.petName = petName;
    pet.petType = petType;
    pet.breed = breed;
    pet.gender = gender;
    pet.color = color;
    pet.homeLocation = homeLocation;
    pet.ownerId = ownerId;

    // Upload new profile image to Firebase if provided
    if (req.file) {
      try {
        const imageUrl = await firebaseStorage.uploadFile(req.file, 'pets');
        pet.profileImage = imageUrl;
        
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

    await pet.save();

    res.json({
      success: true,
      message: 'Pet profile updated successfully',
      data: pet
    });

  } catch (error) {
    console.error('Error updating pet profile:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating pet profile',
      error: error.message
    });
  }
});

// @route   DELETE /api/pets/:id
// @desc    Delete a pet profile (soft delete)
// @access  Public (will add auth later)
router.delete('/:id', async (req, res) => {
  try {
    const pet = await Pet.findById(req.params.id);

    if (!pet) {
      return res.status(404).json({
        success: false,
        message: 'Pet not found'
      });
    }

    // Delete images from Firebase before soft deleting
    try {
      const imagesToDelete = [pet.profileImage, ...pet.additionalPhotos].filter(Boolean);
      if (imagesToDelete.length > 0) {
        await firebaseStorage.deleteMultipleFiles(imagesToDelete);
      }
    } catch (deleteError) {
      console.error('Error deleting images from Firebase:', deleteError);
      // Continue with deletion even if image deletion fails
    }

    // Soft delete - mark as inactive
    pet.isActive = false;
    await pet.save();

    res.json({
      success: true,
      message: 'Pet profile deleted successfully'
    });

  } catch (error) {
    console.error('Error deleting pet profile:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting pet profile',
      error: error.message
    });
  }
});

// @route   POST /api/pets/:id/upload-photos
// @desc    Upload additional photos for a pet
// @access  Public (will add auth later)
router.post('/:id/upload-photos', upload.array('photos', 2), (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    console.error('Multer error:', err);
    return res.status(400).json({
      success: false,
      message: 'File upload error',
      error: err.message
    });
  } else if (err) {
    console.error('Upload error:', err);
    return res.status(400).json({
      success: false,
      message: err.message,
      error: 'Only image files are allowed!'
    });
  }
  next();
}, async (req, res) => {
  try {
    console.log('Upload photos request received for pet:', req.params.id);
    console.log('Files received:', req.files ? req.files.length : 0);
    
    const pet = await Pet.findById(req.params.id);

    if (!pet) {
      return res.status(404).json({
        success: false,
        message: 'Pet not found'
      });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No photos uploaded'
      });
    }

    try {
      console.log('Uploading additional photos to Firebase Storage...');
      // Upload photos to Firebase
      const imageUrls = await firebaseStorage.uploadMultipleFiles(req.files, 'pets');
      
      // Add new photos to the pet's additionalPhotos array
      pet.additionalPhotos.push(...imageUrls);
      await pet.save();

      res.json({
        success: true,
        message: 'Photos uploaded successfully to Firebase Storage',
        data: {
          petId: pet._id,
          newPhotos: imageUrls,
          totalPhotos: pet.additionalPhotos.length
        }
      });
    } catch (uploadError) {
      console.error('Firebase upload error:', uploadError);
      return res.status(500).json({
        success: false,
        message: 'Error uploading photos to Firebase Storage',
        error: uploadError.message
      });
    }

  } catch (error) {
    console.error('Error uploading photos:', error);
    res.status(500).json({
      success: false,
      message: 'Error uploading photos',
      error: error.message
    });
  }
});

// @route   POST /api/pets/:id/mark-lost
// @desc    Mark a pet as lost
// @access  Public (will add auth later)
router.post('/:id/mark-lost', async (req, res) => {
  try {
    const pet = await Pet.findById(req.params.id);

    if (!pet) {
      return res.status(404).json({
        success: false,
        message: 'Pet not found'
      });
    }

    await pet.markAsLost();

    res.json({
      success: true,
      message: 'Pet marked as lost successfully',
      data: pet
    });

  } catch (error) {
    console.error('Error marking pet as lost:', error);
    res.status(500).json({
      success: false,
      message: 'Error marking pet as lost',
      error: error.message
    });
  }
});

// @route   POST /api/pets/:id/mark-found
// @desc    Mark a pet as found
// @access  Public (will add auth later)
router.post('/:id/mark-found', async (req, res) => {
  try {
    const pet = await Pet.findById(req.params.id);

    if (!pet) {
      return res.status(404).json({
        success: false,
        message: 'Pet not found'
      });
    }

    await pet.markAsFound();

    res.json({
      success: true,
      message: 'Pet marked as found successfully',
      data: pet
    });

  } catch (error) {
    console.error('Error marking pet as found:', error);
    res.status(500).json({
      success: false,
      message: 'Error marking pet as found',
      error: error.message
    });
  }
});

// @route   GET /api/pets/owner/:ownerId
// @desc    Get all pets for a specific owner
// @access  Public
router.get('/owner/:ownerId', async (req, res) => {
  try {
    const pets = await Pet.findByOwner(req.params.ownerId)
      .populate('ownerId', 'name email phone');

    res.json({
      success: true,
      data: pets
    });

  } catch (error) {
    console.error('Error fetching owner pets:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching owner pets',
      error: error.message
    });
  }
});

module.exports = router; 