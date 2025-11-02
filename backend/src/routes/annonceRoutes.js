const express = require('express');
const router = express.Router();

const annonceController = require('../controllers/annonceController');
const authMiddleware = require('../middlewares/authMiddleware');
const chargerUtilisateur = require('../middlewares/chargerUtilisateur');
const verifieEtat = require('../middlewares/verifierEtat');

// Ajouter une annonce (nécessite compte actif)
router.post('/ajout', authMiddleware, chargerUtilisateur, verifieEtat, annonceController.ajouterAnnonce);

// Lister toutes les annonces (publique)
router.get('/', annonceController.obtenirAnnonces);

module.exports = router;
