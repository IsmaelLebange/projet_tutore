// src/controllers/annonceController.js

const AnnonceService = require('../services/annonceService');
const ProduitService = require('../services/produitService');
const ServiceService = require('../services/serviceService');
const TypeProduit = require('../models/TypeProduit');
const TypeService = require('../models/TypeService');
const CategorieProduit = require('../models/CategorieProduit');
const CategorieService = require('../models/CategorieService');

exports.ajouterAnnonce = async (req, res) => {
  try {
    const utilisateur = req.utilisateur;

    if (!utilisateur) {
      return res.status(401).json({ message: 'Utilisateur non authentifié.' });
    }

    if (utilisateur.etat !== 'Actif') {
      return res.status(403).json({ message: 'Compte bloqué.' });
    }

    const { titre, description, prix, type, categorie, typeSpecifique } = req.body;

    if (!titre || !description || !prix || !type || !categorie || !typeSpecifique) {
      return res.status(400).json({ message: 'Données incomplètes.' });
    }

    // 🔹 Création de l’annonce principale
    const annonce = await AnnonceService.creerAnnonce({
      titre,
      description,
      prix,
      id_utilisateur: utilisateur.id,
      id_adresse: utilisateur.id_adresse_fixe,
      date_publication: new Date(),
    });

    // 🔹 Gestion selon le type d’annonce
    if (type === 'produit') {
      // Chercher la catégorie produit
      const cat = await CategorieProduit.findOne({ where: { nom_categorie: categorie } });
      if (!cat) return res.status(400).json({ message: `Catégorie produit '${categorie}' introuvable.` });

      // Chercher le type produit
      const typeP = await TypeProduit.findOne({ where: { nom_type: typeSpecifique, id_categorie: cat.id } });
      if (!typeP) return res.status(400).json({ message: `Type produit '${typeSpecifique}' introuvable.` });

      // Créer le produit
      await ProduitService.creerProduit({
        id_annonce: annonce.id,
        id_type: typeP.id,
        etat: 'Neuf',
        dimensions: null,
      });

    } else if (type === 'service') {
      // Chercher la catégorie service
      const cat = await CategorieService.findOne({ where: { nom_categorie: categorie } });
      if (!cat) return res.status(400).json({ message: `Catégorie service '${categorie}' introuvable.` });

      // Chercher le type service
      const typeS = await TypeService.findOne({ where: { nom_type: typeSpecifique, id_categorie: cat.id } });
      if (!typeS) return res.status(400).json({ message: `Type service '${typeSpecifique}' introuvable.` });

      // Créer le service
      await ServiceService.creerService({
        id_annonce: annonce.id,
        id_type: typeS.id,
        disponibilite: 'Disponible',
        type_service: typeSpecifique,
      });
    }

    return res.status(201).json({
      message: 'Annonce ajoutée avec succès',
      annonce,
    });

  } catch (error) {
    console.error('Erreur ajout annonce:', error);
    res.status(500).json({
      message: 'Erreur serveur lors de la création.',
      erreur: error.message,
      stack: error.stack,
    });
  }
};

exports.obtenirAnnonces = async (req, res) => {
  try {
    const annonces = await AnnonceService.trouverTout();
    res.status(200).json(annonces);
  } catch (error) {
    console.error('Erreur récupération annonces:', error);
    res.status(500).json({ message: 'Erreur serveur lors de la récupération.' });
  }
};
