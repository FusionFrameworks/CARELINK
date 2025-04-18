const mongoose = require('mongoose');

const doctorSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  doctorName: { type: String, required: true },
  specialization: { type: String, required: true },
  experience: { type: Number, required: true },
  hospitalName: { type: String, required: true },
});

module.exports = mongoose.model('Doctor', doctorSchema);
