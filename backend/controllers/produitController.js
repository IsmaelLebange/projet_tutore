const Produit = require('../models/Produit');

exports.getTousProduits = async (req, res) => {
  try {
    const produits = await Produit.find().populate('vendeur', 'nom email');
    res.json(produits);
  } catch (erreur) {
    res.status(500).json({ message: 'Erreur serveur', erreur });
  }
};

exports.getProduitParId = async (req, res) => {
  try {
    const produit = await Produit.findById(req.params.id).populate('vendeur', 'nom email');
    if (!produit) return res.status(404).json({ message: 'Produit non trouvé' });
    res.json(produit);
  } catch (erreur) {
    res.status(500).json({ message: 'Erreur serveur', erreur });
  }
};

exports.creerProduit = async (req, res) => {
  try {
    const produit = new Produit(req.body);
    const nouveauProduit = await produit.save();
    res.status(201).json(nouveauProduit);
  } catch (erreur) {
    res.status(400).json({ message: 'Erreur création produit', erreur });
  }
};

exports.modifierProduit = async (req, res) => {
  try {
    const produitModifie = await Produit.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!produitModifie) return res.status(404).json({ message: 'Produit non trouvé' });
    res.json(produitModifie);
  } catch (erreur) {
    res.status(400).json({ message: 'Erreur modification produit', erreur });
  }
};

exports.supprimerProduit = async (req, res) => {
  try {
    const produitSupprime = await Produit.findByIdAndDelete(req.params.id);
    if (!produitSupprime) return res.status(404).json({ message: 'Produit non trouvé' });
    res.json({ message: 'Produit supprimé' });
  } catch (erreur) {
    res.status(500).json({ message: 'Erreur serveur', erreur });
  }
};
