const Annonce = require('../models/Annonce');
const Utilisateur = require('../models/utilisateur');
const Adresse = require('../models/Adresse');
const Produit = require('../models/Produit');
const Service = require('../models/Service');
const PhotoProduit = require('../models/PhotoProduit');
const PhotoService = require('../models/PhotoService');
const CategorieProduit = require('../models/CategorieProduit');
const CategorieService = require('../models/CategorieService');
const TypeProduit = require('../models/TypeProduit');
const TypeService = require('../models/TypeService');


class AnnonceService {
  
  async creerAnnonce(data) {
    try {
      return await Annonce.create(data);
    } catch (error) {
      console.error('Erreur création annonce:', error);
      throw error;
    }
  }

  async trouverTout() {
    try {
      return await Annonce.findAll({
        include: [
          {
            model: Utilisateur,
            as: 'vendeur',
            attributes: ['id', 'prenom', 'nom', 'reputation']
          },
          {
            model: Adresse,
            as: 'adresseAnnonce',
            attributes: ['ville', 'quartier']
          }
        ],
        order: [['date_publication', 'DESC']]
      });
    } catch (error) {
      console.error('Erreur récupération annonces:', error);
      throw error;
    }
  }

  // 🔧 MODIFIÉ : Renvoie image (String) au lieu de photos (Array)
  async trouverParUtilisateur(utilisateurId) {
    try {
      console.log(`🔍 Recherche annonces pour utilisateur ID: ${utilisateurId}`);

      const annonces = await Annonce.findAll({
        where: { id_utilisateur: utilisateurId },
        include: [
          {
            model: Adresse,
            as: 'adresseAnnonce',
            attributes: ['ville', 'quartier', 'rue']
          }
        ],
        order: [['date_publication', 'DESC']]
      });

      console.log(`✅ ${annonces.length} annonce(s) trouvée(s)`);

      const annoncesEnrichies = await Promise.all(
        annonces.map(async (annonce) => {
          const annonceJson = annonce.toJSON();

          // Chercher si c'est un produit
          const produit = await Produit.findOne({
            where: { id_annonce: annonce.id },
            include: [
              {
                model: TypeProduit,
                as: 'type',
                include: [
                  {
                    model: CategorieProduit,
                    as: 'categorie'
                  }
                ]
              }
            ]
          });

          if (produit) {
            const photos = await PhotoProduit.findAll({
              where: { id_produit: produit.id },
              attributes: ['url'],
              limit: 1 // ⚠️ Prendre que la première
            });

            return {
              ...annonceJson,
              type: 'produit',
              categorie: produit.type?.categorie?.nom_categorie || 'Non définie',
              typeSpecifique: produit.type?.nom_type || 'Non défini',
              etat: produit.etat,
              image: photos.length > 0 ? photos[0].url : null // ⚠️ image au lieu de photos
            };
          }

          // Chercher si c'est un service
          const service = await Service.findOne({
            where: { id_annonce: annonce.id },
            include: [
              {
                model: TypeService,
                as: 'type',
                include: [
                  {
                    model: CategorieService,
                    as: 'categorie'
                  }
                ]
              }
            ]
          });

          if (service) {
            const photos = await PhotoService.findAll({
              where: { id_service: service.id },
              attributes: ['url'],
              limit: 1 // ⚠️ Prendre que la première
            });

            return {
              ...annonceJson,
              type: 'service',
              categorie: service.type?.categorie?.nom_categorie || 'Non définie',
              typeSpecifique: service.type?.nom_type || 'Non défini',
              disponibilite: service.disponibilite,
              image: photos.length > 0 ? photos[0].url : null // ⚠️ image au lieu de photos
            };
          }

          return {
            ...annonceJson,
            type: 'inconnu',
            image: null // ⚠️ image au lieu de photos
          };
        })
      );

      return annoncesEnrichies;

    } catch (error) {
      console.error('❌ Erreur trouverParUtilisateur:', error);
      throw error;
    }
  }

  async trouverParId(id) {
    try {
      return await Annonce.findByPk(id);
    } catch (error) {
      console.error('Erreur récupération annonce:', error);
      throw error;
    }
  }

  async supprimer(id, utilisateurId) {
    try {
      const annonce = await Annonce.findByPk(id);
      
      if (!annonce) {
        throw new Error('Annonce introuvable');
      }

      if (annonce.id_utilisateur !== utilisateurId) {
        throw new Error('Non autorisé à supprimer cette annonce');
      }

      await annonce.destroy();
      return true;
    } catch (error) {
      console.error('Erreur suppression annonce:', error);
      throw error;
    }
  }
}

module.exports = new AnnonceService();