// src/models/Annonce.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Utilisateur = require('./utilisateur');
const Adresse = require('./Adresse');

const Annonce = sequelize.define('Annonce', {
    titre: {
        type: DataTypes.STRING(255),
        allowNull: false,
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    prix: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    date_publication: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
    },
    statut_annonce: {
        type: DataTypes.STRING(50),
        allowNull: false,
        defaultValue: 'Active',
    },
    id_utilisateur: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Utilisateur, key: 'id' } // FK vers Utilisateur (Vendeur) [cite: 162, 164]
    },
    id_adresse: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Adresse, key: 'id' } // FK vers Adresse (Lieu de l'annonce) [cite: 163, 164]
    },
}, {
    timestamps: false,
});

Annonce.belongsTo(Utilisateur, { foreignKey: 'id_utilisateur', as: 'vendeur' });
Utilisateur.hasMany(Annonce, { foreignKey: 'id_utilisateur', as: 'annonces' });

Annonce.belongsTo(Adresse, { foreignKey: 'id_adresse', as: 'adresseAnnonce' });
Adresse.hasMany(Annonce, { foreignKey: 'id_adresse', as: 'annonces' });

module.exports = Annonce;