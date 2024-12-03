const bcrypt = require('bcryptjs');
const LabTechnician = require('../models/labTechnicianModel');

exports.registerTechnician = async (req, res) => {
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
};

exports.loginTechnician = async (req, res) => {
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
};
