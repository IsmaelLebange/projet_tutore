const panierService = require('../services/panierService');

const getUserId = (req) => req.idUtilisateur;

async function obtenirPanier(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Utilisateur non authentifié' });

    const panier = await panierService.obtenirPanier(userId);
    return res.json(panier);
  } catch (error) {
    console.error('❌ Erreur controller obtenirPanier:', error);
    return res.status(500).json({
      message: 'Erreur lors de la récupération du panier',
      error: error.message,
    });
  }
}

async function ajouterAuPanier(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Utilisateur non authentifié' });

    const { type, itemId, quantite } = req.body;
    if (!type || !itemId) {
      return res.status(400).json({ message: 'Type et itemId requis' });
    }

    const resultat = await panierService.ajouterAuPanier(userId, { type, itemId, quantite });
    return res.json(resultat);
  } catch (error) {
    console.error('❌ Erreur controller ajouterAuPanier:', error);
    return res.status(500).json({ message: error.message });
  }
}

async function modifierQuantite(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Utilisateur non authentifié' });

    const { ligneId } = req.params;
    const { quantite } = req.body;
    if (!quantite || quantite < 1) {
      return res.status(400).json({ message: 'Quantité invalide' });
    }

    const resultat = await panierService.modifierQuantite(userId, parseInt(ligneId, 10), quantite);
    return res.json(resultat);
  } catch (error) {
    console.error('❌ Erreur controller modifierQuantite:', error);
    return res.status(500).json({ message: error.message });
  }
}

async function supprimerLigne(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Utilisateur non authentifié' });

    const { ligneId } = req.params;
    const resultat = await panierService.supprimerLigne(userId, parseInt(ligneId, 10));
    return res.json(resultat);
  } catch (error) {
    console.error('❌ Erreur controller supprimerLigne:', error);
    return res.status(500).json({ message: error.message });
  }
}

async function viderPanier(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Utilisateur non authentifié' });

    const resultat = await panierService.viderPanier(userId);
    return res.json(resultat);
  } catch (error) {
    console.error('❌ Erreur controller viderPanier:', error);
    return res.status(500).json({ message: error.message });
  }
}

async function validerPanier(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Utilisateur non authentifié' });

    const { comptePaiementId } = req.body; // ✅ FIX: nom unifié
    if (!comptePaiementId) {
      return res.status(400).json({ message: 'Compte paiement requis' });
    }

    console.log('🔑 User:', userId, 'CompteId:', comptePaiementId); // Debug

    const resultat = await panierService.validerPanier(userId, comptePaiementId);
    return res.json(resultat);
  } catch (error) {
    console.error('❌ Erreur controller validerPanier:', error);
    console.log('erreur', error);
    return res.status(500).json({ message: error.message });
  }
}

module.exports = {
  obtenirPanier,
  ajouterAuPanier,
  modifierQuantite,
  supprimerLigne,
  viderPanier,
  validerPanier,
};