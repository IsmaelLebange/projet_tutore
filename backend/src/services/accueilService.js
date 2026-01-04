// src/services/accueilService.js
const { Op } = require('sequelize');
const { sequelize } = require('../config/database');
// Utiliser ILIKE sur Postgres, LIKE sur SQLite/Autres
const ILIKE = (sequelize && sequelize.getDialect && sequelize.getDialect() === 'postgres') ? Op.iLike : Op.like;
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

class AccueilService {
  
  async obtenirDonneesAccueil(options = {}) {
    try {
      console.log('🏠 === DONNÉES ACCUEIL ===');
      
      const {
        limiteTendance = 6,
        limiteRecentes = 10
      } = options;

      const [
        categories,
        annoncesTendance,
        annoncesRecentes,
        statistiques
      ] = await Promise.all([
        this.obtenirCategories(),
        this.obtenirAnnoncesTendance({ limit: limiteTendance }),
        this.obtenirAnnoncesRecentes({ limit: limiteRecentes }),
        this.obtenirStatistiques()
      ]);

      console.log(`✅ Données récupérées - Categories: ${categories.length}, Tendance: ${annoncesTendance.length}, Récentes: ${annoncesRecentes.length}`);

      return {
        categories,
        tendance: annoncesTendance,
        recentes: annoncesRecentes,
        statistiques
      };
    } catch (error) {
      console.error('❌ Erreur obtenirDonneesAccueil:', error);
      throw error;
    }
  }

  async obtenirCategories() {
    try {
      console.log('📂 Récupération des catégories...');
      
      let categoriesProduits = [];
      let categoriesServices = [];

      try {
        const cats = await CategorieProduit.findAll({ 
          attributes: ['id', 'nom_categorie'],
          limit: 10 
        });
        categoriesProduits = cats.map(c => ({ 
          id: c.id, 
          nom_categorie: c.nom_categorie,
          type: 'Produit'
        }));
        console.log(`✅ ${categoriesProduits.length} catégories produits trouvées`);
      } catch (e) {
        console.warn('⚠️ Erreur récupération catégories produits:', e.message);
      }

      try {
        const cats = await CategorieService.findAll({ 
          attributes: ['id', 'nom_categorie'],
          limit: 10 
        });
        categoriesServices = cats.map(c => ({ 
          id: c.id, 
          nom_categorie: c.nom_categorie,
          type: 'Service'
        }));
        console.log(`✅ ${categoriesServices.length} catégories services trouvées`);
      } catch (e) {
        console.warn('⚠️ Erreur récupération catégories services:', e.message);
      }

      const categories = [...categoriesProduits, ...categoriesServices];

      if (categories.length === 0) {
        console.log('⚠️ Aucune catégorie trouvée, utilisation des valeurs par défaut');
        return [
          { id: 1, nom_categorie: 'Électronique', type: 'Produit' },
          { id: 2, nom_categorie: 'Mode', type: 'Produit' },
          { id: 3, nom_categorie: 'Maison', type: 'Produit' },
          { id: 4, nom_categorie: 'Informatique', type: 'Service' },
          { id: 5, nom_categorie: 'Automobile', type: 'Service' }
        ];
      }

      return categories;
    } catch (error) {
      console.error('❌ Erreur obtenirCategories:', error);
      throw error;
    }
  }

  async obtenirAnnoncesTendance(options = {}) {
    try {
      const { limit = 6 } = options;
      console.log(`🔥 Recherche ${limit} annonces tendance...`);

      const annonces = await Annonce.findAll({
        where: {
          statut_annonce: { [ILIKE]: 'active' },
        },
        include: [
          {
            model: Utilisateur,
            as: 'vendeur',
            attributes: ['id', 'nom', 'prenom'],
            include: [{
              model: Adresse,
              as: 'adresseFixe',
              attributes: ['ville'],
            }]
          },
          {
            model: Produit,
            as: 'produit',
            required: false,
            include: [
              { model: PhotoProduit, as: 'photos', limit: 1 },
              { model: TypeProduit, as: 'type', required: false, include: [{ model: CategorieProduit, as: 'categorie' }] }
            ]
          },
          {
            model: Service,
            as: 'service',
            required: false,
            include: [
              { model: PhotoService, as: 'photos', limit: 1 },
              { model: TypeService, as: 'type', required: false, include: [{ model: CategorieService, as: 'categorie' }] }
            ]
          }
        ],
        order: [
          ['date_publication', 'DESC'],
          // ['nombre_vues', 'DESC'] // supprimé si champ absent
        ],
        limit
      });

      const annoncesFormatees = annonces.map(a => this._formaterAnnonceAccueil(a));
      console.log(`✅ ${annoncesFormatees.length} annonces tendance formatées`);
      
      return annoncesFormatees;
    } catch (error) {
      console.error('❌ Erreur obtenirAnnoncesTendance:', error);
      return [];
    }
  }

  async obtenirAnnoncesRecentes(options = {}) {
    try {
      const { limit = 10 } = options;
      console.log(`📅 Recherche ${limit} annonces récentes...`);

      const annonces = await Annonce.findAll({
        where: {
          statut_annonce: { [ILIKE]: 'active' }
        },
        include: [
          {
            model: Utilisateur,
            as: 'vendeur',
            attributes: ['id', 'nom', 'prenom'],
            include: [{
              model: Adresse,
              as: 'adresseFixe',
              attributes: ['ville'],
            }]
          },
          {
            model: Produit,
            as: 'produit',
            required: false,
            include: [
              { model: PhotoProduit, as: 'photos', limit: 1 },
              { model: TypeProduit, as: 'type', required: false, include: [{ model: CategorieProduit, as: 'categorie' }] }
            ]
          },
          {
            model: Service,
            as: 'service',
            required: false,
            include: [
              { model: PhotoService, as: 'photos', limit: 1 },
              { model: TypeService, as: 'type', required: false, include: [{ model: CategorieService, as: 'categorie' }] }
            ]
          }
        ],
        order: [['date_publication', 'DESC']],
        limit
      });

      const annoncesFormatees = annonces.map(a => this._formaterAnnonceAccueil(a));
      console.log(`✅ ${annoncesFormatees.length} annonces récentes formatées`);
      
      return annoncesFormatees;
    } catch (error) {
      console.error('❌ Erreur obtenirAnnoncesRecentes:', error);
      return [];
    }
  }

  async obtenirStatistiques() {
    try {
      console.log('📊 Calcul des statistiques...');

      const [totalAnnonces, totalUtilisateurs, produitsActifs] = await Promise.all([
        Annonce.count({ where: { statut_annonce: { [ILIKE]: 'active' } } }),
        Utilisateur.count(),
        Annonce.count({ where: { statut_annonce: { [ILIKE]: 'active' } } })
      ]);

      const stats = {
        totalAnnonces,
        totalUtilisateurs,
        produitsActifs
      };

      console.log('✅ Statistiques calculées:', stats);
      return stats;
    } catch (error) {
      console.error('❌ Erreur obtenirStatistiques:', error);
      return {
        totalAnnonces: 0,
        totalUtilisateurs: 0,
        produitsActifs: 0
      };
    }
  }

  async rechercherAnnonces(query, options = {}) {
    try {
      const {
        limit = 20,
        offset = 0,
        type = null,
        categorie = null,
        prixMin = null,
        prixMax = null
      } = options;

      console.log(`🔍 Recherche: "${query}" avec options:`, options);

      let where = {
        statut_annonce: { [Op.iLike]: 'active' }
      };

      // Filtre par type si spécifié
      if (type) {
        where.type_annonce = type;
      }

      // Conditions de recherche dans le texte
      if (query && query.trim()) {
        where[Op.or] = [
          { titre: { [ILIKE]: `%${query}%` } },
          { description: { [ILIKE]: `%${query}%` } }
        ];
      }

      // Conditions de prix
      if (prixMin !== null || prixMax !== null) {
        where.prix = {};
        if (prixMin !== null) where.prix[Op.gte] = prixMin;
        if (prixMax !== null) where.prix[Op.lte] = prixMax;
      }

      const annonces = await Annonce.findAndCountAll({
        where,
        include: [
          {
            model: Utilisateur,
            as: 'vendeur',
            attributes: ['id', 'nom', 'prenom'],
            include: [{
              model: Adresse,
              as: 'adresseFixe',
              attributes: ['ville'],
            }]
          },
          {
            model: Produit,
            as: 'produit',
            required: false,
            include: [
              { model: PhotoProduit, as: 'photos', limit: 1 },
              { model: TypeProduit, as: 'type', required: false, include: [{ model: CategorieProduit, as: 'categorie' }], where: categorie ? { id_categorie: categorie } : undefined }
            ]
          },
          {
            model: Service,
            as: 'service',
            required: false,
            include: [
              { model: PhotoService, as: 'photos', limit: 1 },
              { model: TypeService, as: 'type', required: false, include: [{ model: CategorieService, as: 'categorie' }], where: categorie ? { id_categorie: categorie } : undefined }
            ]
          }
        ],
        order: [['date_publication', 'DESC']],
        limit,
        offset
      });

      const resultats = {
        annonces: annonces.rows.map(a => this._formaterAnnonceAccueil(a)),
        total: annonces.count,
        page: Math.floor(offset / limit) + 1,
        totalPages: Math.ceil(annonces.count / limit)
      };

      console.log(`✅ Recherche terminée: ${resultats.annonces.length}/${resultats.total} résultats`);
      return resultats;
    } catch (error) {
      console.error('❌ Erreur rechercherAnnonces:', error);
      return { annonces: [], total: 0, page: 1, totalPages: 0 };
    }
  }

  _formaterAnnonceAccueil(annonce) {
    if (!annonce) return null;

    const estProduit = annonce.produit !== null;
    const item = estProduit ? annonce.produit : annonce.service;
    
    return {
      id: annonce.id,
      titre: annonce.titre,
      description: annonce.description,
      prix: annonce.prix,
      type: estProduit ? 'Produit' : 'Service',
      statut: annonce.statut_annonce,
      date_publication: annonce.date_publication,
      
      image: item?.photos?.[0]?.url || null,
      categorie: item?.type?.categorie?.nom_categorie || 'Sans catégorie',
      auteur: {
        id: annonce.vendeur?.id,
        nom: `${annonce.vendeur?.prenom || ''} ${annonce.vendeur?.nom || ''}`.trim(),
        ville: annonce.vendeur?.adresseFixe?.ville || 'Non spécifié'
      }
    };
  }
}

module.exports = new AccueilService();
