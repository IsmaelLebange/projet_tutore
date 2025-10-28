const Utilisateur = require('../models/utilisateur');
const Adresse = require('../models/Adresse'); 
const { Op } = require('sequelize')

const creerUtilisateur = async (donneesUtilisateur) => {
    return await Utilisateur.create(donneesUtilisateur);
};

const trouverUtilisateurParId = (id) => {
    return Utilisateur.findByPk(id, {
        attributes: { exclude: ['mot_de_passe'] },
        // On inclut l'adresse fixe pour l'affichage du profil
        include: [{ model: Adresse, as: 'adresseFixe' }] 
    });
};
const trouverUtilisateurParEmail = async (email) => {
    return await Utilisateur.findOne({ 
        where: { email },
        include: [{
            model: Adresse,
            as: 'adresseFixe'
        }]
    });
};


const mettreAJourUtilisateur = async (id, donnees) => {
    return await Utilisateur.update(donnees, {
        where: { id }
    });
};
const trouverTousLesUtilisateurs = async () => {
    return await Utilisateur.findAll({
        include: [{
            model: Adresse,
            as: 'adresseFixe'
        }],
        order: [['date_inscription', 'DESC']]
    });
};

module.exports = {
    creerUtilisateur,
    trouverUtilisateurParEmail,
    trouverUtilisateurParId,
    mettreAJourUtilisateur,
    trouverTousLesUtilisateurs,
};