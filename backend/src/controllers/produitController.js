const produitService = require('../services/produitService');

class ProduitController {
  
  async obtenirTousProduits(req, res) {
    try {
      const options = {
        page: req.query.page,
        limit: req.query.limit,
        categorie: req.query.categorie,
        type: req.query.type,
        prixMin: req.query.prixMin,
        prixMax: req.query.prixMax,
        recherche: req.query.recherche
      };

      const resultat = await produitService.obtenirTousProduits(options);
      res.json(resultat);
    } catch (error) {
      console.error('❌ Erreur controller obtenirTousProduits:', error);
      res.status(500).json({ 
        message: 'Erreur lors de la récupération des produits',
        error: error.message 
      });
    }
  }

  async obtenirProduitParId(req, res) {
    try {
      const produit = await produitService.obtenirProduitParId(req.params.id);
      res.json(produit);
    } catch (error) {
      console.error('❌ Erreur controller obtenirProduitParId:', error);
      if (error.message === 'Produit introuvable') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ 
        message: 'Erreur lors de la récupération du produit',
        error: error.message 
      });
    }
  }

  async obtenirCategories(req, res) {
    try {
      const categories = await produitService.obtenirCategories();
      res.json(categories);
    } catch (error) {
      console.error('❌ Erreur controller obtenirCategories:', error);
      res.status(500).json({ 
        message: 'Erreur lors de la récupération des catégories',
        error: error.message 
      });
    }
  }

  async obtenirTypesParCategorie(req, res) {
    try {
      const types = await produitService.obtenirTypesParCategorie(req.params.categorieId);
      res.json(types);
    } catch (error) {
      console.error('❌ Erreur controller obtenirTypesParCategorie:', error);
      res.status(500).json({ 
        message: 'Erreur lors de la récupération des types',
        error: error.message 
      });
    }
  }
}

module.exports = new ProduitController();