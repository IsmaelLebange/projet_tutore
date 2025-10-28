// src/models/CategorieProduit.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database'); 

const CategorieProduit = sequelize.define('CategorieProduit', {
    nom_categorie: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    num: {
        type: DataTypes.INTEGER,
        allowNull: true,
    },
}, {
    timestamps: false,
});

module.exports = CategorieProduit;