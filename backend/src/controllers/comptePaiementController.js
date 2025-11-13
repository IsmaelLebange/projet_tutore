const comptePaiementService = require('../services/comptePaiementService');

const getUserId = (req) => req.idUtilisateur;

async function obtenirComptes(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Non authentifié' });

    const comptes = await comptePaiementService.obtenirComptesUtilisateur(userId);
    return res.json(comptes);
  } catch (error) {
    console.error('❌ Erreur obtenirComptes:', error);
    return res.status(500).json({ message: error.message });
  }
}

async function ajouterCompte(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Non authentifié' });

    const { numero_compte, entreprise, est_principal } = req.body;
    if (!numero_compte || !entreprise) {
      return res.status(400).json({ message: 'Numéro et entreprise requis' });
    }

    const compte = await comptePaiementService.ajouterCompte(userId, {
      numero_compte,
      entreprise,
      est_principal
    });

    return res.json({ message: 'Compte ajouté', compte });
  } catch (error) {
    console.error('❌ Erreur ajouterCompte:', error);
    return res.status(500).json({ message: error.message });
  }
}

async function modifierCompte(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Non authentifié' });

    const { compteId } = req.params;
    const compte = await comptePaiementService.modifierCompte(userId, parseInt(compteId), req.body);

    return res.json({ message: 'Compte modifié', compte });
  } catch (error) {
    console.error('❌ Erreur modifierCompte:', error);
    return res.status(500).json({ message: error.message });
  }
}

async function supprimerCompte(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Non authentifié' });

    const { compteId } = req.params;
    const result = await comptePaiementService.supprimerCompte(userId, parseInt(compteId));

    return res.json(result);
  } catch (error) {
    console.error('❌ Erreur supprimerCompte:', error);
    return res.status(500).json({ message: error.message });
  }
}

async function definirPrincipal(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Non authentifié' });

    const { compteId } = req.params;
    const compte = await comptePaiementService.definirPrincipal(userId, parseInt(compteId));

    return res.json({ message: 'Compte principal défini', compte });
  } catch (error) {
    console.error('❌ Erreur definirPrincipal:', error);
    return res.status(500).json({ message: error.message });
  }
}

module.exports = {
  obtenirComptes,
  ajouterCompte,
  modifierCompte,
  supprimerCompte,
  definirPrincipal
};