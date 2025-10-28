const express = require('express');
const router = express.Router();
const produitController = require('../controllers/produitController');

router.get('/', produitController.getTousProduits);
router.get('/:id', produitController.getProduitParId);
router.post('/', produitController.creerProduit);
router.put('/:id', produitController.modifierProduit);
router.delete('/:id', produitController.supprimerProduit);

module.exports = router;
