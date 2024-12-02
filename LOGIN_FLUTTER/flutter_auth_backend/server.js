
// Import required packages
const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const bodyParser = require('body-parser');
const fs = require('fs');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000; // Ensure PORT is declared here

// Middleware
app.use(cors());
app.use(express.json());
app.use(bodyParser.json());

// Connect to MongoDB (Replace with your connection string)
mongoose
  .connect('mongodb+srv://rakshitharakshitha6242:raksh@cluster0.rdl2otz.mongodb.net/carelink', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log('Connected to MongoDB');
  })
  .catch((err) => {
    console.error('MongoDB connection error:', err);
  });



// Create a schema and model for uploaded files
const fileSchema = new mongoose.Schema({
  fileName: { type: String, required: true },
  filePath: { type: String, required: true },
  uploadDate: { type: Date, default: Date.now },
});

const File = mongoose.model('File', fileSchema);

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Ensure this directory exists
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const upload = multer({ storage: storage });

// File upload route
app.post('/upload', upload.single('labReport'), async (req, res) => {
  if (!req.file) {
    return res.status(400).send('No file uploaded');
  }

  try {
    // Save file metadata to MongoDB
    const newFile = new File({
      fileName: req.file.originalname,
      filePath: req.file.path,
    });

    await newFile.save();

    res.status(200).send({
      message: 'File uploaded successfully',
      fileName: req.file.originalname,
      filePath: req.file.path,
    });
  } catch (error) {
    console.error('Error saving file to database:', error);
    res.status(500).send('Error saving file to database');
  }
});

// Fetch uploaded reports
app.get('/reports', async (req, res) => {
  try {
    const files = await File.find();
    res.status(200).json(files);
  } catch (error) {
    console.error('Error fetching reports:', error);
    res.status(500).send('Failed to fetch reports');
  }
});

// Serve uploaded files statically
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Edit a report's metadata
app.put('/reports/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { fileName } = req.body;

    const updatedReport = await File.findByIdAndUpdate(
      id,
      { fileName },
      { new: true } // Return the updated document
    );

    if (!updatedReport) {
      return res.status(404).send('Report not found');
    }

    res.status(200).json(updatedReport);
  } catch (error) {
    console.error('Error editing report:', error);
    res.status(500).send('Failed to edit report');
  }
});




// Delete a lab report
app.delete('/reports/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Find the report in the database
    const report = await File.findById(id);
    if (!report) {
      return res.status(404).send('Report not found');
    }

    // Remove the file from the server
    fs.unlinkSync(report.filePath);

    // Remove the report metadata from the database
    await File.findByIdAndDelete(id);

    res.status(200).json({ message: 'Report deleted successfully' });
  } catch (error) {
    console.error('Error deleting report:', error);
    res.status(500).send('Failed to delete report');
  }
});

// Modify a lab report's metadata
app.put('/reports/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { fileName } = req.body;

    const updatedReport = await File.findByIdAndUpdate(
      id,
      { fileName },
      { new: true } // Return the updated document
    );

    if (!updatedReport) {
      return res.status(404).send('Report not found');
    }

    res.status(200).json(updatedReport);
  } catch (error) {
    console.error('Error editing report:', error);
    res.status(500).send('Failed to edit report');
  }
});


// Doctor Schema & Model
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  doctorName: { type: String, required: true },
  specialization: { type: String, required: true },
  experience: { type: Number, required: true },
  hospitalName: { type: String, required: true },
});
const User = mongoose.model('Doctor', userSchema);

// Doctor Login
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    res.status(200).json({
      email: user.email,
      doctorName: user.doctorName,
      specialization: user.specialization,
      experience: user.experience,
      hospitalName: user.hospitalName,
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Doctor Registration
app.post('/register', async (req, res) => {
  try {
    const { email, password, doctorName, specialization, experience, hospitalName } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

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
    res.status(500).json({ error: 'Server error' });
  }
});

// Lab Technician Schema & Model
const labTechnicianSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  technicianName: { type: String, required: true },
});
const LabTechnician = mongoose.model('LabTechnician', labTechnicianSchema);

// Lab Technician Login
app.post('/labtechnician/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const technician = await LabTechnician.findOne({ email });
    if (!technician || !(await bcrypt.compare(password, technician.password))) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    res.status(200).json({
      email: technician.email,
      technicianName: technician.technicianName,
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Lab Technician Registration
app.post('/labtechnician/register', async (req, res) => {
  try {
    const { email, password, technicianName } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    const newTechnician = new LabTechnician({
      email,
      password: hashedPassword,
      technicianName,
    });

    await newTechnician.save();
    res.status(201).json({ message: 'Lab technician registered successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
