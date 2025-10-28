const express = require('express');
const router = express.Router();
const adminController = require('../controllers/administration/adminController');
const verifierToken = require('../middlewares/authMiddleware'); // Ton middleware JWT existant
const verifierAdmin = require('../middlewares/verifierAdmin'); 
const adminUtilisateurController= require('../controllers/administration/adminUtilisateurController');

// 🚨 PROTECTION GLOBALE : Toutes les routes Admin nécessitent d'être connecté ET admin.
router.use(verifierToken); 
router.use(verifierAdmin); 

router.post('/create', verifierToken, verifierAdmin, adminController.creerAdmin);

// Route pour vérifier les droits admin
router.get('/check', verifierToken, adminController.verifierDroitsAdmin);

router.get('/utilisateurs', adminController.obtenirTousLesUtilisateurs);

// [PATCH] /api/admin/utilisateurs/:id : Met à jour l'état (bloqué) ou le rôle
router.patch('/utilisateurs/:id', adminController.mettreAJourUtilisateurAdmin);
router.get('/utilisateurs', adminUtilisateurController.obtenirUtilisateurs);
router.patch('/utilisateurs/:id/etat', adminUtilisateurController.changerEtatUtilisateur);
router.patch('/utilisateurs/:id/role', adminUtilisateurController.changerRoleUtilisateur);

module.exports = router;