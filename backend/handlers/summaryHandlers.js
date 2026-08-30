const { Expense } = require('../models/Expense');

/**
 * Helper to format Date as YYYY-MM-DD
 */
const formatDateKey = (date) => {
  const yyyy = date.getFullYear();
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  return `${yyyy}-${mm}-${dd}`;
};

/**
 * GET /api/summary
 * Calculate total spending, weekly, monthly, yearly, and top category
 */
const getSummary = async (req, res, next) => {
  try {
    const allExpenses = await Expense.find();

    // Determine reference date: use query refDate if provided, otherwise default to current date
    let refDate = new Date();
    if (req.query.refDate) {
      const parsed = new Date(req.query.refDate);
      if (!isNaN(parsed.getTime())) refDate = parsed;
    }

    // Reference time calculations
    const nowYear = refDate.getFullYear();
    const nowMonth = refDate.getMonth();

    // Week boundaries (Sunday to Saturday)
    const startOfWeek = new Date(refDate);
    startOfWeek.setDate(refDate.getDate() - refDate.getDay());
    startOfWeek.setHours(0, 0, 0, 0);

    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 6);
    endOfWeek.setHours(23, 59, 59, 999);

    // Month boundaries
    const startOfMonth = new Date(nowYear, nowMonth, 1, 0, 0, 0, 0);
    const endOfMonth = new Date(nowYear, nowMonth + 1, 0, 23, 59, 59, 999);

    // Year boundaries
    const startOfYear = new Date(nowYear, 0, 1, 0, 0, 0, 0);
    const endOfYear = new Date(nowYear, 11, 31, 23, 59, 59, 999);

    let totalSpending = 0;
    let thisWeek = 0;
    let thisMonth = 0;
    let thisYear = 0;
    const categoryTotals = {};

    for (const exp of allExpenses) {
      const amt = exp.amount || 0;
      totalSpending += amt;

      const expDate = new Date(exp.date);

      if (expDate >= startOfWeek && expDate <= endOfWeek) {
        thisWeek += amt;
      }

      if (expDate >= startOfMonth && expDate <= endOfMonth) {
        thisMonth += amt;
      }

      if (expDate >= startOfYear && expDate <= endOfYear) {
        thisYear += amt;
      }

      categoryTotals[exp.category] = (categoryTotals[exp.category] || 0) + amt;
    }

    let topCategory = null;
    let maxCategoryAmount = -1;

    for (const [catName, amt] of Object.entries(categoryTotals)) {
      if (amt > maxCategoryAmount) {
        maxCategoryAmount = amt;
        topCategory = {
          name: catName,
          amount: Math.round(amt * 100) / 100
        };
      }
    }

    res.status(200).json({
      success: true,
      data: {
        totalSpending: Math.round(totalSpending * 100) / 100,
        thisWeek: Math.round(thisWeek * 100) / 100,
        thisMonth: Math.round(thisMonth * 100) / 100,
        thisYear: Math.round(thisYear * 100) / 100,
        topCategory: topCategory || { name: null, amount: 0 }
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/summary/trends
 * Daily breakdown for current week bar chart (Sunday to Saturday)
 */
const getSpendingTrends = async (req, res, next) => {
  try {
    const allExpenses = await Expense.find();

    let refDate = new Date();
    if (req.query.refDate) {
      const parsed = new Date(req.query.refDate);
      if (!isNaN(parsed.getTime())) refDate = parsed;
    }

    // Sunday of reference week
    const startOfWeek = new Date(refDate);
    startOfWeek.setDate(refDate.getDate() - refDate.getDay());
    startOfWeek.setHours(0, 0, 0, 0);

    const values = [];

    for (let i = 0; i < 7; i++) {
      const dayDate = new Date(startOfWeek);
      dayDate.setDate(startOfWeek.getDate() + i);

      const dayStart = new Date(dayDate);
      dayStart.setHours(0, 0, 0, 0);

      const dayEnd = new Date(dayDate);
      dayEnd.setHours(23, 59, 59, 999);

      let dayAmount = 0;
      for (const exp of allExpenses) {
        const d = new Date(exp.date);
        if (d >= dayStart && d <= dayEnd) {
          dayAmount += exp.amount;
        }
      }

      values.push({
        date: formatDateKey(dayDate),
        amount: Math.round(dayAmount * 100) / 100
      });
    }

    res.status(200).json({
      success: true,
      data: {
        period: 'week',
        values
      }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getSummary,
  getSpendingTrends
};
