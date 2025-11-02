const utilisateurService = require('../services/utilisateurService');

module.exports = async (req, res, next) => {
  try {
    const idUtilisateur = req.idUtilisateur; // injecté par ton authMiddleware
    if (!idUtilisateur) {
      return res.status(401).json({ message: 'Utilisateur non authentifié (token manquant).' });
    }

    const utilisateur = await utilisateurService.trouverUtilisateurParId(idUtilisateur);

    if (!utilisateur) {
      return res.status(404).json({ message: 'Utilisateur introuvable.' });
    }

    req.utilisateur = utilisateur; // ✅ injection ici pour verifieEtat
    next();
  } catch (err) {
    console.error('Erreur middleware chargerUtilisateur:', err);
    res.status(500).json({ message: 'Erreur interne chargement utilisateur.' });
  }
};
