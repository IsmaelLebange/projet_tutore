const ComptePaiement = require('../models/ComptePaiement');

class ComptePaiementService {
  async obtenirComptesUtilisateur(userId) {
    return await ComptePaiement.findAll({
      where: { id_utilisateur: userId },
      order: [['est_principal', 'DESC'], ['createdAt', 'DESC']]
    });
  }

  async ajouterCompte(userId, { numero_compte, entreprise, est_principal = false }) {
    
    if (est_principal) {
      await ComptePaiement.update(
        { est_principal: false },
        { where: { id_utilisateur: userId } }
      );
    }
    return await ComptePaiement.create({
      id_utilisateur: userId,
      numero_compte,
      entreprise,
      est_principal
    });
  }

  async modifierCompte(userId, compteId, updates) {
    const compte = await ComptePaiement.findOne({
      where: { id: compteId, id_utilisateur: userId }
    });

    if (!compte) throw new Error('Compte introuvable');

    if (updates.est_principal) {
      await ComptePaiement.update(
        { est_principal: false },
        { where: { id_utilisateur: userId } }
      );
    }

    return await compte.update(updates);
  }

  async supprimerCompte(userId, compteId) {
    const compte = await ComptePaiement.findOne({
      where: { id: compteId, id_utilisateur: userId }
    });

    if (!compte) throw new Error('Compte introuvable');

    await compte.destroy();
    return { message: 'Compte supprimé' };
  }

  async definirPrincipal(userId, compteId) {
    const compte = await ComptePaiement.findOne({
      where: { id: compteId, id_utilisateur: userId }
    });

    if (!compte) throw new Error('Compte introuvable');

    await ComptePaiement.update(
      { est_principal: false },
      { where: { id_utilisateur: userId } }
    );

    compte.est_principal = true;
    await compte.save();

    return compte;
  }
}

module.exports = new ComptePaiementService();