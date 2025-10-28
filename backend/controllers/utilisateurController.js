const Utilisateur = require('../models/Utilisateur');

exports.getTousUtilisateurs = async (req, res) => {
  try {
    const utilisateurs = await Utilisateur.find();
    res.json(utilisateurs);
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur', err });
  }
};

exports.getUtilisateurParId = async (req, res) => {
  try {
    const utilisateur = await Utilisateur.findById(req.params.id);
    if (!utilisateur) return res.status(404).json({ message: 'Utilisateur non trouvé' });
    res.json(utilisateur);
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur', err });
  }
};

exports.creerUtilisateur = async (req, res) => {
  const nouvelUtilisateur = new Utilisateur(req.body);
  try {
    const sauvegarde = await nouvelUtilisateur.save();
    res.status(201).json(sauvegarde);
  } catch (err) {
    res.status(400).json({ message: 'Données invalides', err });
  }
};

exports.modifierUtilisateur = async (req, res) => {
  try {
    const utilisateurMAJ = await Utilisateur.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!utilisateurMAJ) return res.status(404).json({ message: 'Utilisateur non trouvé' });
    res.json(utilisateurMAJ);
  } catch (err) {
    res.status(400).json({ message: 'Erreur de mise à jour', err });
  }
};

exports.supprimerUtilisateur = async (req, res) => {
  try {
    const utilisateurSuppr = await Utilisateur.findByIdAndDelete(req.params.id);
    if (!utilisateurSuppr) return res.status(404).json({ message: 'Utilisateur non trouvé' });
    res.json({ message: 'Utilisateur supprimé' });
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur', err });
  }
};
