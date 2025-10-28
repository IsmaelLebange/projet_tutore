const utilisateurService = require('../services/utilisateurService');
const bcrypt = require('bcrypt');
const NOMBRE_CYCLES_HACHAGE = 10;

const obtenirProfil = async (req, res) => {
    try {
        // req.idUtilisateur provient du middleware JWT
        const utilisateur = await utilisateurService.trouverUtilisateurParId(req.idUtilisateur); 

        if (!utilisateur) {
            return res.status(404).json({ message: 'Profil utilisateur non trouvé.' });
        }
        
        // Réponse utilisant les champs nom et prenom séparés
        const utilisateurReponse = {
            id: utilisateur.id,
            prenom: utilisateur.prenom,
            nom: utilisateur.nom,
            email: utilisateur.email,
            telephone: utilisateur.numero_de_telephone,
            date_inscription: utilisateur.date_inscription,
            reputation: utilisateur.reputation,
            etat: utilisateur.etat,
            adresseFixe: utilisateur.adresseFixe // déjà inclus via trouverUtilisateurParId
        };

        res.status(200).json(utilisateurReponse);
    } catch (erreur) {
        console.error('Erreur lors de la récupération du profil:', erreur);
        res.status(500).json({ message: 'Erreur interne du serveur.' });
    }
};

const mettreAJourProfil = async (req, res) => {
    try {
        // Les champs de mise à jour peuvent maintenant inclure 'nom' et 'prenom'
        const { nom, prenom, numero_de_telephone, mot_de_passe_nouveau } = req.body;
        
        // Mise à jour pour utiliser les champs séparés
        const donneesAMettreAJour = { nom, prenom, numero_de_telephone };

        if (mot_de_passe_nouveau) {
            const motDePasseHache = await bcrypt.hash(mot_de_passe_nouveau, NOMBRE_CYCLES_HACHAGE);
            donneesAMettreAJour.mot_de_passe = motDePasseHache;
        }

        // Nettoyage des champs undefined pour que Sequelize n'essaie pas de les mettre à jour
        Object.keys(donneesAMettreAJour).forEach(key => donneesAMettreAJour[key] === undefined && delete donneesAMettreAJour[key]);

        const [lignesAffectees] = await utilisateurService.mettreAJourUtilisateur(req.idUtilisateur, donneesAMettreAJour);

        if (lignesAffectees === 0) {
            return res.status(400).json({ message: 'Mise à jour impossible ou aucune donnée modifiée.' });
        }

        const utilisateurMisAJour = await utilisateurService.trouverUtilisateurParId(req.idUtilisateur);
        
        // Préparation de la réponse avec les champs séparés
        const utilisateurReponse = {
            id: utilisateurMisAJour.id,
            prenom: utilisateurMisAJour.prenom,
            nom: utilisateurMisAJour.nom,
            email: utilisateurMisAJour.email,
            telephone: utilisateurMisAJour.numero_de_telephone,
            date_inscription: utilisateurMisAJour.date_inscription,
            reputation: utilisateurMisAJour.reputation,
            etat: utilisateurMisAJour.etat,
            adresseFixe: utilisateurMisAJour.adresseFixe
        };
        
        res.status(200).json({ 
            message: 'Profil mis à jour avec succès.',
            utilisateur: utilisateurReponse
        });

    } catch (erreur) {
        console.error('Erreur lors de la mise à jour du profil:', erreur);
        res.status(500).json({ message: 'Erreur interne du serveur.' });
    }
};

module.exports = {
    obtenirProfil,
    mettreAJourProfil,
};
