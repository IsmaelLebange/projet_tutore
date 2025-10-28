// src/models/ComptePaiement.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Utilisateur = require('./utilisateur');

const ComptePaiement = sequelize.define('ComptePaiement', {
    numero_compte: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    entreprise: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    est_principal: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
    },
    // Clé étrangère vers l'Utilisateur
    id_utilisateur: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: Utilisateur,
            key: 'id',
        }
    }
}, {
    timestamps: true,
});

// Définition des relations (ComptePaiement <-> Utilisateur)
ComptePaiement.belongsTo(Utilisateur, { foreignKey: 'id_utilisateur', as: 'utilisateur' });
Utilisateur.hasMany(ComptePaiement, { foreignKey: 'id_utilisateur', as: 'comptesPaiement' });

module.exports = ComptePaiement;