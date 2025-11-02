const ServiceModel = require('../models/Service');
const Annonce = require('../models/Annonce');

class ServiceService {
  static async creerService(data) {
    return await ServiceModel.create(data);
  }

  static async trouverParAnnonce(idAnnonce) {
    return await ServiceModel.findOne({
      where: { id_annonce: idAnnonce },
      include: [{ model: Annonce, as: 'annonce' }]
    });
  }

  static async modifierService(id, changes) {
    const [rows] = await ServiceModel.update(changes, { where: { id }});
    if (rows === 0) throw new Error('Service non trouvé');
    return await ServiceModel.findByPk(id);
  }
}

module.exports = ServiceService;
