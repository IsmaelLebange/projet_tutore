// src/models/Service.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Annonce = require('./Annonce');
const TypeService = require('./TypeService');

const Service = sequelize.define('Service', {
    type_service: {
        type: DataTypes.STRING(100), 
        allowNull: false,
    },
    disponibilite: {
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
        unique: true, // Un Service doit avoir une seule Annonce et vice-versa
        references: { model: Annonce, key: 'id' } // FK vers Annonce [cite: 179, 184]
    },
    id_type: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: { model: TypeService, key: 'id' } // FK vers TypeService [cite: 180, 185]
    },
}, {
    timestamps: false,
});

Service.belongsTo(Annonce, { foreignKey: 'id_annonce', as: 'annonce' });
Annonce.hasOne(Service, { foreignKey: 'id_annonce', as: 'service' }); // Relation 1:1

Service.belongsTo(TypeService, { foreignKey: 'id_type', as: 'type' });
TypeService.hasMany(Service, { foreignKey: 'id_type', as: 'services' });

module.exports = Service;