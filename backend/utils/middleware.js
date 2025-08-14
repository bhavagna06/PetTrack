const multer = require('multer');
const { validationResult } = require('express-validator');

// Configure multer for memory storage (for Firebase upload)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024 // 10MB limit
  },
  fileFilter: function (req, file, cb) {
    console.log('File upload attempt:', {
      originalname: file.originalname,
      mimetype: file.mimetype,
      size: file.size
    });
    
    // Accept only images - check both MIME type and file extension
    const isImageMimeType = file.mimetype.startsWith('image/');
    const hasImageExtension = /\.(jpg|jpeg|png|gif|webp)$/i.test(file.originalname);
    
    if (isImageMimeType || hasImageExtension) {
      console.log('File accepted:', file.originalname);
      cb(null, true);
    } else {
      console.log('File rejected:', file.originalname, 'MIME type:', file.mimetype);
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

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

module.exports = {
  upload,
  handleValidationErrors
};
