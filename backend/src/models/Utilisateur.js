// models/Utilisateur.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Adresse = require('./Adresse');

const Utilisateur = sequelize.define('Utilisateur', {
    prenom: { 
        type: DataTypes.STRING,
        allowNull: false,
    },
    nom: { 
        type: DataTypes.STRING,
        allowNull: false,
    },
    email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
    },
    mot_de_passe: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    numero_de_telephone: {
        type: DataTypes.STRING,
        allowNull: true,
    },
    date_inscription: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
    },
    reputation: {
        type: DataTypes.FLOAT,
        allowNull: false,
        defaultValue: 0.0,
    },
    id_adresse_fixe: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Adresse,
            key: 'id',
        }
    },
    etat: {
        type: DataTypes.STRING,
        allowNull: false,
        defaultValue: 'Actif',
    },
    // ✅ AJOUTE CE CHAMP
    role: {
        type: DataTypes.ENUM('utilisateur', 'admin', 'moderateur'),
        allowNull: false,
        defaultValue: 'utilisateur',
    }
}, {
    timestamps: false,
});

// ✅ GARDE l'association
Utilisateur.belongsTo(Adresse, { foreignKey: 'id_adresse_fixe', as: 'adresseFixe' });

module.exports = Utilisateur;