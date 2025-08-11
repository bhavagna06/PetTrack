const mongoose = require('mongoose');

const petSchema = new mongoose.Schema({
  // Basic Information
  petName: {
    type: String,
    required: [true, 'Pet name is required'],
    trim: true,
    maxlength: [50, 'Pet name cannot exceed 50 characters']
  },
  
  petType: {
    type: String,
    required: [true, 'Pet type is required'],
    enum: {
      values: ['Dog', 'Cat', 'Rabbit', 'Hamster', 'Guinea Pig', 'Bird', 'Other'],
      message: 'Please select a valid pet type'
    }
  },
  
  breed: {
    type: String,
    required: [true, 'Breed is required'],
    trim: true,
    maxlength: [100, 'Breed name cannot exceed 100 characters']
  },

  gender: {
    type: String,
    required: [true, 'Gender is required'],
    enum:{
      values: ['Male', 'Female'],
      message: 'Please mention the gender'
    }
  },
  
  color: {
    type: String,
    required: [true, 'Color is required'],
    enum: {
      values: ['Black', 'White', 'Brown', 'Golden', 'Gray', 'Orange', 'Cream', 'Multi-colored', 'Other'],
      message: 'Please select a valid color'
    }
  },
  
  homeLocation: {
    type: String,
    required: [true, 'Home location is required'],
    trim: true,
    maxlength: [200, 'Home location cannot exceed 200 characters']
  },
  
  // Images (Firebase URLs)
  profileImage: {
    type: String,
    default: null
  },
  
  additionalPhotos: [{
    type: String
  }],
  
  // Owner Information
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Owner ID is required']
  },
  
  // Metadata
  isActive: {
    type: Boolean,
    default: true
  },
  
  isLost: {
    type: Boolean,
    default: false
  },
  
  isFound: {
    type: Boolean,
    default: false
  },
  
  // Timestamps
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Index for better query performance
petSchema.index({ ownerId: 1, isActive: 1 });
petSchema.index({ petType: 1, breed: 1 });
petSchema.index({ isLost: 1, isFound: 1 });

// Virtual for pet age (if we add birth date later)
petSchema.virtual('age').get(function() {
  // TODO: Calculate age from birth date when added
  return null;
});

// Pre-save middleware to update the updatedAt field
petSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Static method to get pets by owner
petSchema.statics.findByOwner = function(ownerId) {
  return this.find({ ownerId, isActive: true }).sort({ createdAt: -1 });
};

// Static method to get lost pets
petSchema.statics.findLostPets = function() {
  return this.find({ isLost: true, isActive: true }).sort({ createdAt: -1 });
};

// Static method to get found pets
petSchema.statics.findFoundPets = function() {
  return this.find({ isFound: true, isActive: true }).sort({ createdAt: -1 });
};

// Instance method to mark pet as lost
petSchema.methods.markAsLost = function() {
  this.isLost = true;
  this.isFound = false;
  return this.save();
};

// Instance method to mark pet as found
petSchema.methods.markAsFound = function() {
  this.isFound = true;
  this.isLost = false;
  return this.save();
};

// Instance method to deactivate pet
petSchema.methods.deactivate = function() {
  this.isActive = false;
  return this.save();
};

module.exports = mongoose.model('Pet', petSchema); 