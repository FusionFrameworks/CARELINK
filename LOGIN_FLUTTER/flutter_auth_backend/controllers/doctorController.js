const bcrypt = require('bcryptjs');
const Doctor = require('../models/doctorModel');

exports.registerDoctor = async (req, res) => {
  try {
    const { email, password, doctorName, specialization, experience, hospitalName } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    const newDoctor = new Doctor({
      email,
      password: hashedPassword,
      doctorName,
      specialization,
      experience,
      hospitalName,
    });

    await newDoctor.save();
    res.status(201).json({ message: 'Doctor registered successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
};

exports.loginDoctor = async (req, res) => {
  try {
    const { email, password } = req.body;
    const doctor = await Doctor.findOne({ email });

    if (!doctor || !(await bcrypt.compare(password, doctor.password))) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    res.status(200).json({
      email: doctor.email,
      doctorName: doctor.doctorName,
      specialization: doctor.specialization,
      experience: doctor.experience,
      hospitalName: doctor.hospitalName,
    });
  } catch (error) {
    res.status(500).json({ error: 'Server error' });
  }
};
