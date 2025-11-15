// config/database.js
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize({
    dialect: process.env.DB_DIALECT,
    storage: process.env.DB_STORAGE,
    logging: false,
    define: {
        freezeTableName: true,
    }
});

const connectDB = async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ Connexion DB OK');

        // Charge tous les modèles (associations incluses)
        const Adresse = require('../models/Adresse');
        const Utilisateur = require('../models/utilisateur');

        // ✅ AJOUTE l'association manquante ici
        
        require('../models/index');

        const syncOption = { alter: true }; // Use alter to add new columns without dropping tables
        await sequelize.sync(syncOption);
        
        console.log(`✅ Tables synchronisées (Mode: ${process.env.NODE_ENV || 'development'})`);

    } catch (error) {
        console.error('❌ Erreur DB:', error);
        process.exit(1);
    }
};

module.exports = { sequelize, connectDB };