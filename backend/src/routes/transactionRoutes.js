const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');
const authMiddleware = require('../middlewares/authMiddleware');

// Toutes les routes sont protégées par authentification
router.use(authMiddleware);

router.get('/', transactionController.obtenirTransactions);
router.get('/:transactionId/facture', transactionController.getFacture);

module.exports = router;
