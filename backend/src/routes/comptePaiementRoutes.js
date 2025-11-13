const { Router } = require('express');
const router = Router();
const authMiddleware = require('../middlewares/authMiddleware');
const comptePaiementController = require('../controllers/comptePaiementController');

router.use(authMiddleware); // Toutes les routes protégées

router.get('/', comptePaiementController.obtenirComptes);
router.post('/', comptePaiementController.ajouterCompte);
router.put('/:compteId', comptePaiementController.modifierCompte);
router.delete('/:compteId', comptePaiementController.supprimerCompte);
router.post('/:compteId/principal', comptePaiementController.definirPrincipal);

module.exports = router;