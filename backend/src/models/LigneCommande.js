// src/models/LigneCommande.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Transaction = require('./Transaction');
const Produit = require('./Produit');
const Service = require('./Service');

const LigneCommande = sequelize.define('LigneCommande', {
    quantite: {
        type: DataTypes.INTEGER, 
        allowNull: false,
    },
    etat: {
        type: DataTypes.STRING(50), 
        allowNull: false,
    },
    id_transaction: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Transaction, key: 'id' } 
    },
    // Clés étrangères pour le polymorphisme (un seul doit être non-null)
    id_produit: {
        type: DataTypes.INTEGER,
        allowNull: true, // [cite: 199]
        references: { model: Produit, key: 'id' } 
    },
    id_service: {
        type: DataTypes.INTEGER,
        allowNull: true, // [cite: 199]
        references: { model: Service, key: 'id' } 
    },
}, {
    timestamps: false,
});

LigneCommande.belongsTo(Transaction, { foreignKey: 'id_transaction', as: 'transaction' });
Transaction.hasMany(LigneCommande, { foreignKey: 'id_transaction', as: 'lignesCommande' });

LigneCommande.belongsTo(Produit, { foreignKey: 'id_produit', as: 'produit' });
LigneCommande.belongsTo(Service, { foreignKey: 'id_service', as: 'service' });

module.exports = LigneCommande;