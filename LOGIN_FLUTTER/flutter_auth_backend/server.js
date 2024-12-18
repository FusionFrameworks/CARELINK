// const express = require('express');
// const cors = require('cors');
// const connectDB = require('./utils/db');
// const doctorRoutes = require('./routes/doctorRoutes');
// const fileRoutes = require('./routes/fileRoutes');
// const labTechnicianRoutes = require('./routes/labTechnicianRoutes');
// const multer = require('multer');
// const fs = require('fs');
// const path = require('path');
// const File = require('./models/fileModel');
// const app = express();
// const PORT = process.env.PORT || 3000;

// // // Middleware
// app.use(cors());
// app.use(express.json());
// app.use('/uploads', express.static('uploads'));

// // Connect to DB
// connectDB();

// // // Routes
// app.use('/doctors', doctorRoutes);
// app.use('/files', fileRoutes);
// app.use('/labtechnicians', labTechnicianRoutes);

// // Middleware
// app.use(cors());
// app.use(express.json());
// app.use('/uploads', express.static('uploads'));

// // Multer configuration for file upload
// const storage = multer.diskStorage({
//   destination: (req, file, cb) => {
//     cb(null, 'uploads/'); // Ensure this directory exists
//   },
//   filename: (req, file, cb) => {
//     cb(null, `${Date.now()}-${file.originalname}`);
//   },
// });

// const upload = multer({ storage: storage });

// // File upload route
// app.post('/upload', upload.single('labReport'), async (req, res) => {
//   if (!req.file) {
//     return res.status(400).send('No file uploaded');
//   }

//   try {
//     // Save file metadata to MongoDB
//     const newFile = new File({
//       fileName: req.file.originalname,
//       filePath: req.file.path,
//     });

//     await newFile.save();

//     res.status(200).send({
//       message: 'File uploaded successfully',
//       fileName: req.file.originalname,
//       filePath: req.file.path,
//     });
//   } catch (error) {
//     console.error('Error saving file to database:', error);
//     res.status(500).send('Error saving file to database');
//   }
// });

// // Fetch uploaded reports
// app.get('/reports', async (req, res) => {
//   try {
//     const files = await File.find();
//     res.status(200).json(files);
//   } catch (error) {
//     console.error('Error fetching reports:', error);
//     res.status(500).send('Failed to fetch reports');
//   }
// });

// // Serve uploaded files statically
// app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// // Delete a lab report
// app.delete('/reports/:id', async (req, res) => {
//   try {
//     const { id } = req.params;

//     // Find the report in the database
//     const report = await File.findById(id);
//     if (!report) {
//       return res.status(404).send('Report not found');
//     }

//     // Remove the file from the server
//     fs.unlinkSync(report.filePath);

//     // Remove the report metadata from the database
//     await File.findByIdAndDelete(id);

//     res.status(200).json({ message: 'Report deleted successfully' });
//   } catch (error) {
//     console.error('Error deleting report:', error);
//     res.status(500).send('Failed to delete report');
//   }
// });

// app.listen(PORT, () => {
//   console.log(`Server running on port ${PORT}`);
// });

// const express = require('express');
// const cors = require('cors');
// const connectDB = require('./utils/db');
// const doctorRoutes = require('./routes/doctorRoutes');
// const fileRoutes = require('./routes/fileRoutes');
// const labTechnicianRoutes = require('./routes/labTechnicianRoutes');
// const multer = require('multer');
// const fs = require('fs');
// const path = require('path');
// const File = require('./models/fileModel');
// const socketIO = require('socket.io');
// const app = express();
// const http = require('http').Server(app);
// const io = socketIO(http, {
//   cors: {
//     origin: "http://localhost:3000", // Make sure to replace with the correct frontend URL
//     methods: ["GET", "POST"],
//   },
// });

// const PORT = process.env.PORT || 3000;

// // Middleware
// app.use(cors());
// app.use(express.json());
// app.use('/uploads', express.static('uploads'));

// // Connect to DB
// connectDB();

// // Routes
// app.use('/doctors', doctorRoutes);
// app.use('/files', fileRoutes);
// app.use('/labtechnicians', labTechnicianRoutes);

// // Multer configuration for file upload
// const storage = multer.diskStorage({
//   destination: (req, file, cb) => {
//     cb(null, 'uploads/');
//   },
//   filename: (req, file, cb) => {
//     cb(null, `${Date.now()}-${file.originalname}`);
//   },
// });

// const upload = multer({ storage: storage });

// // File upload route
// app.post('/upload', upload.single('labReport'), async (req, res) => {
//   if (!req.file) {
//     return res.status(400).send('No file uploaded');
//   }

//   try {
//     const newFile = new File({
//       fileName: req.file.originalname,
//       filePath: req.file.path,
//     });

//     await newFile.save();

//     // Emit event to notify frontend about the new lab report
//     io.emit('newLabReport', {
//       fileName: req.file.originalname,
//       filePath: req.file.path,
//     });

//     res.status(200).send({
//       message: 'File uploaded successfully',
//       fileName: req.file.originalname,
//       filePath: req.file.path,
//     });
//   } catch (error) {
//     console.error('Error saving file to database:', error);
//     res.status(500).send('Error saving file to database');
//   }
// });

// // Fetch uploaded reports
// app.get('/reports', async (req, res) => {
//   try {
//     const files = await File.find();
//     res.status(200).json(files);
//   } catch (error) {
//     console.error('Error fetching reports:', error);
//     res.status(500).send('Failed to fetch reports');
//   }
// });

// // Delete a lab report
// app.delete('/reports/:id', async (req, res) => {
//   try {
//     const { id } = req.params;
//     const report = await File.findById(id);
//     if (!report) {
//       return res.status(404).send('Report not found');
//     }

//     fs.unlinkSync(report.filePath);
//     await File.findByIdAndDelete(id);

//     res.status(200).json({ message: 'Report deleted successfully' });
//   } catch (error) {
//     console.error('Error deleting report:', error);
//     res.status(500).send('Failed to delete report');
//   }
// });

// // WebSocket event listener for new lab reports
// io.on('connection', (socket) => {
//   console.log('New client connected');

//   socket.on('disconnect', () => {
//     console.log('Client disconnected');
//   });

//   socket.on('error', (err) => {
//     console.log('Socket Error:', err);
//   });
// });

// // Start server
// http.listen(PORT, () => {
//   console.log(`Server running on port ${PORT}`);
// });

const express = require("express");
const cors = require("cors");
const connectDB = require("./utils/db");
const doctorRoutes = require("./routes/doctorRoutes");
const fileRoutes = require("./routes/fileRoutes");
const labTechnicianRoutes = require("./routes/labTechnicianRoutes");
const multer = require("multer");
const fs = require("fs");
const path = require("path");
const File = require("./models/fileModel");
const socketIO = require("socket.io");
const app = express();
const http = require("http").Server(app);
const io = socketIO(http, {
  cors: {
    origin: "http://localhost:3000", // Replace with the correct frontend URL
    methods: ["GET", "POST"],
  },
});

const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use("/uploads", express.static("uploads"));

// Connect to DB
connectDB();

// Routes
app.use("/doctors", doctorRoutes);
app.use("/files", fileRoutes);
app.use("/labtechnicians", labTechnicianRoutes);

// Multer configuration for file upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage: storage });

// File upload route
app.post("/upload", upload.single("labReport"), async (req, res) => {
  if (!req.file) {
    return res.status(400).send("No file uploaded");
  }

  try {
    const newFile = new File({
      fileName: req.file.originalname,
      filePath: req.file.path,
    });

    await newFile.save();

    // Fetch updated reports
    const files = await File.find();

    // Emit updated reports to clients
    io.emit("updateReports", files);

    // Log updated reports in terminal
    console.log("Updated Reports:", JSON.stringify(files, null, 2));

    res.status(200).send({
      message: "File uploaded successfully",
      fileName: req.file.originalname,
      filePath: req.file.path,
    });
  } catch (error) {
    console.error("Error saving file to database:", error);
    res.status(500).send("Error saving file to database");
  }
});

// Fetch uploaded reports
app.get("/reports", async (req, res) => {
  try {
    const files = await File.find();
    res.status(200).json(files);
  } catch (error) {
    console.error("Error fetching reports:", error);
    res.status(500).send("Failed to fetch reports");
  }
});

// Delete a lab report
app.delete("/reports/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const report = await File.findById(id);
    if (!report) {
      return res.status(404).send("Report not found");
    }

    fs.unlinkSync(report.filePath);
    await File.findByIdAndDelete(id);

    res.status(200).json({ message: "Report deleted successfully" });
  } catch (error) {
    console.error("Error deleting report:", error);
    res.status(500).send("Failed to delete report");
  }
});

// WebSocket event listener for new lab reports
io.on("connection", (socket) => {
  console.log("New client connected");

  socket.on("disconnect", () => {
    console.log("Client disconnected");
  });

  socket.on("error", (err) => {
    console.log("Socket Error:", err);
  });
});

// Start server
http.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
