// src/models/PhotoProduit.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Produit = require('./Produit');

const PhotoProduit = sequelize.define('PhotoProduit', {
    url: {
        type: DataTypes.TEXT, // URL de l'image [cite: 191]
        allowNull: false,
    },
    id_produit: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Produit, key: 'id' } // FK vers Produit [cite: 190, 192]
    },
}, {
    timestamps: false,
});

PhotoProduit.belongsTo(Produit, { foreignKey: 'id_produit', as: 'produit' });
Produit.hasMany(PhotoProduit, { foreignKey: 'id_produit', as: 'photos' });

module.exports = PhotoProduit;