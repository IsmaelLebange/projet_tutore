const Annonce = require('../models/Annonce');
const Adresse = require('../models/Adresse');
const Produit = require('../models/Produit');
const ServiceModel = require('../models/Service');

class AnnonceService {
  static async creerAnnonce(data) {
    // data doit contenir: titre, description, prix, id_utilisateur, id_adresse, etc.
    const annonce = await Annonce.create(data);
    return annonce;
  }

  static async trouverParId(id) {
    return await Annonce.findByPk(id, {
      include: [{ model: Adresse, as: 'adresseAnnonce' }],
    });
  }

  static async trouverTout(options = {}) {
    // options: page, limit, filtre, etc. Ici version simple
    const { page = 1, limit = 50 } = options;
    const offset = (page - 1) * limit;

    const annonces = await Annonce.findAll({
      include: [
        { model: Adresse, as: 'adresseAnnonce' },
        { model: Produit, as: 'produit' , required: false},
        { model: ServiceModel, as: 'service', required: false},
      ],
      order: [['date_publication', 'DESC']],
      limit: parseInt(limit),
      offset,
    });

    return annonces;
  }
}

module.exports = AnnonceService;
