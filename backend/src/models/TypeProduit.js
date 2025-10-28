// src/models/TypeProduit.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database'); 
const CategorieProduit = require('./CategorieProduit');

const TypeProduit = sequelize.define('TypeProduit', {
    nom_type: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    num: {
        type: DataTypes.INTEGER,
        allowNull: true,
    },
    id_categorie: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: CategorieProduit, key: 'id' } // FK vers CategorieProduit [cite: 144, 145]
    },
}, {
    timestamps: false,
});

TypeProduit.belongsTo(CategorieProduit, { foreignKey: 'id_categorie', as: 'categorie' });
CategorieProduit.hasMany(TypeProduit, { foreignKey: 'id_categorie', as: 'types' });

module.exports = TypeProduit;