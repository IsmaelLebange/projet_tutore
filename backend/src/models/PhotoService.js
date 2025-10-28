// src/models/PhotoService.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Service = require('./Service');

const PhotoService = sequelize.define('PhotoService', {
    url: {
        type: DataTypes.TEXT, // URL de l'image [cite: 196]
        allowNull: false,
    },
    id_service: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: Service, key: 'id' } // FK vers Service [cite: 195, 197]
    },
}, {
    timestamps: false,
});

PhotoService.belongsTo(Service, { foreignKey: 'id_service', as: 'service' });
Service.hasMany(PhotoService, { foreignKey: 'id_service', as: 'photos' });

module.exports = PhotoService;