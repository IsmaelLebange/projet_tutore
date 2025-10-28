// src/models/Notation.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Utilisateur = require('./utilisateur');
const Transaction = require('./Transaction');

const Notation = sequelize.define('Notation', {
    note: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    commentaire: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    date_notation: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
    },
    id_noteur: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Utilisateur, key: 'id' } // L'utilisateur qui note [cite: 201]
    },
    id_note_a_qui: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Utilisateur, key: 'id' } // L'utilisateur noté [cite: 201]
    },
    id_transaction: {
        type: DataTypes.INTEGER,
        allowNull: false,
        unique: true, // Une notation par transaction
        references: { model: Transaction, key: 'id' } 
    },
}, {
    timestamps: false,
});

Notation.belongsTo(Utilisateur, { foreignKey: 'id_noteur', as: 'noteur' });
Notation.belongsTo(Utilisateur, { foreignKey: 'id_note_a_qui', as: 'utilisateurNote' });
Notation.belongsTo(Transaction, { foreignKey: 'id_transaction', as: 'transaction' });

module.exports = Notation;