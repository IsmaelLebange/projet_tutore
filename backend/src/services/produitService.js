const Annonce = require('../models/Annonce');
const Utilisateur = require('../models/utilisateur');
const Adresse = require('../models/Adresse');
const Produit = require('../models/Produit');
const PhotoProduit = require('../models/PhotoProduit');
const PhotoUtilisateur = require('../models/PhotoUtilisateur');
const CategorieProduit = require('../models/CategorieProduit');
const TypeProduit = require('../models/TypeProduit');
const { Op } = require('sequelize');

class ProduitService {
  
  async obtenirTousProduits(options = {}) {
    try {
      const { 
        page = 1, 
        limit = 20, 
        categorie = null, 
        type = null, 
        prixMin = null, 
        prixMax = null,
        recherche = null 
      } = options;

      const parsedLimit = parseInt(limit, 10);
      const parsedPage = parseInt(page, 10);
      const offset = (parsedPage - 1) * parsedLimit;

      // Construction where clause pour Annonce
      const whereAnnonce = { statut_annonce: 'Active' };
      if (recherche) {
        whereAnnonce[Op.or] = [
          { titre: { [Op.like]: `%${recherche}%` } },
          { description: { [Op.like]: `%${recherche}%` } }
        ];
      }
      if (prixMin) whereAnnonce.prix = { ...whereAnnonce.prix, [Op.gte]: parseFloat(prixMin) };
      if (prixMax) whereAnnonce.prix = { ...whereAnnonce.prix, [Op.lte]: parseFloat(prixMax) };

      // Construction where clause pour Produit/Type
      const whereProduit = {};
      const whereType = {};
      if (categorie) {
        whereType.id_categorie = parseInt(categorie);
      }
      if (type) {
        whereProduit.id_type = parseInt(type);
      }

      const { count, rows: produits } = await Produit.findAndCountAll({
        where: whereProduit,
        include: [
          {
            model: Annonce,
            as: 'annonce',
            where: whereAnnonce,
            include: [
              {
                model: Utilisateur,
                as: 'vendeur',
                attributes: ['id', 'prenom', 'nom', 'reputation', 'numero_de_telephone'],
                include: [
                  {
                    model: PhotoUtilisateur,
                    as: 'photos',
                    attributes: ['url'],
                    limit: 1,
                    required: false
                  }
                ]
              },
              {
                model: Adresse,
                as: 'adresseAnnonce',
                attributes: ['ville', 'quartier', 'rue']
              }
            ]
          },
          {
            model: TypeProduit,
            as: 'type',
            where: Object.keys(whereType).length > 0 ? whereType : undefined,
            include: [
              {
                model: CategorieProduit,
                as: 'categorie',
                attributes: ['id', 'nom_categorie']
              }
            ]
          },
          {
            model: PhotoProduit,
            as: 'photos',
            attributes: ['url'],
            limit: 1
          }
        ],
        limit: parsedLimit,
        offset: offset,
        distinct: true
      });

      // Formater réponse
      const produitsFormates = produits.map(p => {
        const pJson = p.toJSON();
         if (!pJson.type || !pJson.type.categorie) {
          console.warn('⚠️ Produit sans type/catégorie:', {
            id: pJson.annonce?.id,
            id_type: pJson.id_type,
            type: pJson.type,
          });
        }
        return {
          id: pJson.annonce.id,
          titre: pJson.annonce.titre,
          description: pJson.annonce.description,
          prix: pJson.annonce.prix,
          datePublication: pJson.annonce.date_publication,
          statut: pJson.annonce.statut_annonce,
          image: pJson.photos && pJson.photos.length > 0 ? pJson.photos[0].url : null,
          etat: pJson.etat,
          
          categorieProduit: pJson.type?.categorie?.nom_categorie || 'Non définie',
          typeProduit: pJson.type?.nom_type || 'Non défini',
          vendeur: {
            id: pJson.annonce.vendeur.id,
            nom: `${pJson.annonce.vendeur.prenom} ${pJson.annonce.vendeur.nom}`,
            reputation: pJson.annonce.vendeur.reputation,
            telephone: pJson.annonce.vendeur.numero_de_telephone,
            photo: pJson.annonce.vendeur.photos && pJson.annonce.vendeur.photos.length > 0 
              ? pJson.annonce.vendeur.photos[0].url 
              : null
          },
          adresse: {
            ville: pJson.annonce.adresseAnnonce?.ville,
            quartier: pJson.annonce.adresseAnnonce?.quartier,
            rue: pJson.annonce.adresseAnnonce?.rue
          }
        };
      });

      return {
        produits: produitsFormates,
        pagination: {
          page: parsedPage,
          limit: parsedLimit,
          total: count,
          pages: Math.ceil(count / parsedLimit)
        }
      };

    } catch (error) {
      console.error('❌ Erreur obtenirTousProduits:', error);
      throw error;
    }
  }

  async obtenirProduitParId(id) {
    try {
      const produit = await Produit.findOne({
        include: [
          {
            model: Annonce,
            as: 'annonce',
            where: { id },
            include: [
              {
                model: Utilisateur,
                as: 'vendeur',
                attributes: ['id', 'prenom', 'nom', 'reputation', 'numero_de_telephone', 'email'],
                include: [
                  {
                    model: PhotoUtilisateur,
                    as: 'photos',
                    attributes: ['url']
                  }
                ]
              },
              {
                model: Adresse,
                as: 'adresseAnnonce'
              }
            ]
          },
          {
            model: TypeProduit,
            as: 'type',
            include: [
              {
                model: CategorieProduit,
                as: 'categorie'
              }
            ]
          },
          {
            model: PhotoProduit,
            as: 'photos',
            attributes: ['url']
          }
        ]
      });

      if (!produit) {
        throw new Error('Produit introuvable');
      }

      const pJson = produit.toJSON();
      return {
        id: pJson.annonce.id,
        titre: pJson.annonce.titre,
        description: pJson.annonce.description,
        prix: pJson.annonce.prix,
        datePublication: pJson.annonce.date_publication,
        statut: pJson.annonce.statut_annonce,
        images: pJson.photos.map(photo => photo.url),
        etat: pJson.etat,
        categorieProduit: pJson.type?.categorie?.nom_categorie || 'Non définie',
        typeProduit: pJson.type?.nom_type || 'Non défini',
        vendeur: {
          id: pJson.annonce.vendeur.id,
          nom: `${pJson.annonce.vendeur.prenom} ${pJson.annonce.vendeur.nom}`,
          email: pJson.annonce.vendeur.email,
          reputation: pJson.annonce.vendeur.reputation,
          telephone: pJson.annonce.vendeur.numero_de_telephone,
          photos: pJson.annonce.vendeur.photos.map(p => p.url)
        },
        adresse: pJson.annonce.adresseAnnonce
      };

    } catch (error) {
      console.error('❌ Erreur obtenirProduitParId:', error);
      throw error;
    }
  }

  async obtenirCategories() {
    try {
      return await CategorieProduit.findAll({
        attributes: ['id', 'nom_categorie'],
        order: [['nom_categorie', 'ASC']]
      });
    } catch (error) {
      console.error('❌ Erreur obtenirCategories:', error);
      throw error;
    }
  }

  async obtenirTypesParCategorie(categorieId) {
    try {
      return await TypeProduit.findAll({
        where: { id_categorie: categorieId },
        attributes: ['id', 'nom_type'],
        order: [['nom_type', 'ASC']]
      });
    } catch (error) {
      console.error('❌ Erreur obtenirTypesParCategorie:', error);
      throw error;
    }
  }
}

module.exports = new ProduitService();