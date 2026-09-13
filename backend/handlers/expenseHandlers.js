const mongoose = require('mongoose');
const { Expense, CATEGORIES, PAYMENT_METHODS } = require('../models/Expense');

/**
 * GET /api/expenses
 * Search and filter expenses dynamically for authenticated user
 */
const getExpenses = async (req, res, next) => {
  try {
    if (!req.user || !req.user.id || !mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or missing user identity'
      });
    }

    const userObjectId = new mongoose.Types.ObjectId(req.user.id);
    const query = { user: userObjectId };

    if (search && search.trim() !== '') {
      query.title = { $regex: search.trim(), $options: 'i' };
    }

    if (category && category.trim() !== '') {
      query.category = category.trim();
    }

    if (payment && payment.trim() !== '') {
      query.payment = payment.trim();
    }

    if (date && date.trim() !== '') {
      const parsedDate = new Date(date);
      if (!isNaN(parsedDate.getTime())) {
        const startOfDay = new Date(parsedDate);
        startOfDay.setHours(0, 0, 0, 0);

        const endOfDay = new Date(parsedDate);
        endOfDay.setHours(23, 59, 59, 999);

        query.date = { $gte: startOfDay, $lte: endOfDay };
      }
    }

    const expenses = await Expense.find(query).sort({ date: -1, createdAt: -1 });

    res.status(200).json({
      success: true,
      data: expenses
    });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/expenses/:id
 * Retrieve a single expense by ID for authenticated user
 */
const getExpense = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(404).json({
        success: false,
        message: 'Expense not found'
      });
    }

    const userObjectId = new mongoose.Types.ObjectId(req.user.id);
    const expense = await Expense.findOne({ _id: id, user: userObjectId });

    if (!expense) {
      return res.status(404).json({
        success: false,
        message: 'Expense not found'
      });
    }

    res.status(200).json({
      success: true,
      data: expense
    });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /api/expenses
 * Create a new expense associated with authenticated user
 */
const createExpense = async (req, res, next) => {
  try {
    const { title, amount, category, payment, date } = req.body;

    if (!title || typeof title !== 'string' || title.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Title is required'
      });
    }

    const numAmount = Number(amount);
    if (isNaN(numAmount) || numAmount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Amount must be greater than zero'
      });
    }

    if (!category || !CATEGORIES.includes(category)) {
      return res.status(400).json({
        success: false,
        message: `Category must be one of: ${CATEGORIES.join(', ')}`
      });
    }

    if (!payment || !PAYMENT_METHODS.includes(payment)) {
      return res.status(400).json({
        success: false,
        message: `Payment method must be one of: ${PAYMENT_METHODS.join(', ')}`
      });
    }

    const parsedDate = date ? new Date(date) : new Date();
    if (isNaN(parsedDate.getTime())) {
      return res.status(400).json({
        success: false,
        message: 'Invalid date format'
      });
    }

    const userObjectId = new mongoose.Types.ObjectId(req.user.id);
    const newExpense = await Expense.create({
      user: userObjectId,
      title: title.trim(),
      amount: numAmount,
      category,
      payment,
      date: parsedDate
    });

    res.status(201).json({
      success: true,
      message: 'Expense created successfully',
      data: newExpense
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    next(error);
  }
};

/**
 * PUT /api/expenses/:id
 * Update an existing expense for authenticated user
 */
const updateExpense = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(404).json({
        success: false,
        message: 'Expense not found'
      });
    }

    const { title, amount, category, payment, date } = req.body;

    const updateData = {};

    if (title !== undefined) {
      if (typeof title !== 'string' || title.trim() === '') {
        return res.status(400).json({
          success: false,
          message: 'Title cannot be empty'
        });
      }
      updateData.title = title.trim();
    }

    if (amount !== undefined) {
      const numAmount = Number(amount);
      if (isNaN(numAmount) || numAmount <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Amount must be greater than zero'
        });
      }
      updateData.amount = numAmount;
    }

    if (category !== undefined) {
      if (!CATEGORIES.includes(category)) {
        return res.status(400).json({
          success: false,
          message: `Category must be one of: ${CATEGORIES.join(', ')}`
        });
      }
      updateData.category = category;
    }

    if (payment !== undefined) {
      if (!PAYMENT_METHODS.includes(payment)) {
        return res.status(400).json({
          success: false,
          message: `Payment method must be one of: ${PAYMENT_METHODS.join(', ')}`
        });
      }
      updateData.payment = payment;
    }

    if (date !== undefined) {
      const parsedDate = new Date(date);
      if (isNaN(parsedDate.getTime())) {
        return res.status(400).json({
          success: false,
          message: 'Invalid date format'
        });
      }
      updateData.date = parsedDate;
    }

    const userObjectId = new mongoose.Types.ObjectId(req.user.id);
    const updatedExpense = await Expense.findOneAndUpdate(
      { _id: id, user: userObjectId },
      updateData,
      { new: true, runValidators: true }
    );

    if (!updatedExpense) {
      return res.status(404).json({
        success: false,
        message: 'Expense not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Expense updated successfully',
      data: updatedExpense
    });
  } catch (error) {
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }
    next(error);
  }
};

/**
 * DELETE /api/expenses/:id
 * Delete an expense for authenticated user
 */
const deleteExpense = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(404).json({
        success: false,
        message: 'Expense not found'
      });
    }

    const userObjectId = new mongoose.Types.ObjectId(req.user.id);
    const deleted = await Expense.findOneAndDelete({ _id: id, user: userObjectId });

    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: 'Expense not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Expense deleted successfully'
    });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/categories
 * List allowed expense categories
 */
const getCategories = (req, res) => {
  res.status(200).json({
    success: true,
    data: CATEGORIES
  });
};

/**
 * GET /api/payment-methods
 * List allowed payment methods
 */
const getPaymentMethods = (req, res) => {
  res.status(200).json({
    success: true,
    data: PAYMENT_METHODS
  });
};

module.exports = {
  getExpenses,
  getExpense,
  createExpense,
  updateExpense,
  deleteExpense,
  getCategories,
  getPaymentMethods
};
