// src/models/Transaction.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Utilisateur = require('./utilisateur');
const ComptePaiement = require('./ComptePaiement');

const Transaction = sequelize.define('Transaction', {
    date_transaction: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
    },
    montant: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    statut_transaction: {
        type: DataTypes.STRING(50),
        allowNull: false,
    },
    commission: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    id_acheteur: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Utilisateur, key: 'id' } // FK vers Utilisateur [cite: 198]
    },
    id_vendeur: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Utilisateur, key: 'id' } // FK vers Utilisateur [cite: 198]
    },
    id_compte_paiement_vendeur: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: ComptePaiement, key: 'id' } // FK vers ComptePaiement [cite: 198]
    }
}, {
    timestamps: false,
});

Transaction.belongsTo(Utilisateur, { foreignKey: 'id_acheteur', as: 'acheteur' });
Transaction.belongsTo(Utilisateur, { foreignKey: 'id_vendeur', as: 'vendeur' });
Transaction.belongsTo(ComptePaiement, { foreignKey: 'id_compte_paiement_vendeur', as: 'comptePaiementVendeur' });

// Les relations "hasMany" sont dans les modèles Utilisateur/ComptePaiement (fait en J2)

module.exports = Transaction;