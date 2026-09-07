require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDatabase = require('./config/database');

const authRoutes = require('./routes/authRoutes');
const expenseRoutes = require('./routes/expenseRoutes');
const summaryRoutes = require('./routes/summaryRoutes');
const suggestionRoutes = require('./routes/suggestionRoutes');
const authMiddleware = require('./middleware/authMiddleware');
const { getCategories, getPaymentMethods } = require('./handlers/expenseHandlers');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health Check (Public)
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Budget Tracker API is running'
  });
});

// Auth Routes (Public login endpoint, protected me endpoint inside authRoutes)
app.use('/api/auth', authRoutes);

// Protected Metadata Endpoints
app.get('/api/categories', authMiddleware, getCategories);
app.get('/api/payment-methods', authMiddleware, getPaymentMethods);

// Protected API Routes
app.use('/api/expenses', authMiddleware, expenseRoutes);
app.use('/api/summary', authMiddleware, summaryRoutes);
app.use('/api/suggestions', authMiddleware, suggestionRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled Error:', err.message);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error'
  });
});

const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    await connectDatabase();
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
  }
};

// Start server if run directly
if (require.main === module) {
  startServer();
}

module.exports = { app, startServer };
