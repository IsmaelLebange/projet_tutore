// src/models/Produit.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Annonce = require('./Annonce');
const TypeProduit = require('./TypeProduit');

const Produit = sequelize.define('Produit', {
    etat: {
        type: DataTypes.STRING(50),
        allowNull: false,
    },
    num: {
        type: DataTypes.INTEGER,
        allowNull: true,
    },
    id_annonce: {
        type: DataTypes.INTEGER,
        allowNull: false,
        unique: true, 
        references: { model: Annonce, key: 'id' } 
    },
    id_type: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: TypeProduit, key: 'id' } 
    },
}, {
    timestamps: false,
});

Produit.belongsTo(Annonce, { foreignKey: 'id_annonce', as: 'annonce' });
Annonce.hasOne(Produit, { foreignKey: 'id_annonce', as: 'produit' }); 

Produit.belongsTo(TypeProduit, { foreignKey: 'id_type', as: 'type' });
TypeProduit.hasMany(Produit, { foreignKey: 'id_type', as: 'produits' });

module.exports = Produit;