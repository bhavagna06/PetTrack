const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');
require('dotenv').config({ path: './config.env' });

// Initialize Firebase (this will be done in the config file)
require('./config/firebase');

// Import routes
const petRoutes = require('./routes/petRoutes');
const userRoutes = require('./routes/userRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Set EJS as templating engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Serve static files
app.use('/public', express.static(path.join(__dirname, 'public')));

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI)
.then(() => {
  console.log('✅ Connected to MongoDB successfully');
})
.catch((err) => {
  console.error('❌ MongoDB connection error:', err);
  process.exit(1);
});

// Routes
app.use('/api/pets', petRoutes);
app.use('/api/users', userRoutes);

// Home route
app.get('/', (req, res) => {
  res.render('index', { 
    title: 'PetTrack Backend',
    message: 'Welcome to PetTrack API'
  });
});

// Health check route
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'PetTrack Backend is running',
    timestamp: new Date().toISOString()
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: 'Something went wrong!',
    message: err.message 
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Route not found',
    path: req.originalUrl 
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server is running on port ${PORT}`);
  console.log(`📱 PetTrack Backend API: http://localhost:${PORT}`);
  console.log(`🔍 Health Check: http://localhost:${PORT}/health`);
}); 