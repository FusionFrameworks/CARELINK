const express = require('express');
const multer = require('multer');
const { uploadFile, getReports, deleteReport } = require('../controllers/fileController');

const router = express.Router();
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
});
const upload = multer({ storage });

router.post('/upload', upload.single('labReport'), uploadFile);
router.get('/reports', getReports);
router.delete('/reports/:id', deleteReport);

module.exports = router;
