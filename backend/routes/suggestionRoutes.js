const express = require('express');
const router = express.Router();
const {
  getSuggestions
} = require('../handlers/suggestionHandlers');

router.get('/', getSuggestions);

module.exports = router;
