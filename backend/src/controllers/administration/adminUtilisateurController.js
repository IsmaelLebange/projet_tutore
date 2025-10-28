// controllers/administration/utilisateurController.js
const AdminUtilisateurService = require('../../services/administration/adminUtilisateurAdmin');

class AdminUtilisateurController {
   
    static async obtenirUtilisateurs(req, res) {
        try {
            const { page, limit, recherche, role, etat } = req.query;
            
            const result = await AdminUtilisateurService.obtenirUtilisateurs({
                page: page || 1,
                limit: limit || 50,
                recherche: recherche || '',
                role: role || '',
                etat: etat || ''
            });

            res.status(200).json(result);

        } catch (erreur) {
            console.error('Erreur récupération utilisateurs:', erreur);
            res.status(500).json({ message: 'Erreur interne du serveur.' });
        }
    }

    /**
     * Changer l'état d'un utilisateur
     */
    static async changerEtatUtilisateur(req, res) {
        try {
            const { id } = req.params;
            const { etat } = req.body;

            if (!etat) {
                return res.status(400).json({ message: 'Le champ etat est requis.' });
            }

            const result = await AdminUtilisateurService.changerEtatUtilisateur(id, etat);
            res.status(200).json(result);

        } catch (erreur) {
            console.error('Erreur changement état utilisateur:', erreur);
            
            if (erreur.message === 'État invalide') {
                return res.status(400).json({ message: 'État invalide. Doit être "Actif" ou "Bloqué".' });
            }
            if (erreur.message === 'Utilisateur non trouvé') {
                return res.status(404).json({ message: 'Utilisateur non trouvé.' });
            }
            
            res.status(500).json({ message: 'Erreur interne du serveur.' });
        }
    }

    /**
     * Changer le rôle d'un utilisateur
     */
    static async changerRoleUtilisateur(req, res) {
        try {
            const { id } = req.params;
            const { role } = req.body;

            if (!role) {
                return res.status(400).json({ message: 'Le champ role est requis.' });
            }

            const result = await AdminUtilisateurService.changerRoleUtilisateur(
                id, 
                role, 
                req.idUtilisateur
            );
            
            res.status(200).json(result);

        } catch (erreur) {
            console.error('Erreur changement rôle utilisateur:', erreur);
            
            if (erreur.message === 'Rôle invalide') {
                return res.status(400).json({ message: 'Rôle invalide.' });
            }
            if (erreur.message === 'Utilisateur non trouvé') {
                return res.status(404).json({ message: 'Utilisateur non trouvé.' });
            }
            if (erreur.message.includes('retirer vos propres droits')) {
                return res.status(403).json({ message: erreur.message });
            }
            
            res.status(500).json({ message: 'Erreur interne du serveur.' });
        }
    }
}

module.exports = AdminUtilisateurController;