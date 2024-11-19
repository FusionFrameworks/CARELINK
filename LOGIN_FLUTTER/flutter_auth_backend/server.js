
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

const User = mongoose.model('Doctor', userSchema);

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


// Update profile route
app.put('/profile', async (req, res) => {
  try {
    const { email, doctorName, specialization, experience, hospitalName } = req.body;

    // Check if email is provided (assuming email is the identifier)
    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    // Find the user by email and update the fields
    const updatedUser = await User.findOneAndUpdate(
      { email },
      { doctorName, specialization, experience, hospitalName },
      { new: true } // Return the updated document
    );

    if (!updatedUser) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.status(200).json({
      message: 'Profile updated successfully',
      user: {
        email: updatedUser.email,
        doctorName: updatedUser.doctorName,
        specialization: updatedUser.specialization,
        experience: updatedUser.experience,
        hospitalName: updatedUser.hospitalName,
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});


// Create LabTechnician schema and model
const labTechnicianSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  technicianName: { type: String, required: true },
  
});

const LabTechnician = mongoose.model('LabTechnician', labTechnicianSchema);

// Lab Technician Login route
app.post('/labtechnician/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const technician = await LabTechnician.findOne({ email });
    if (!technician) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    const isMatch = await bcrypt.compare(password, technician.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    res.status(200).json({
      email: technician.email,
      technicianName: technician.technicianName,
      department: technician.department,
      experience: technician.experience,
      labName: technician.labName,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Lab Technician Register route
app.post('/labtechnician/register', async (req, res) => {
  try {
    console.log(req.body); // Log the request body to see if it's correct

    const { email, password, technicianName } = req.body;

    if (!email || !password || !technicianName) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    const existingTechnician = await LabTechnician.findOne({ email });
    if (existingTechnician) {
      return res.status(400).json({ error: 'Lab technician already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newTechnician = new LabTechnician({
      email,
      password: hashedPassword,
      technicianName,
    });

    await newTechnician.save();

    res.status(201).json({ message: 'Lab technician registered successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});
app.put('/labtechnician/profile', async (req, res) => {
  const { currentEmail, email, password } = req.body;
  const technician = await LabTechnician.findOne({ email: currentEmail });
  if (!technician) {
    return res.status(404).json({ error: 'Lab Technician not found' });
  }

  // Update and save
  technician.email = email;
  technician.password = password; // Ensure proper hashing
  await technician.save();
  res.status(200).json({ message: 'Profile updated successfully' });
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});