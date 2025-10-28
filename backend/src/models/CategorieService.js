// src/models/CategorieService.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database'); 

const CategorieService = sequelize.define('CategorieService', {
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

module.exports = CategorieService;