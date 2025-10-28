// models/Adresse.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database'); 

const Adresse = sequelize.define('Adresse', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
    },
    rue: {
        type: DataTypes.STRING,
        allowNull: true,
    },
    ville: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    quartier: {
        type: DataTypes.STRING,
        allowNull: true,
    },
    latitude: {
        type: DataTypes.FLOAT, 
        allowNull: true,
    },
    longitude: {
        type: DataTypes.FLOAT,
        allowNull: true,
    },
}, {
    timestamps: false, 
});

// ✅ GARDE l'association

module.exports = Adresse;