const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'expense_tracker_secret_jwt_key_2026';

/**
 * Authentication Middleware
 * Validates Bearer JWT token in Authorization header
 */
const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required. Missing token.'
      });
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required. Empty token.'
      });
    }

    const decoded = jwt.verify(token, JWT_SECRET);
    const userId = decoded.id || decoded._id || decoded.userId;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Invalid authentication token: missing user ID.'
      });
    }

    req.user = {
      ...decoded,
      id: userId.toString()
    };
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired authentication token'
    });
  }
};

module.exports = authMiddleware;
