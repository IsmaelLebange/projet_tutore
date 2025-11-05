const path = require('path');
const AnnonceService = require('../services/annonceService');
const ProduitService = require('../services/produitService');
const ServiceService = require('../services/serviceService');
const CategorieProduit = require('../models/CategorieProduit');
const TypeProduit = require('../models/TypeProduit');
const CategorieService = require('../models/CategorieService');
const TypeService = require('../models/TypeService');
const PhotoProduit = require('../models/PhotoProduit');
const PhotoService = require('../models/PhotoService');

exports.ajouterAnnonce = async (req, res) => {
  try {
    const utilisateur = req.utilisateur;
    if (!utilisateur) return res.status(401).json({ message: 'Utilisateur non authentifié.' });
    if (utilisateur.etat !== 'Actif') return res.status(403).json({ message: 'Compte bloqué.' });

    const { titre, description, prix, type, categorie, typeSpecifique } = req.body;
    if (!titre || !description || !prix || !type || !categorie || !typeSpecifique)
      return res.status(400).json({ message: 'Données incomplètes.' });

    // 🔹 Création de l’annonce principale
    const annonce = await AnnonceService.creerAnnonce({
      titre,
      description,
      prix,
      id_utilisateur: utilisateur.id,
      id_adresse: utilisateur.id_adresse_fixe,
      date_publication: new Date(),
    });

    let objetCree = null;

    if (type === 'produit') {
      const cat = await CategorieProduit.findOne({ where: { nom_categorie: categorie } });
      if (!cat) return res.status(400).json({ message: `Catégorie produit '${categorie}' introuvable.` });

      const typeP = await TypeProduit.findOne({ where: { nom_type: typeSpecifique, id_categorie: cat.id } });
      if (!typeP) return res.status(400).json({ message: `Type produit '${typeSpecifique}' introuvable.` });

      objetCree = await ProduitService.creerProduit({
        id_annonce: annonce.id,
        id_type: typeP.id,
        etat: 'Neuf',
      });

    } else if (type === 'service') {
      const cat = await CategorieService.findOne({ where: { nom_categorie: categorie } });
      if (!cat) return res.status(400).json({ message: `Catégorie service '${categorie}' introuvable.` });

      const typeS = await TypeService.findOne({ where: { nom_type: typeSpecifique, id_categorie: cat.id } });
      if (!typeS) return res.status(400).json({ message: `Type service '${typeSpecifique}' introuvable.` });

      objetCree = await ServiceService.creerService({
        id_annonce: annonce.id,
        id_type: typeS.id,
        type_service: typeSpecifique,
        disponibilite: 'Disponible',
      });
    }

    // 🔹 Gestion des fichiers images
    if (req.files && req.files.length > 0) {
      const urls = req.files.map(f => `/uploads/${path.basename(f.path)}`);
      if (type === 'produit' && objetCree) {
        for (const url of urls) await PhotoProduit.create({ url, id_produit: objetCree.id });
      } else if (type === 'service' && objetCree) {
        for (const url of urls) await PhotoService.create({ url, id_service: objetCree.id });
      }
    }

    return res.status(201).json({ message: 'Annonce ajoutée avec succès', annonce });

  } catch (error) {
    console.error('Erreur ajout annonce:', error);
    res.status(500).json({ message: 'Erreur serveur lors de la création.', erreur: error.message });
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
