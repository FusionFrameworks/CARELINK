const express = require('express');
const cors = require('cors');
const connectDB = require('./utils/db');
const doctorRoutes = require('./routes/doctorRoutes');
const fileRoutes = require('./routes/fileRoutes');
const labTechnicianRoutes = require('./routes/labTechnicianRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Connect to DB
connectDB();

// Routes
app.use('/doctors', doctorRoutes);
app.use('/files', fileRoutes);
app.use('/labtechnicians', labTechnicianRoutes);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
