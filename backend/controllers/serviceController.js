const Service = require('../models/Service');

exports.getTousServices = async (req, res) => {
  try {
    const services = await Service.find().populate('prestataire', 'nom email');
    res.json(services);
  } catch (erreur) {
    res.status(500).json({ message: 'Erreur serveur', erreur });
  }
};

exports.getServiceParId = async (req, res) => {
  try {
    const service = await Service.findById(req.params.id).populate('prestataire', 'nom email');
    if (!service) return res.status(404).json({ message: 'Service non trouvé' });
    res.json(service);
  } catch (erreur) {
    res.status(500).json({ message: 'Erreur serveur', erreur });
  }
};

exports.creerService = async (req, res) => {
  try {
    const service = new Service(req.body);
    const nouveauService = await service.save();
    res.status(201).json(nouveauService);
  } catch (erreur) {
    res.status(400).json({ message: 'Erreur création service', erreur });
  }
};

exports.modifierService = async (req, res) => {
  try {
    const serviceModifie = await Service.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!serviceModifie) return res.status(404).json({ message: 'Service non trouvé' });
    res.json(serviceModifie);
  } catch (erreur) {
    res.status(400).json({ message: 'Erreur modification service', erreur });
  }
};

exports.supprimerService = async (req, res) => {
  try {
    const serviceSupprime = await Service.findByIdAndDelete(req.params.id);
    if (!serviceSupprime) return res.status(404).json({ message: 'Service non trouvé' });
    res.json({ message: 'Service supprimé' });
  } catch (erreur) {
    res.status(500).json({ message: 'Erreur serveur', erreur });
  }
};
