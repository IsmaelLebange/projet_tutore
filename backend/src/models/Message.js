// src/models/Message.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Utilisateur = require('./utilisateur');

const Message = sequelize.define('Message', {
    contenu: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
    date_envoi: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
    },
    id_expediteur: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Utilisateur, key: 'id' } 
    },
    id_recepteur: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Utilisateur, key: 'id' } 
    },
}, {
    timestamps: false,
});

Message.belongsTo(Utilisateur, { foreignKey: 'id_expediteur', as: 'expediteur' });
Message.belongsTo(Utilisateur, { foreignKey: 'id_recepteur', as: 'recepteur' });

module.exports = Message;