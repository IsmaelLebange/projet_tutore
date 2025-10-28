// src/services/adresseService.js
const Adresse = require('../models/Adresse');

const creerAdresse = (donneesAdresse) => {
    return Adresse.create(donneesAdresse);
};

module.exports = {
    creerAdresse,
};