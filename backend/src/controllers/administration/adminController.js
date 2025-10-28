const utilisateurService = require('../../services/utilisateurService');
const { Op } = require('sequelize');
const adresseService = require('../../services/adresseService');
const bcrypt = require('bcrypt');

const NOMBRE_CYCLES_HACHAGE = 10;



const verifierDroitsAdmin = async (req, res) => {
    try {
        const utilisateur = await utilisateurService.trouverUtilisateurParId(req.idUtilisateur);
        
        if (!utilisateur) {
            return res.status(404).json({ message: 'Utilisateur non trouvé.' });
        }

        const estAdmin = utilisateur.role === 'admin';
        
        res.status(200).json({
            isAdmin: estAdmin,
            role: utilisateur.role,
            email: utilisateur.email
        });

    } catch (erreur) {
        console.error('Erreur vérification droits admin:', erreur);
        res.status(500).json({ message: 'Erreur interne du serveur.' });
    }
};


const creerAdmin = async (req, res) => {
    try {
        const { 
            nom, 
            prenom, 
            email, 
            mot_de_passe, 
            numero_de_telephone,
            adresse_fixe 
        } = req.body;

        console.log('Données reçues pour création admin:', { nom, prenom, email, adresse_fixe });

        // Validation des données requises
        if (!nom || !prenom || !email || !mot_de_passe) {
            return res.status(400).json({ 
                message: 'Données manquantes: nom, prénom, email et mot_de_passe sont requis.' 
            });
        }

        // Vérifier si l'email existe déjà
        const utilisateurExistant = await utilisateurService.trouverUtilisateurParEmail(email);
        if (utilisateurExistant) {
            return res.status(409).json({ message: 'Cet email est déjà utilisé.' });
        }

        let idAdresse = null;
        
        // Créer l'adresse fixe si fournie
        if (adresse_fixe && adresse_fixe.commune) {
            const nouvelleAdresse = await adresseService.creerAdresse({
                rue: adresse_fixe.rue || null,
                quartier: adresse_fixe.quartier || null,
                ville: adresse_fixe.commune, // Utiliser commune comme ville
                commune: adresse_fixe.commune,
                latitude: null, // Tu peux ajouter plus tard
                longitude: null,
            });
            idAdresse = nouvelleAdresse.id;
        }

        // Hacher le mot de passe
        const motDePasseHache = await bcrypt.hash(mot_de_passe, NOMBRE_CYCLES_HACHAGE);

        // Créer l'utilisateur avec rôle admin
        const nouvelAdmin = await utilisateurService.creerUtilisateur({
            nom: nom,
            prenom: prenom,
            email: email,
            mot_de_passe: motDePasseHache,
            numero_de_telephone: numero_de_telephone || null,
            id_adresse_fixe: idAdresse,
            role: 'admin', // Définir directement comme admin
            etat: 'Actif',
            reputation: 0.0
        });

        // Récupérer l'admin créé avec ses relations
        const adminComplet = await utilisateurService.trouverUtilisateurParId(nouvelAdmin.id);

        // Préparer la réponse
        const reponse = {
            id: adminComplet.id,
            nom: adminComplet.nom,
            prenom: adminComplet.prenom,
            email: adminComplet.email,
            telephone: adminComplet.numero_de_telephone,
            role: adminComplet.role,
            etat: adminComplet.etat,
            date_inscription: adminComplet.date_inscription,
            reputation: adminComplet.reputation
        };

        // Ajouter l'adresse si elle existe
        if (adminComplet.adresseFixe) {
            reponse.adresse_fixe = {
                id: adminComplet.adresseFixe.id,
                rue: adminComplet.adresseFixe.rue,
                ville: adminComplet.adresseFixe.ville,
                commune: adminComplet.adresseFixe.commune,
                quartier: adminComplet.adresseFixe.quartier
            };
        }

        res.status(201).json({
            message: 'Administrateur créé avec succès',
            administrateur: reponse
        });

    } catch (erreur) {
        console.error('Erreur lors de la création admin:', erreur);
        res.status(500).json({ message: 'Erreur interne du serveur: ' + erreur.message });
    }
};



const mettreAJourUtilisateurAdmin = async (req, res) => {
    try {
        const { id } = req.params;
        const { etat, role } = req.body; 
        
        if (!etat && !role) {
            return res.status(400).json({ message: 'Au moins un champ (etat ou role) est requis pour la mise à jour.' });
        }

        const donneesAMettreAJour = {};

        if (etat && ['Actif', 'Bloqué'].includes(etat)) {
            donneesAMettreAJour.etat = etat;
        }

        if (role && ['utilisateur', 'admin'].includes(role)) {
            donneesAMettreAJour.role = role;
        }
        
        if (Object.keys(donneesAMettreAJour).length === 0) {
            return res.status(400).json({ message: 'Données de mise à jour invalides.' });
        }
        
        const [lignesAffectees] = await utilisateurService.mettreAJourUtilisateur(id, donneesAMettreAJour);

        if (lignesAffectees === 0) {
            return res.status(404).json({ message: 'Utilisateur non trouvé ou données inchangées.' });
        }

        res.status(200).json({ message: `Utilisateur ${id} mis à jour avec succès.`, updates: donneesAMettreAJour });

    } catch (erreur) {
        console.error('Erreur lors de la mise à jour utilisateur (Admin):', erreur);
        res.status(500).json({ message: 'Erreur interne du serveur.' });
    }
};


module.exports = {
    
    mettreAJourUtilisateurAdmin,
    creerAdmin, // Nouvelle fonction
    verifierDroitsAdmin ,
};