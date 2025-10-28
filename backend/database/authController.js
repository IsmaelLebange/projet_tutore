const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const utilisateurService = require('../services/utilisateurService');

const NOMBRE_CYCLES_HACHAGE = 10; 
const SECRET_JWT = process.env.JWT_SECRET;

const inscription = async (req, res) => {
    const { nom_complet, email, mot_de_passe, numero_de_telephone } = req.body;

    if (!email || !mot_de_passe || !nom_complet) {
        return res.status(400).json({ message: 'Email, mot de passe et nom sont obligatoires.' });
    }

    try {
        const utilisateurExistant = await utilisateurService.trouverUtilisateurParEmail(email);
        if (utilisateurExistant) {
            return res.status(409).json({ message: 'Un compte avec cet email existe déjà.' });
        }

        const motDePasseHache = await bcrypt.hash(mot_de_passe, NOMBRE_CYCLES_HACHAGE);

        const nouvelUtilisateur = await utilisateurService.creerUtilisateur({
            nom_complet,
            email,
            mot_de_passe: motDePasseHache, 
            numero_de_telephone,
        });

        res.status(201).json({ 
            message: 'Utilisateur inscrit avec succès.',
            utilisateur: { id: nouvelUtilisateur.id, nom_complet: nouvelUtilisateur.nom_complet, email: nouvelUtilisateur.email }
        });

    } catch (erreur) {
        console.error('Erreur lors de l\'inscription:', erreur);
        res.status(500).json({ message: 'Erreur interne du serveur.' });
    }
};


const connexion = async (req, res) => {
    const { email, mot_de_passe } = req.body;

    if (!email || !mot_de_passe) {
        return res.status(400).json({ message: 'Email et mot de passe sont requis.' });
    }

    try {
        const utilisateur = await utilisateurService.trouverUtilisateurParEmail(email);
        if (!utilisateur) {
            return res.status(401).json({ message: 'Email ou mot de passe incorrect.' });
        }

        const motDePasseEstValide = await bcrypt.compare(mot_de_passe, utilisateur.mot_de_passe);
        if (!motDePasseEstValide) {
            return res.status(401).json({ message: 'Email ou mot de passe incorrect.' });
        }

        const token = jwt.sign(
            { idUtilisateur: utilisateur.id }, 
            SECRET_JWT, 
            { expiresIn: '1d' } 
        );

        res.status(200).json({ 
            message: 'Connexion réussie.',
            token,
            utilisateur: { id: utilisateur.id, email: utilisateur.email, nom_complet: utilisateur.nom_complet }
        });

    } catch (erreur) {
        console.error('Erreur lors de la connexion:', erreur);
        res.status(500).json({ message: 'Erreur interne du serveur.' });
    }
};


module.exports = {
    inscription,
    connexion,
};