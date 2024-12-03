const express = require('express');
const { registerTechnician, loginTechnician } = require('../controllers/labTechnicianController');
const router = express.Router();

router.post('/register', registerTechnician);
router.post('/login', loginTechnician);

module.exports = router;
