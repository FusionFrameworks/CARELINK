const mongoose = require('mongoose');

const labTechnicianSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  technicianName: { type: String, required: true },
});

module.exports = mongoose.model('LabTechnician', labTechnicianSchema);
