const express = require('express');
const router = express.Router();
const annonceController = require('../controllers/annonceController');
const authentifier = require('../middlewares/authMiddleware');
const upload = require('../middlewares/upload');

console.log('📋 Routes annonces chargées');

// Routes publiques
router.get('/', annonceController.obtenirAnnonces);

// 🆕 Routes protégées
router.get('/mesAnnonces', authentifier, annonceController.obtenirMesAnnonces);
router.delete('/:id', authentifier, annonceController.supprimerAnnonce);

// Route ajout
router.post(
    '/ajout',
    (req, res, next) => {
        console.log('🟢 Route /ajout atteinte');
        next();
    },
    authentifier,
    upload.array('images', 5),
    annonceController.ajouterAnnonce
);

module.exports = router;