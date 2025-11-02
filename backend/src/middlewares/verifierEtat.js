const utilisateurService = require('../services/utilisateurService');

module.exports = (req, res, next) => {
  try {
    const utilisateur = req.utilisateur; // injecté par verifieToken

    if (!utilisateur) {
      return res.status(401).json({ message: 'Utilisateur non authentifié.' });
    }

    // Normalise la valeur au cas où (ex: 'actif' vs 'Actif')
    const etat = (utilisateur.etat || '').toString().trim();

    if (etat !== 'Actif') {
      return res.status(403).json({ message: 'Compte bloqué. Contactez l\'administration.' });
    }

    // Tout est ok
    next();
  } catch (err) {
    console.error('Erreur verifieEtat middleware:', err);
    res.status(500).json({ message: 'Erreur interne middleware vérification état.' });
  }
};
