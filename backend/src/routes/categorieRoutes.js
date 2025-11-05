const express = require('express');
const router = express.Router();
const categorieController = require('../controllers/categorieController');

router.get('/produits', categorieController.obtenirCategoriesProduits);
router.get('/services', categorieController.obtenirCategoriesServices);

module.exports = router;
