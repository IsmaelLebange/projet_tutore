const express = require('express');
const accueilController = require('../controllers/accueilController');


const router = express.Router();

router.get('/obtenirDonnees',accueilController.obtenirDonneesAccueil);
router.get('/categories', accueilController.obteniCategorie,);


module.exports = router;
