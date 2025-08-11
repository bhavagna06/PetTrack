const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

// Test data
const testUser = {
  name: 'Test User',
  email: 'test@example.com',
  phone: '5551234567',
  password: 'testpassword123'
};

const testPet = {
  petName: 'Test Pet',
  petType: 'Dog',
  breed: 'Golden Retriever',
  gender: 'Male',
  color: 'Golden',
  homeLocation: '123 Test St, Test City, TS 12345'
};

let userId = null;
let petId = null;

// Helper function to log results
function logResult(testName, success, data = null, error = null) {
  const status = success ? '✅ PASS' : '❌ FAIL';
  console.log(`${status} ${testName}`);
  if (data) console.log('   Data:', JSON.stringify(data, null, 2));
  if (error) console.log('   Error:', error.message || error);
  console.log('');
}

// Test functions
async function testHealthCheck() {
  try {
    const response = await axios.get(`${BASE_URL}/health`);
    logResult('Health Check', response.status === 200, response.data);
    return true;
  } catch (error) {
    logResult('Health Check', false, null, error);
    return false;
  }
}

async function testUserRegistration() {
  try {
    const response = await axios.post(`${BASE_URL}/api/users/register`, testUser);
    userId = response.data.data._id;
    logResult('User Registration', response.status === 201, response.data);
    return true;
  } catch (error) {
    logResult('User Registration', false, null, error.response?.data || error);
    return false;
  }
}

async function testUserLogin() {
  try {
    const response = await axios.post(`${BASE_URL}/api/users/login`, {
      email: testUser.email,
      password: testUser.password
    });
    logResult('User Login', response.status === 200, response.data);
    return true;
  } catch (error) {
    logResult('User Login', false, null, error.response?.data || error);
    return false;
  }
}

async function testCreatePet() {
  if (!userId) {
    logResult('Create Pet', false, null, 'No user ID available');
    return false;
  }

  try {
    const petData = { ...testPet, ownerId: userId };
    const response = await axios.post(`${BASE_URL}/api/pets`, petData);
    petId = response.data.data._id;
    logResult('Create Pet', response.status === 201, response.data);
    return true;
  } catch (error) {
    logResult('Create Pet', false, null, error.response?.data || error);
    return false;
  }
}

async function testGetPets() {
  try {
    const response = await axios.get(`${BASE_URL}/api/pets`);
    logResult('Get All Pets', response.status === 200, {
      count: response.data.data.length,
      pagination: response.data.pagination
    });
    return true;
  } catch (error) {
    logResult('Get All Pets', false, null, error.response?.data || error);
    return false;
  }
}

async function testGetPetById() {
  if (!petId) {
    logResult('Get Pet by ID', false, null, 'No pet ID available');
    return false;
  }

  try {
    const response = await axios.get(`${BASE_URL}/api/pets/${petId}`);
    logResult('Get Pet by ID', response.status === 200, response.data);
    return true;
  } catch (error) {
    logResult('Get Pet by ID', false, null, error.response?.data || error);
    return false;
  }
}

async function testUpdatePet() {
  if (!petId) {
    logResult('Update Pet', false, null, 'No pet ID available');
    return false;
  }

  try {
    const updateData = { ...testPet, petName: 'Updated Test Pet', ownerId: userId };
    const response = await axios.put(`${BASE_URL}/api/pets/${petId}`, updateData);
    logResult('Update Pet', response.status === 200, response.data);
    return true;
  } catch (error) {
    logResult('Update Pet', false, null, error.response?.data || error);
    return false;
  }
}

async function testGetPetsByOwner() {
  if (!userId) {
    logResult('Get Pets by Owner', false, null, 'No user ID available');
    return false;
  }

  try {
    const response = await axios.get(`${BASE_URL}/api/pets/owner/${userId}`);
    logResult('Get Pets by Owner', response.status === 200, {
      count: response.data.data.length,
      pets: response.data.data.map(pet => ({ id: pet._id, name: pet.petName }))
    });
    return true;
  } catch (error) {
    logResult('Get Pets by Owner', false, null, error.response?.data || error);
    return false;
  }
}

async function testGetUsers() {
  try {
    const response = await axios.get(`${BASE_URL}/api/users`);
    logResult('Get All Users', response.status === 200, {
      count: response.data.data.length,
      pagination: response.data.pagination
    });
    return true;
  } catch (error) {
    logResult('Get All Users', false, null, error.response?.data || error);
    return false;
  }
}

async function testDeletePet() {
  if (!petId) {
    logResult('Delete Pet', false, null, 'No pet ID available');
    return false;
  }

  try {
    const response = await axios.delete(`${BASE_URL}/api/pets/${petId}`);
    logResult('Delete Pet', response.status === 200, response.data);
    return true;
  } catch (error) {
    logResult('Delete Pet', false, null, error.response?.data || error);
    return false;
  }
}

async function testDeleteUser() {
  if (!userId) {
    logResult('Delete User', false, null, 'No user ID available');
    return false;
  }

  try {
    const response = await axios.delete(`${BASE_URL}/api/users/${userId}`);
    logResult('Delete User', response.status === 200, response.data);
    return true;
  } catch (error) {
    logResult('Delete User', false, null, error.response?.data || error);
    return false;
  }
}

async function testMarkPetAsLost() {
  if (!petId) {
    logResult('Mark Pet as Lost', false, null, 'No pet ID available');
    return false;
  }

  try {
    const response = await axios.post(`${BASE_URL}/api/pets/${petId}/mark-lost`);
    logResult('Mark Pet as Lost', response.status === 200, response.data);
    return true;
  } catch (error) {
    logResult('Mark Pet as Lost', false, null, error.response?.data || error);
    return false;
  }
}

async function testMarkPetAsFound() {
  if (!petId) {
    logResult('Mark Pet as Found', false, null, 'No pet ID available');
    return false;
  }

  try {
    const response = await axios.post(`${BASE_URL}/api/pets/${petId}/mark-found`);
    logResult('Mark Pet as Found', response.status === 200, response.data);
    return true;
  } catch (error) {
    logResult('Mark Pet as Found', false, null, error.response?.data || error);
    return false;
  }
}

async function testGetLostPets() {
  try {
    const response = await axios.get(`${BASE_URL}/api/pets?isLost=true`);
    logResult('Get Lost Pets', response.status === 200, {
      count: response.data.data.length,
      pagination: response.data.pagination
    });
    return true;
  } catch (error) {
    logResult('Get Lost Pets', false, null, error.response?.data || error);
    return false;
  }
}

async function testGetFoundPets() {
  try {
    const response = await axios.get(`${BASE_URL}/api/pets?isFound=true`);
    logResult('Get Found Pets', response.status === 200, {
      count: response.data.data.length,
      pagination: response.data.pagination
    });
    return true;
  } catch (error) {
    logResult('Get Found Pets', false, null, error.response?.data || error);
    return false;
  }
}

// Main test runner
async function runTests() {
  console.log('🧪 Starting PetTrack API Tests...\n');
  console.log(`📍 Testing against: ${BASE_URL}\n`);

  const tests = [
    { name: 'Health Check', fn: testHealthCheck },
    { name: 'User Registration', fn: testUserRegistration },
    { name: 'User Login', fn: testUserLogin },
    { name: 'Create Pet', fn: testCreatePet },
    { name: 'Get All Pets', fn: testGetPets },
    { name: 'Get Pet by ID', fn: testGetPetById },
    { name: 'Update Pet', fn: testUpdatePet },
    { name: 'Get Pets by Owner', fn: testGetPetsByOwner },
    { name: 'Get All Users', fn: testGetUsers },
    { name: 'Mark Pet as Lost', fn: testMarkPetAsLost },
    { name: 'Get Lost Pets', fn: testGetLostPets },
    { name: 'Mark Pet as Found', fn: testMarkPetAsFound },
    { name: 'Get Found Pets', fn: testGetFoundPets },
    { name: 'Delete Pet', fn: testDeletePet },
    { name: 'Delete User', fn: testDeleteUser }
  ];

  let passedTests = 0;
  let totalTests = tests.length;

  for (const test of tests) {
    console.log(`🔍 Running: ${test.name}`);
    const success = await test.fn();
    if (success) passedTests++;
  }

  console.log('📊 Test Results Summary:');
  console.log(`✅ Passed: ${passedTests}/${totalTests}`);
  console.log(`❌ Failed: ${totalTests - passedTests}/${totalTests}`);
  
  if (passedTests === totalTests) {
    console.log('\n🎉 All tests passed! The API is working correctly.');
  } else {
    console.log('\n⚠️  Some tests failed. Please check the server and try again.');
  }
}

// Run tests if this file is executed directly
if (require.main === module) {
  runTests().catch(console.error);
}

module.exports = {
  runTests,
  testHealthCheck,
  testUserRegistration,
  testUserLogin,
  testCreatePet,
  testGetPets,
  testGetPetById,
  testUpdatePet,
  testGetPetsByOwner,
  testGetUsers,
  testMarkPetAsLost,
  testMarkPetAsFound,
  testGetLostPets,
  testGetFoundPets,
  testDeletePet,
  testDeleteUser
}; 