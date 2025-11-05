const CategorieProduit = require('../models/CategorieProduit');
const CategorieService = require('../models/CategorieService');
const TypeProduit = require('../models/TypeProduit');
const TypeService = require('../models/TypeService');

// 📦 Liste des catégories produits
exports.obtenirCategoriesProduits = async (req, res) => {
  try {
    const categories = await CategorieProduit.findAll({ include: ['types'] });
    res.json(categories);
  } catch (err) {
    res.status(500).json({ message: 'Erreur récupération catégories produits', erreur: err.message });
  }
};

// 📦 Liste des catégories services
exports.obtenirCategoriesServices = async (req, res) => {
  try {
    const categories = await CategorieService.findAll({ include: ['types'] });
    res.json(categories);
  } catch (err) {
    res.status(500).json({ message: 'Erreur récupération catégories services', erreur: err.message });
  }
};
