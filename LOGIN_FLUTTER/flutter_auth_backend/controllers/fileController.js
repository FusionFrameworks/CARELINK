const File = require('../models/fileModel');
const fs = require('fs');

exports.uploadFile = async (req, res) => {
  if (!req.file) return res.status(400).send('No file uploaded');

  try {
    const newFile = new File({
      fileName: req.file.originalname,
      filePath: req.file.path,
    });

    await newFile.save();
    res.status(200).send({ message: 'File uploaded successfully', fileName: req.file.originalname, filePath: req.file.path });
  } catch (error) {
    res.status(500).send('Error saving file to database');
  }
};

exports.getReports = async (req, res) => {
  try {
    const files = await File.find();
    res.status(200).json(files);
  } catch (error) {
    res.status(500).send('Failed to fetch reports');
  }
};

exports.deleteReport = async (req, res) => {
  try {
    const { id } = req.params;
    const report = await File.findById(id);

    if (!report) return res.status(404).send('Report not found');

    fs.unlinkSync(report.filePath);
    await File.findByIdAndDelete(id);

    res.status(200).json({ message: 'Report deleted successfully' });
  } catch (error) {
    res.status(500).send('Failed to delete report');
  }
};
