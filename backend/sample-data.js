const mongoose = require('mongoose');
const User = require('./models/User');
const Pet = require('./models/Pet');
require('dotenv').config({ path: './config.env' });

// Sample user data
const sampleUsers = [
  {
    name: 'John Doe',
    email: 'john@example.com',
    phone: '1234567890',
    password: 'password123',
    address: {
      street: '123 Main St',
      city: 'New York',
      state: 'NY',
      zipCode: '10001',
      country: 'United States'
    },
    isVerified: true
  },
  {
    name: 'Jane Smith',
    email: 'jane@example.com',
    phone: '0987654321',
    password: 'password123',
    address: {
      street: '456 Oak Ave',
      city: 'Los Angeles',
      state: 'CA',
      zipCode: '90210',
      country: 'United States'
    },
    isVerified: true
  },
  {
    name: 'Mike Johnson',
    email: 'mike@example.com',
    phone: '5551234567',
    password: 'password123',
    address: {
      street: '789 Pine Rd',
      city: 'Chicago',
      state: 'IL',
      zipCode: '60601',
      country: 'United States'
    },
    isVerified: true
  }
];

// Sample pet data
const samplePets = [
  {
    petName: 'Buddy',
    petType: 'Dog',
    breed: 'Golden Retriever',
    gender: 'Male',
    color: 'Golden',
    homeLocation: '123 Main St, New York, NY 10001',
    isActive: true,
    isLost: false,
    isFound: false
  },
  {
    petName: 'Whiskers',
    petType: 'Cat',
    breed: 'Persian',
    gender: 'Female',
    color: 'White',
    homeLocation: '456 Oak Ave, Los Angeles, CA 90210',
    isActive: true,
    isLost: false,
    isFound: false
  },
  {
    petName: 'Max',
    petType: 'Dog',
    breed: 'German Shepherd',
    gender: 'Male',
    color: 'Black',
    homeLocation: '789 Pine Rd, Chicago, IL 60601',
    isActive: true,
    isLost: true,
    isFound: false
  },
  {
    petName: 'Luna',
    petType: 'Cat',
    breed: 'Siamese',
    gender: 'Female',
    color: 'Cream',
    homeLocation: '123 Main St, New York, NY 10001',
    isActive: true,
    isLost: false,
    isFound: false
  },
  {
    petName: 'Bunny',
    petType: 'Rabbit',
    breed: 'Holland Lop',
    gender: 'Female',
    color: 'Brown',
    homeLocation: '456 Oak Ave, Los Angeles, CA 90210',
    isActive: true,
    isLost: false,
    isFound: false
  }
];

// Function to seed the database
async function seedDatabase() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Clear existing data
    await User.deleteMany({});
    await Pet.deleteMany({});
    console.log('🗑️  Cleared existing data');

    // Create users
    const createdUsers = await User.insertMany(sampleUsers);
    console.log(`👥 Created ${createdUsers.length} users`);

    // Create pets and assign owners
    const petsWithOwners = samplePets.map((pet, index) => ({
      ...pet,
      ownerId: createdUsers[index % createdUsers.length]._id
    }));

    const createdPets = await Pet.insertMany(petsWithOwners);
    console.log(`🐾 Created ${createdPets.length} pets`);

    console.log('\n📊 Sample Data Summary:');
    console.log(`- Users: ${createdUsers.length}`);
    console.log(`- Pets: ${createdPets.length}`);
    console.log('\n🔗 Sample User IDs:');
    createdUsers.forEach((user, index) => {
      console.log(`  ${index + 1}. ${user.name}: ${user._id}`);
    });

    console.log('\n🔗 Sample Pet IDs:');
    createdPets.forEach((pet, index) => {
      console.log(`  ${index + 1}. ${pet.petName} (${pet.petType}): ${pet._id}`);
    });

    console.log('\n✅ Database seeded successfully!');
    console.log('\n🧪 Test the API:');
    console.log('  GET /api/users - List all users');
    console.log('  GET /api/pets - List all pets');
    console.log('  GET /api/pets/owner/[USER_ID] - Get pets by owner');

  } catch (error) {
    console.error('❌ Error seeding database:', error);
  } finally {
    // Close the connection
    await mongoose.connection.close();
    console.log('🔌 Database connection closed');
  }
}

// Function to clear the database
async function clearDatabase() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    await User.deleteMany({});
    await Pet.deleteMany({});
    console.log('🗑️  Database cleared successfully');

  } catch (error) {
    console.error('❌ Error clearing database:', error);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 Database connection closed');
  }
}

// Export functions for use in other files
module.exports = {
  seedDatabase,
  clearDatabase,
  sampleUsers,
  samplePets
};

// Run seeding if this file is executed directly
if (require.main === module) {
  const command = process.argv[2];
  
  if (command === 'clear') {
    clearDatabase();
  } else {
    seedDatabase();
  }
} 