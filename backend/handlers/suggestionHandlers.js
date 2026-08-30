const { Expense } = require('../models/Expense');

/**
 * GET /api/suggestions?query=...
 * Search previous MongoDB expenses by title for auto-filling
 */
const getSuggestions = async (req, res, next) => {
  try {
    const { query } = req.query;

    if (!query || query.trim() === '') {
      return res.status(200).json({
        success: true,
        data: []
      });
    }

    const searchTerm = query.trim();
    const regex = new RegExp(searchTerm, 'i');

    const expenses = await Expense.find({ title: regex })
      .sort({ date: -1, createdAt: -1 })
      .limit(20);

    const seenTitles = new Set();
    const suggestions = [];

    for (const exp of expenses) {
      const lowerTitle = exp.title.toLowerCase();
      if (!seenTitles.has(lowerTitle)) {
        seenTitles.add(lowerTitle);
        suggestions.push({
          title: exp.title,
          amount: exp.amount,
          category: exp.category,
          payment: exp.payment
        });
      }

      if (suggestions.length >= 5) {
        break;
      }
    }

    res.status(200).json({
      success: true,
      data: suggestions
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getSuggestions
};
