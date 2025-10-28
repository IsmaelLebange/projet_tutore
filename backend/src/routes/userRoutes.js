const express = require('express');
const userController = require('../controllers/userController');
const authentifier = require('../middlewares/authMiddleware');

const router = express.Router();

// Route sécurisée pour lire le profil
router.get('/profile', authentifier, userController.obtenirProfil);

// Route sécurisée pour modifier le profil
router.put('/profile', authentifier, userController.mettreAJourProfil);

module.exports = router;