const express = require('express');
const router = express.Router();
const panierController = require('../controllers/panierController');
const authMiddleware = require('../middlewares/authMiddleware');
router.use(authMiddleware);

router.get('/', panierController.obtenirPanier);
router.post('/ajouter', panierController.ajouterAuPanier);
router.put('/ligne/:ligneId', panierController.modifierQuantite);
router.delete('/ligne/:ligneId', panierController.supprimerLigne);
router.delete('/vider', panierController.viderPanier);
router.post('/valider', panierController.validerPanier);

module.exports = router;