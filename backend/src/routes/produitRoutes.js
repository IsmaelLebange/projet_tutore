const express = require('express');
const router = express.Router();
const produitController = require('../controllers/produitController');

// ✅ Routes spécifiques EN PREMIER
router.get('/categories', produitController.obtenirCategories);
router.get('/categories/:categorieId/types', produitController.obtenirTypesParCategorie);

// ✅ Routes paramétriques APRÈS
router.get('/', produitController.obtenirTousProduits);
router.get('/:id', produitController.obtenirProduitParId);

module.exports = router;