const express = require('express');
const router = express.Router();
const adminController = require('../controllers/administration/adminController');
const verifierToken = require('../middlewares/authMiddleware');
const verifierAdmin = require('../middlewares/verifierAdmin');
const adminUtilisateurController = require('../controllers/administration/adminUtilisateurController');
const adminAnnonceController = require('../controllers/administration/adminAnnonceController');
const path = require('path');

// Toutes les routes admin protégées
router.use(verifierToken);
router.use(verifierAdmin);

// Création admin + check droits
router.post('/create', adminController.creerAdmin);
router.get('/check', adminController.verifierDroitsAdmin);

// ✅ Annonces admin
router.get('/annonces', adminAnnonceController.obtenirAnnoncesAdmin);
router.patch('/:id/statut', adminAnnonceController.changerStatutAnnonce);

// Utilisateurs admin
router.get('/utilisateurs', adminUtilisateurController.obtenirUtilisateurs);
router.patch('/utilisateurs/:id/etat', adminUtilisateurController.changerEtatUtilisateur);
router.patch('/utilisateurs/:id/role', adminUtilisateurController.changerRoleUtilisateur);

module.exports = router;