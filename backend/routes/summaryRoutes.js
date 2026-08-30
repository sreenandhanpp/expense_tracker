const express = require('express');
const router = express.Router();
const {
  getSummary,
  getSpendingTrends
} = require('../handlers/summaryHandlers');

router.get('/', getSummary);
router.get('/trends', getSpendingTrends);

module.exports = router;
