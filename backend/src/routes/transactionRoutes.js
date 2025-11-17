const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');
const authentifier = require('../middlewares/authMiddleware');

// Toutes les routes nécessitent l'authentification
router.use(authentifier);

// GET /api/transactions - Liste des transactions
router.get('/', transactionController.obtenirMesTransactions);

// GET /api/transactions/:id - Détail d'une transaction
router.get('/:id', transactionController.obtenirDetailTransaction);

// POST /api/transactions/:id/confirmer - Confirmer réception/envoi
router.post('/:id/confirmer', transactionController.confirmerTransaction);

module.exports = router;