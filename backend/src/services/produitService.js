const Produit = require('../models/Produit');
const Annonce = require('../models/Annonce');

class ProduitService {
  static async creerProduit(data) {
    // data: id_annonce, id_type, etat, etc.
    return await Produit.create(data);
  }

  static async trouverParAnnonce(idAnnonce) {
    return await Produit.findOne({
      where: { id_annonce: idAnnonce },
      include: [{ model: Annonce, as: 'annonce' }]
    });
  }

  static async modifierProduit(id, changes) {
    const [rows] = await Produit.update(changes, { where: { id }});
    if (rows === 0) throw new Error('Produit non trouvé');
    return await Produit.findByPk(id);
  }
}

module.exports = ProduitService;
