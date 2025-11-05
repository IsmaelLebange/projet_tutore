const express = require('express');

const router = express.Router();
const annonceController = require('../controllers/annonceController');
const authMiddleware = require('../middlewares/authMiddleware');
const upload = require('../middlewares/upload');

// ✅ route pour ajouter avec images
router.post('/ajout', authMiddleware, upload.array('images', 5), annonceController.ajouterAnnonce);

// ✅ route pour récupérer toutes les annonces
router.get('/', annonceController.obtenirAnnonces);

module.exports = router;
