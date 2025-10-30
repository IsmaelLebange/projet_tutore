const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const utilisateurService = require('../services/utilisateurService');
const adresseService = require('../services/adresseService');

// Configuration du hachage et du JWT (à mettre dans un fichier .env en production)
const NOMBRE_CYCLES_HACHAGE = 10;
const CLE_SECRETE_JWT = 'TA_CLE_SECRETE_ULTRA_SECRETE'; // À changer absolument
const DUREE_TOKEN = '1d';

// Fonction utilitaire pour générer le token JWT
const genererToken = (idUtilisateur) => {
    return jwt.sign({ idUtilisateur }, CLE_SECRETE_JWT, {
        expiresIn: DUREE_TOKEN,
    });
};

const inscription = async (req, res) => {
    try {
        // 1. Récupération des données du corps (elles arrivent splitées du Flutter)
        const { nom, prenom, email, mot_de_passe, numero_de_telephone, adresse_fixe } = req.body;

        // Validation de base
        if (!email || !mot_de_passe || !nom || !prenom || !adresse_fixe || !adresse_fixe.commune) {
            return res.status(400).json({ message: 'Données manquantes pour l\'inscription.' });
        }

        // 2. Vérification de l'existence de l'utilisateur
        const utilisateurExistant = await utilisateurService.trouverUtilisateurParEmail(email);
        if (utilisateurExistant) {
            return res.status(409).json({ message: 'Cet email est déjà utilisé.' });
        }

        // 3. Création de l'adresse fixe
        const nouvelleAdresse = await adresseService.creerAdresse({
            rue: adresse_fixe.rue || null,
            quartier: adresse_fixe.quartier || null,
            commune: adresse_fixe.commune, // Commune est obligatoire
            // La ville n'est pas dans le modèle flutter, on peut la déduire ou la mettre à 'commune'
            ville: adresse_fixe.commune, 
            latitude: adresse_fixe.latitude,
            longitude: adresse_fixe.longitude,
        });

        // 4. Préparation et hachage du mot de passe
        const motDePasseHache = await bcrypt.hash(mot_de_passe, NOMBRE_CYCLES_HACHAGE);

        // 6. Création de l'utilisateur
        const nouvelUtilisateur = await utilisateurService.creerUtilisateur({
            nom: nom,
            prenom: prenom,
            email,
            mot_de_passe: motDePasseHache,
            numero_de_telephone,
            id_adresse_fixe: nouvelleAdresse.id,
        });

        // 7. Génération du token
        const token = genererToken(nouvelUtilisateur.id);

        // 8. Réponse réussie (on exclut le mot de passe avant d'envoyer)
        const utilisateurSansMdp = { 
            id: nouvelUtilisateur.id,
            nom: nouvelUtilisateur.nom,
            prenom: nouvelUtilisateur.prenom,
            email: nouvelUtilisateur.email,
            telephone: nouvelUtilisateur.numero_de_telephone,
            date_inscription: nouvelUtilisateur.date_inscription,
            reputation: nouvelUtilisateur.reputation,
            type_connexion: 'classique',
            etat: nouvelUtilisateur.etat,
            role: nouvelUtilisateur.role, // ✅ AJOUT DU RÔLE
            adresse_fixe: nouvelleAdresse.toJSON()
        };

        res.status(201).json({ 
            message: 'Inscription réussie',
            utilisateur: utilisateurSansMdp,
            token 
        });

    } catch (erreur) {
        console.error('Erreur lors de l\'inscription:', erreur);
        res.status(500).json({ message: 'Erreur interne du serveur lors de l\'inscription.' });
    }
};

const connexion = async (req, res) => {
    try {
        const { email, mot_de_passe } = req.body;

        if (!email || !mot_de_passe) {
            return res.status(400).json({ message: 'Email et mot de passe sont requis.' });
        }

        // 1. Trouver l'utilisateur (inclut le mot de passe pour la vérification)
        const utilisateur = await utilisateurService.trouverUtilisateurParEmail(email);

        if (!utilisateur) {
            return res.status(401).json({ message: 'Identifiants invalides.' });
        }

        // 2. Vérifier le mot de passe
        const mdpValide = await bcrypt.compare(mot_de_passe, utilisateur.mot_de_passe);

        if (!mdpValide) {
            return res.status(401).json({ message: 'Identifiants invalides.' });
        }
        
        // 3. Générer le token
        const token = genererToken(utilisateur.id);

        // 4. Préparation de la réponse
        const utilisateurReponse = {
            id: utilisateur.id,
            nom: utilisateur.nom,
            prenom: utilisateur.prenom,
            email: utilisateur.email,
            telephone: utilisateur.numero_de_telephone,
            date_inscription: utilisateur.date_inscription,
            reputation: utilisateur.reputation,
            type_connexion: 'classique',
            etat: utilisateur.etat,
            role: utilisateur.role, // ✅ AJOUT DU RÔLE
            adresse_fixe: utilisateur.adresseFixe ? utilisateur.adresseFixe.toJSON() : null
        };

        res.status(200).json({ 
            message: 'Connexion réussie',
            utilisateur: utilisateurReponse,
            token 
        });

    } catch (erreur) {
        console.error('Erreur lors de la connexion:', erreur);
        res.status(500).json({ message: 'Erreur interne du serveur lors de la connexion.' });
    }
};

module.exports = {
    inscription,
    connexion,
};