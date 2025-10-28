const express = require('express');
const router = express.Router();
const utilisateurController = require('../controllers/utilisateurController');

router.get('/', utilisateurController.getTousUtilisateurs);
router.get('/:id', utilisateurController.getUtilisateurParId);
router.post('/', utilisateurController.creerUtilisateur);
router.put('/:id', utilisateurController.modifierUtilisateur);
router.delete('/:id', utilisateurController.supprimerUtilisateur);

module.exports = router;