const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/serviceController');

// ✅ Routes spécifiques EN PREMIER
router.get('/categories', serviceController.obtenirCategories);
router.get('/categories/:categorieId/types', serviceController.obtenirTypesParCategorie);

// ✅ Routes paramétriques APRÈS
router.get('/', serviceController.obtenirTousServices);
router.get('/:id', serviceController.obtenirServiceParId);

module.exports = router;