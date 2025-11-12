const serviceService = require('../services/serviceService');

class ServiceController {
  
  async obtenirTousServices(req, res) {
    try {
      const options = {
        page: req.query.page,
        limit: req.query.limit,
        categorie: req.query.categorie,
        type: req.query.type,
        prixMin: req.query.prixMin,
        prixMax: req.query.prixMax,
        recherche: req.query.recherche,
        disponibilite: req.query.disponibilite
      };

      const resultat = await serviceService.obtenirTousServices(options);
      res.json(resultat);
    } catch (error) {
      console.error('❌ Erreur controller obtenirTousServices:', error);
      res.status(500).json({ 
        message: 'Erreur lors de la récupération des services',
        error: error.message 
      });
    }
  }

  async obtenirServiceParId(req, res) {
    try {
      const service = await serviceService.obtenirServiceParId(req.params.id);
      res.json(service);
    } catch (error) {
      console.error('❌ Erreur controller obtenirServiceParId:', error);
      if (error.message === 'Service introuvable') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ 
        message: 'Erreur lors de la récupération du service',
        error: error.message 
      });
    }
  }

  async obtenirCategories(req, res) {
    try {
      const categories = await serviceService.obtenirCategories();
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
      const types = await serviceService.obtenirTypesParCategorie(req.params.categorieId);
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

module.exports = new ServiceController();