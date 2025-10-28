// src/models/TypeService.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database'); 
const CategorieService = require('./CategorieService');

const TypeService = sequelize.define('TypeService', {
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
        references: { model: CategorieService, key: 'id' } // FK vers CategorieService [cite: 151, 152]
    },
}, {
    timestamps: false,
});

TypeService.belongsTo(CategorieService, { foreignKey: 'id_categorie', as: 'categorie' });
CategorieService.hasMany(TypeService, { foreignKey: 'id_categorie', as: 'types' });

module.exports = TypeService;