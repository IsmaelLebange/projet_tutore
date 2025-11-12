const { Op } = require('sequelize');
const Service = require('../models/Service');
const Annonce = require('../models/Annonce');
const Utilisateur = require('../models/utilisateur');
const Adresse = require('../models/Adresse');
const PhotoService = require('../models/PhotoService');// ...existing code...
const PhotoUtilisateur = require('../models/PhotoUtilisateur'); 
const CategorieService = require('../models/CategorieService');
const TypeService = require('../models/TypeService');

class ServiceService {
  
  async obtenirTousServices(options = {}) {
    try {
      const { 
        page = 1, 
        limit = 20, 
        categorie = null, 
        type = null, 
        prixMin = null, 
        prixMax = null,
        recherche = null,
        disponibilite = null
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

      // Construction where clause pour Service/Type
      const whereService = {};
      const whereType = {};
      if (categorie) {
        whereType.id_categorie = parseInt(categorie);
      }
      if (type) {
        whereService.id_type = parseInt(type);
      }
      if (disponibilite !== null) {
        whereService.disponibilite = disponibilite;
      }

      const { count, rows: services } = await Service.findAndCountAll({
        where: whereService,
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
            model: TypeService,
            as: 'type',
            where: Object.keys(whereType).length > 0 ? whereType : undefined,
            include: [
              {
                model: CategorieService,
                as: 'categorie',
                attributes: ['id', 'nom_categorie']
              }
            ]
          },
          {
            model: PhotoService,
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
      const servicesFormates = services.map(s => {
        const sJson = s.toJSON();
        
        // ✅ Log de debug (retire après fix)
        if (!sJson.type || !sJson.type.categorie) {
          console.warn('⚠️ Service sans type/catégorie:', {
            id: sJson.annonce?.id,
            id_type: sJson.id_type,
            type: sJson.type,
          });
        }
        
        return {
          id: sJson.annonce.id,
          titre: sJson.annonce.titre,
          description: sJson.annonce.description,
          prix: sJson.annonce.prix,
          datePublication: sJson.annonce.date_publication,
          statut: sJson.annonce.statut_annonce,
          image: sJson.photos && sJson.photos.length > 0 ? sJson.photos[0].url : null,
          disponibilite: sJson.disponibilite,
          typeService: sJson.type_service,
          categorieService: sJson.type?.categorie?.nom_categorie || 'Non définie',
          typeServiceDetail: sJson.type?.nom_type || 'Non défini',
          vendeur: {
            id: sJson.annonce.vendeur.id,
            nom: `${sJson.annonce.vendeur.prenom} ${sJson.annonce.vendeur.nom}`,
            reputation: sJson.annonce.vendeur.reputation,
            telephone: sJson.annonce.vendeur.numero_de_telephone,
            photo: sJson.annonce.vendeur.photos && sJson.annonce.vendeur.photos.length > 0 
              ? sJson.annonce.vendeur.photos[0].url 
              : null
          },
          adresse: {
            ville: sJson.annonce.adresseAnnonce?.ville,
            quartier: sJson.annonce.adresseAnnonce?.quartier,
            rue: sJson.annonce.adresseAnnonce?.rue
          }
        };
      });

      return {
        services: servicesFormates,
        pagination: {
          page: parsedPage,
          limit: parsedLimit,
          total: count,
          pages: Math.ceil(count / parsedLimit)
        }
      };

    } catch (error) {
      console.error('❌ Erreur obtenirTousServices:', error);
      throw error;
    }
  }

  async obtenirServiceParId(id) {
    try {
      const service = await Service.findOne({
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
            model: TypeService,
            as: 'type',
            include: [
              {
                model: CategorieService,
                as: 'categorie'
              }
            ]
          },
          {
            model: PhotoService,
            as: 'photos',
            attributes: ['url']
          }
        ]
      });

      if (!service) {
        throw new Error('Service introuvable');
      }

      const sJson = service.toJSON();
      return {
        id: sJson.annonce.id,
        titre: sJson.annonce.titre,
        description: sJson.annonce.description,
        prix: sJson.annonce.prix,
        datePublication: sJson.annonce.date_publication,
        statut: sJson.annonce.statut_annonce,
        images: sJson.photos.map(photo => photo.url),
        disponibilite: sJson.disponibilite,
        typeService: sJson.type_service,
        categorieService: sJson.type?.categorie?.nom_categorie || 'Non définie',
        typeServiceDetail: sJson.type?.nom_type || 'Non défini',
        vendeur: {
          id: sJson.annonce.vendeur.id,
          nom: `${sJson.annonce.vendeur.prenom} ${sJson.annonce.vendeur.nom}`,
          email: sJson.annonce.vendeur.email,
          reputation: sJson.annonce.vendeur.reputation,
          telephone: sJson.annonce.vendeur.numero_de_telephone,
          photos: sJson.annonce.vendeur.photos.map(p => p.url)
        },
        adresse: sJson.annonce.adresseAnnonce
      };

    } catch (error) {
      console.error('❌ Erreur obtenirServiceParId:', error);
      throw error;
    }
  }

  async obtenirCategories() {
    try {
      return await CategorieService.findAll({
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
      return await TypeService.findAll({
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

module.exports = new ServiceService();