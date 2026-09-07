const express = require('express');
const { googleAuth, getCurrentUser } = require('../handlers/authHandlers');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// Public auth endpoint
router.post('/google', googleAuth);

// Protected user endpoint
router.get('/me', authMiddleware, getCurrentUser);

module.exports = router;
