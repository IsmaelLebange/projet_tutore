const utilisateurService = require('../services/utilisateurService');

const verifierAdmin = async (req, res, next) => {
    // req.idUtilisateur doit être mis par un middleware d'authentification (vérification du JWT) AVANT celui-ci.
    const idUtilisateur = req.idUtilisateur; 

    if (!idUtilisateur) {
        // Normalement, ça ne devrait pas arriver si le middleware d'auth est bien positionné.
        return res.status(401).json({ message: 'Accès non autorisé. Token manquant ou invalide.' });
    }

    try {
        
        const utilisateur = await utilisateurService.trouverUtilisateurParId(idUtilisateur);
        
        if (!utilisateur) {
            return res.status(404).json({ message: 'Utilisateur non trouvé.' });
        }

        // Vérification du rôle
        if (utilisateur.role !== 'admin') {
            return res.status(403).json({ message: 'Accès interdit. Réservé aux administrateurs.' });
        }

        // Si tout est bon, on passe à la suite
        next();
        
    } catch (erreur) {
        console.error('Erreur dans le middleware verifierAdmin:', erreur);
        res.status(500).json({ message: 'Erreur interne lors de la vérification des droits.' });
    }
};

module.exports = verifierAdmin;