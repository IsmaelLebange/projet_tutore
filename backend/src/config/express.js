// src/config/express.js
const express = require('express');
const cors = require('cors');

const setupExpress = (app) => {
    // Middleware pour parser les requêtes JSON (INDISPENSABLE pour req.body)
    app.use(express.json()); 

    // Middleware pour parser les requêtes URL-encoded (si tu avais des formulaires classiques)
    app.use(express.urlencoded({ extended: true })); 
    
    // Middleware de sécurité pour autoriser les requêtes venant d'autres domaines (ton Flutter)
    app.use(cors());
    
    // Tu peux ajouter d'autres middlewares de sécurité ici si besoin
};

module.exports = setupExpress;