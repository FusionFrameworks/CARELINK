// const express = require('express');
// const mongoose = require('mongoose');
// const bodyParser = require('body-parser');
// const cors = require('cors');
// const bcrypt = require('bcrypt'); // Import bcrypt for password hashing

// const app = express();
// app.use(bodyParser.json());
// app.use(cors());

// // Connect to MongoDB
// mongoose.connect('mongodb+srv://ashish:goswami@cluster0.trds1g8.mongodb.net/carelink', {
//   useNewUrlParser: true,
//   useUnifiedTopology: true,
// }).then(() => console.log('MongoDB connected')).catch(err => console.log(err));

// // Define Schema
// const userSchema = new mongoose.Schema({
//   email: { type: String, required: true, unique: true }, // Ensure email is unique
//   password: { type: String, required: true },
//   doctorName: { type: String, required: true },
//   specialization: { type: String, required: true },
//   experience: { type: String, required: true },
//   hospitalName: { type: String, required: true },
// });

// // Create User model
// const User = mongoose.model('User', userSchema);

// // Register route
// app.post('/register', async (req, res) => {
//   try {
//     const { email, password, doctorName, specialization, experience, hospitalName } = req.body;

//     // Check if all fields are provided
//     if (!email || !password || !doctorName || !specialization || !experience || !hospitalName) {
//       return res.status(400).json({ error: 'All fields are required' });
//     }

//     // Hash the password before saving
//     const hashedPassword = await bcrypt.hash(password, 10);

//     // Create new user
//     const newUser = new User({
//       email,
//       password: hashedPassword, // Save hashed password
//       doctorName,
//       specialization,
//       experience,
//       hospitalName,
//     });

//     // Save the user to the database
//     await newUser.save();
//     res.status(200).json({ message: 'Registration successful' });
//   } catch (err) {
//     console.error(err);

//     // Handle duplicate email error
//     if (err.code === 11000) {
//       return res.status(400).json({ error: 'Email already exists' });
//     }

//     // Handle validation errors
//     if (err.name === 'ValidationError') {
//       const messages = Object.values(err.errors).map(val => val.message);
//       return res.status(400).json({ error: messages });
//     }

//     res.status(500).json({ error: 'Registration failed' });
//   }
// });

// // Login route
// app.post('/login', async (req, res) => {
//   try {
//     const { email, password } = req.body;

//     // Find user by email
//     const user = await User.findOne({ email });
//     if (!user) {
//       return res.status(404).json({ message: 'User not found' });
//     }

//     // Compare the provided password with the hashed password in the database
//     const isMatch = await bcrypt.compare(password, user.password);
//     if (!isMatch) {
//       return res.status(401).json({ message: 'Invalid credentials' });
//     }

//     // If credentials are valid, return success message
//     res.status(200).json({ message: 'Login successful', user: { email: user.email, doctorName: user.doctorName } });
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ error: 'Login failed' });
//   }
// });

// // Start server
// app.listen(3000, () => console.log('Server running on port 3000'));










// Import required packages
const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const bodyParser = require('body-parser');

// Initialize Express app
const app = express();

// Middleware for parsing JSON data
app.use(bodyParser.json());

// Connect to MongoDB (Replace the connection string with your MongoDB URL)
mongoose.connect('mongodb+srv://ashish:goswami@cluster0.trds1g8.mongodb.net/carelink', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => {
  console.log('Connected to MongoDB');
}).catch((err) => {
  console.error('MongoDB connection error:', err);
});

// Create User schema and model
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  doctorName: { type: String, required: true },
  specialization: { type: String, required: true },
  experience: { type: Number, required: true },
  hospitalName: { type: String, required: true },
});

const User = mongoose.model('User', userSchema);

// Login route
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check if email and password are provided
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    // Compare passwords
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    // Return user details (excluding password)
    res.status(200).json({
      email: user.email,
      doctorName: user.doctorName,
      specialization: user.specialization,
      experience: user.experience,
      hospitalName: user.hospitalName,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Register route (optional)
app.post('/register', async (req, res) => {
  try {
    const { email, password, doctorName, specialization, experience, hospitalName } = req.body;

    // Validate the input fields
    if (!email || !password || !doctorName || !specialization || !experience || !hospitalName) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    // Check if the user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash the password before saving
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create and save the user
    const newUser = new User({
      email,
      password: hashedPassword,
      doctorName,
      specialization,
      experience,
      hospitalName,
    });

    await newUser.save();

    res.status(201).json({ message: 'User registered successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
