// app.js
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const session = require("express-session");
const connectDB = require("./utils/db");
const doctorRoutes = require("./routes/doctorRoutes");
const fileRoutes = require("./routes/fileRoutes");
const labTechnicianRoutes = require("./routes/labTechnicianRoutes");
const multer = require("multer");
const File = require("./models/fileModel");
const fs = require('fs');
const app = express();

// Middleware
app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || origin === "https://l7xqlqhl-3000.inc1.devtunnels.ms/") {
        callback(null, true);
      } else {
        callback(null, true);
      }
    },
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true,
  })
);

app.use(bodyParser.json());

app.use(
  session({
    secret: "your-secret-key",
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false },
  })
);

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

module.exports = app;
