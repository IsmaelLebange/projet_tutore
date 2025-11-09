const AdminAnnonceService = require('../../services/administration/adminAnnonceService');

exports.obtenirAnnoncesAdmin = async (req, res) => {
  try {
    console.log('🔎 Admin annonces (middleware ok) id=', req.idUtilisateur);
    const annonces = await AdminAnnonceService.trouverToutEnrichi();
    return res.status(200).json({ success: true, count: annonces.length, annonces });
  } catch (e) {
    console.error('❌ Erreur obtenirAnnoncesAdmin:', e);
    return res.status(500).json({ success: false, message: e.message });
  }
};

exports.changerStatutAnnonce = async (req, res) => {
  try {
    const { statut } = req.body;
    if (!statut) return res.status(400).json({ success: false, message: 'Statut requis.' });
    const annonce = await AdminAnnonceService.mettreAJourStatut(req.params.id, statut);
    return res.status(200).json({ success: true, message: 'Statut mis à jour', annonce });
  } catch (e) {
    console.error('❌ Erreur changerStatutAnnonce:', e);
    return res.status(500).json({ success: false, message: e.message });
  }
};

exports.supprimerAnnonceAdmin = async (req, res) => {
  try {
    // suppression directe (sans vérifier propriétaire)
    const ok = await AdminAnnonceService.supprimerForce(req.params.id);
    if (!ok) return res.status(404).json({ success: false, message: 'Annonce introuvable' });
    return res.status(200).json({ success: true, message: 'Annonce supprimée (admin)' });
  } catch (e) {
    console.error('❌ Erreur supprimerAnnonceAdmin:', e);
    return res.status(500).json({ success: false, message: e.message });
  }
};