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
        type: DataTypes.ENUM('En_attente', 'En_attente_confirmation', 'Confirmée', 'Livrée', 'Validée', 'Rejetée'), 
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
        references: { model: Utilisateur, key: 'id' }
    },
    id_vendeur: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Utilisateur, key: 'id' }
    },
    id_compte_paiement_vendeur: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: ComptePaiement, key: 'id' }
    },
    // ✅ AJOUT DES NOUVEAUX CHAMPS
    confirmation_acheteur: {
        type: DataTypes.BOOLEAN,
        allowNull: true, // Nullable pour migration
        defaultValue: false,
    },
    confirmation_vendeur: {
        type: DataTypes.BOOLEAN,
        allowNull: true, // Nullable pour migration
        defaultValue: false,
    }
}, {
    timestamps: false,
});

Transaction.belongsTo(Utilisateur, { foreignKey: 'id_acheteur', as: 'acheteur' });
Transaction.belongsTo(Utilisateur, { foreignKey: 'id_vendeur', as: 'vendeur' });
Transaction.belongsTo(ComptePaiement, { foreignKey: 'id_compte_paiement_vendeur', as: 'comptePaiementVendeur' });

module.exports = Transaction;