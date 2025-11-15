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
const Utilisateur = require('../models/utilisateur'); // ⚠️ AJOUT
const ComptePaiement = require('../models/ComptePaiement'); 



exports.ajouterAnnonce = async (req, res) => {
  console.log('📝 === AJOUT ANNONCE ===');
  console.log('Body:', req.body);
  console.log('Fichiers:', req.files ? req.files.length : 0);
  console.log('User ID:', req.idUtilisateur);

  try {
    const utilisateurId = req.idUtilisateur;
    
    if (!utilisateurId) {
      console.log('❌ Utilisateur non authentifié');
      return res.status(401).json({ message: 'Utilisateur non authentifié.' });
    }

    console.log('✅ Utilisateur authentifié, ID:', utilisateurId);

    // Récupérer l'utilisateur depuis la DB
    const utilisateur = await Utilisateur.findByPk(utilisateurId);
    
    if (!utilisateur) {
      console.log('❌ Utilisateur introuvable en DB');
      return res.status(404).json({ message: 'Utilisateur introuvable.' });
    }

    console.log('✅ Utilisateur trouvé:', utilisateur.email);

    if (utilisateur.etat !== 'Actif') {
      console.log('❌ Compte bloqué');
      return res.status(403).json({ message: 'Compte bloqué ou inactif.' });
    }

    console.log('✅ Compte actif');

    // ✅ VÉRIFICATION OBLIGATOIRE : Le vendeur DOIT avoir au moins 1 compte de paiement
    const comptesVendeur = await ComptePaiement.findAll({
      where: { id_utilisateur: utilisateurId }
    });

    if (comptesVendeur.length === 0) {
      console.log('❌ Aucun compte de paiement trouvé pour le vendeur');
      return res.status(400).json({ 
        message: 'Vous devez avoir au moins un compte de paiement pour poster une annonce.',
        code: 'COMPTE_PAIEMENT_REQUIS',
        action: 'CREER_COMPTE_PAIEMENT'
      });
    }

    console.log(`✅ Vendeur a ${comptesVendeur.length} compte(s) de paiement`);

    // Validation des données
    const { titre, description, prix, type, categorie, typeSpecifique } = req.body;
    
    if (!titre || !description || !prix || !type || !categorie || !typeSpecifique) {
      console.log('❌ Données incomplètes');
      return res.status(400).json({ 
        message: 'Données incomplètes.',
        manquants: {
          titre: !titre,
          description: !description,
          prix: !prix,
          type: !type,
          categorie: !categorie,
          typeSpecifique: !typeSpecifique
        }
      });
    }

    console.log('✅ Données complètes validées');

    // Création de l'annonce principale
    console.log('📝 Création annonce...');
    const annonce = await AnnonceService.creerAnnonce({
      titre,
      description,
      prix: parseFloat(prix),
      id_utilisateur: utilisateur.id,
      id_adresse: utilisateur.id_adresse_fixe || null,
      date_publication: new Date(),
    });

    console.log('✅ Annonce créée, ID:', annonce.id);

    let objetCree = null;

    // Traitement selon le type (Produit ou Service)
    if (type === 'produit') {
      console.log('🛒 Type PRODUIT détecté');
      
      const cat = await CategorieProduit.findOne({ where: { nom_categorie: categorie } });
      if (!cat) {
        console.log(`❌ Catégorie produit "${categorie}" introuvable`);
        return res.status(400).json({ message: `Catégorie produit '${categorie}' introuvable.` });
      }
      console.log(`✅ Catégorie produit trouvée: ${cat.nom_categorie} (ID: ${cat.id})`);

      const typeP = await TypeProduit.findOne({ 
        where: { 
          nom_type: typeSpecifique, 
          id_categorie: cat.id 
        } 
      });
      
      if (!typeP) {
        console.log(`❌ Type produit "${typeSpecifique}" introuvable`);
        return res.status(400).json({ message: `Type produit '${typeSpecifique}' introuvable pour cette catégorie.` });
      }
      console.log(`✅ Type produit trouvé: ${typeP.nom_type} (ID: ${typeP.id})`);

      objetCree = await ProduitService.creerProduit({
        id_annonce: annonce.id,
        id_type: typeP.id,
        etat: 'Neuf',
      });

      console.log('✅ Produit créé, ID:', objetCree.id);

    } else if (type === 'service') {
      console.log('🔧 Type SERVICE détecté');
      
      const cat = await CategorieService.findOne({ where: { nom_categorie: categorie } });
      if (!cat) {
        console.log(`❌ Catégorie service "${categorie}" introuvable`);
        return res.status(400).json({ message: `Catégorie service '${categorie}' introuvable.` });
      }
      console.log(`✅ Catégorie service trouvée: ${cat.nom_categorie} (ID: ${cat.id})`);

      const typeS = await TypeService.findOne({ 
        where: { 
          nom_type: typeSpecifique, 
          id_categorie: cat.id 
        } 
      });
      
      if (!typeS) {
        console.log(`❌ Type service "${typeSpecifique}" introuvable`);
        return res.status(400).json({ message: `Type service '${typeSpecifique}' introuvable pour cette catégorie.` });
      }
      console.log(`✅ Type service trouvé: ${typeS.nom_type} (ID: ${typeS.id})`);

      objetCree = await ServiceService.creerService({
        id_annonce: annonce.id,
        id_type: typeS.id,
        type_service: typeSpecifique,
        disponibilite: 'Disponible',
      });

      console.log('✅ Service créé, ID:', objetCree.id);

    } else {
      console.log(`❌ Type "${type}" invalide`);
      return res.status(400).json({ message: 'Type doit être "produit" ou "service".' });
    }

    // Gestion des fichiers images
    if (req.files && req.files.length > 0) {
      console.log(`📷 Traitement de ${req.files.length} image(s)...`);
      
      const urls = req.files.map(f => `/uploads/${path.basename(f.path)}`);
      console.log('URLs générées:', urls);

      if (type === 'produit' && objetCree) {
        for (const url of urls) {
          await PhotoProduit.create({ 
            url, 
            id_produit: objetCree.id 
          });
        }
        console.log(`✅ ${urls.length} photo(s) produit créée(s)`);
        
      } else if (type === 'service' && objetCree) {
        for (const url of urls) {
          await PhotoService.create({ 
            url, 
            id_service: objetCree.id 
          });
        }
        console.log(`✅ ${urls.length} photo(s) service créée(s)`);
      }
    } else {
      console.log('ℹ️ Aucune image fournie');
    }

    const annonceJson = annonce.toJSON ? annonce.toJSON() : annonce;
    
    console.log('✅✅✅ Annonce ajoutée avec succès, ID:', annonce.id);

    return res.status(201).json({ 
      success: true,
      message: 'Annonce ajoutée avec succès', 
      annonce: annonceJson 
    });

  } catch (error) {
    console.error('❌ Erreur ajout annonce:', error);
    console.error('Stack trace:', error.stack);
    
    return res.status(500).json({ 
      success: false,
      message: 'Erreur serveur lors de la création de l\'annonce.', 
      error: error.message 
    });
  }
};


exports.obtenirAnnonces = async (req, res) => {
  try {
    console.log('📥 Récupération de toutes les annonces...');
    const annonces = await AnnonceService.trouverTout();
    console.log(`✅ ${annonces.length} annonce(s) récupérée(s)`);
    return res.status(200).json(annonces);
  } catch (error) {
    console.error('❌ Erreur récupération annonces:', error);
    return res.status(500).json({ 
      message: 'Erreur serveur lors de la récupération des annonces.' 
    });
  }
};

// ...existing code (ajouterAnnonce, obtenirAnnonces)...

// 🆕 Récupérer MES annonces
exports.obtenirMesAnnonces = async (req, res) => {
  try {
    console.log('📋 === MES ANNONCES ===');
    console.log('User ID:', req.idUtilisateur);

    if (!req.idUtilisateur) {
      return res.status(401).json({ 
        success: false,
        message: 'Utilisateur non authentifié.' 
      });
    }

    const annonces = await AnnonceService.trouverParUtilisateur(req.idUtilisateur);

    console.log(`✅ ${annonces.length} annonce(s) récupérée(s)`);

    return res.status(200).json({
      success: true,
      count: annonces.length,
      annonces: annonces
    });

  } catch (error) {
    console.error('❌ Erreur obtenirMesAnnonces:', error);
    return res.status(500).json({
      success: false,
      message: 'Erreur serveur.',
      error: error.message
    });
  }
};

// 🆕 Supprimer une annonce
exports.supprimerAnnonce = async (req, res) => {
  try {
    console.log('🗑️ === SUPPRESSION ANNONCE ===');
    console.log('Annonce ID:', req.params.id);
    console.log('User ID:', req.idUtilisateur);

    const annonceId = parseInt(req.params.id);

    if (!req.idUtilisateur) {
      return res.status(401).json({ 
        success: false,
        message: 'Utilisateur non authentifié.' 
      });
    }

    await AnnonceService.supprimer(annonceId, req.idUtilisateur);

    console.log(`✅ Annonce ${annonceId} supprimée`);

    return res.status(200).json({
      success: true,
      message: 'Annonce supprimée avec succès'
    });

  } catch (error) {
    console.error('❌ Erreur supprimerAnnonce:', error);
    return res.status(error.message.includes('Non autorisé') ? 403 : 500).json({
      success: false,
      message: error.message
    });
  }
};

