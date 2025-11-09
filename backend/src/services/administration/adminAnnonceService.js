const Annonce = require('../../models/Annonce');
const Utilisateur = require('../../models/utilisateur');
const Adresse = require('../../models/Adresse');
const Produit = require('../../models/Produit');
const Service = require('../../models/Service');
const PhotoProduit = require('../../models/PhotoProduit');
const PhotoService = require('../../models/PhotoService');
const CategorieProduit = require('../../models/CategorieProduit');
const CategorieService = require('../../models/CategorieService');
const TypeProduit = require('../../models/TypeProduit');
const TypeService = require('../../models/TypeService');

class AdminAnnonceService {
  static async trouverToutEnrichi() {
    try {
      const annonces = await Annonce.findAll({
        include: [
          { model: Utilisateur, as: 'vendeur', attributes: ['id','prenom','nom','email','reputation','role'] },
          { model: Adresse, as: 'adresseAnnonce', attributes: ['ville','quartier','rue'] }
        ],
        order: [['date_publication','DESC']]
      });

      return Promise.all(
        annonces.map(async (annonce) => {
          const a = annonce.toJSON();

          // Produit ?
          const produit = await Produit.findOne({
            where: { id_annonce: annonce.id },
            include: [{ model: TypeProduit, as: 'type', include: [{ model: CategorieProduit, as: 'categorie' }] }]
          });
          if (produit) {
            const photo = await PhotoProduit.findOne({ where: { id_produit: produit.id }, attributes: ['url'] });
            return {
              ...a,
              type: 'produit',
              categorie: produit.type?.categorie?.nom_categorie || null,
              typeSpecifique: produit.type?.nom_type || null,
              etat: produit.etat || null,
              image: photo ? photo.url : null,
              statut: a.statut_annonce || 'Active',
            };
          }

          // Service ?
          const service = await Service.findOne({
            where: { id_annonce: annonce.id },
            include: [{ model: TypeService, as: 'type', include: [{ model: CategorieService, as: 'categorie' }] }]
          });
          if (service) {
            const photo = await PhotoService.findOne({ where: { id_service: service.id }, attributes: ['url'] });
            return {
              ...a,
              type: 'service',
              categorie: service.type?.categorie?.nom_categorie || null,
              typeSpecifique: service.type?.nom_type || null,
              disponibilite: service.disponibilite || null,
              image: photo ? photo.url : null,
              statut: a.statut_annonce || 'Active',
            };
          }

          return {
            ...a,
            type: 'inconnu',
            image: null,
            statut: a.statut_annonce || 'Active',
          };
        })
      );
    } catch (e) {
      console.error('❌ Erreur trouverToutEnrichi:', e);
      throw e;
    }
  }

  static async mettreAJourStatut(id, nouveauStatut) {
    const annonce = await Annonce.findByPk(id);
    if (!annonce) throw new Error('Annonce introuvable');

    // Le modèle a "statut_annonce"
    annonce.statut_annonce = nouveauStatut;
    await annonce.save();
    return annonce;
  }
  
  static async supprimerForce(id) {
    const annonce = await Annonce.findByPk(id);
    if (!annonce) return false;
    await annonce.destroy();
    return true;
  }
}

module.exports = AdminAnnonceService;