const express = require('express');
const router = express.Router();
const rechercheController = require('../controllers/rechercheController');

router.get('/produit',rechercheController.rechercheProduits);
router.get('/service',rechercheController.rechercheServices);
router.get('/',rechercheController.rechercheAnnonces);

module.exports = router;