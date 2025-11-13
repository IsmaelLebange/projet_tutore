const { Op } = require('sequelize');
const LigneCommande = require('../models/LigneCommande');
const Transaction = require('../models/Transaction');
const Produit = require('../models/Produit');
const Service = require('../models/Service');
const Annonce = require('../models/Annonce');
const Utilisateur = require('../models/utilisateur');
const PhotoProduit = require('../models/PhotoProduit');
const PhotoService = require('../models/PhotoService');
const notificationService = require('./notificationService'); // ✅ AJOUT

class PanierService {
  /**
   * Récupérer le panier d'un utilisateur (transaction en attente + lignes "En_panier")
   */
  async obtenirPanier(userId) {
    try {
      let transaction = await Transaction.findOne({
        where: {
          id_acheteur: userId,
          statut_transaction: 'En_attente'
        }
      });

      if (!transaction) {
        return { transaction: null, lignes: [], total: 0 };
      }

      const lignes = await LigneCommande.findAll({
        where: {
          id_transaction: transaction.id,
          etat: 'En_panier'
        },
        include: [
          {
            model: Produit,
            as: 'produit',
            required: false,
            include: [
              {
                model: Annonce,
                as: 'annonce',
                attributes: ['id', 'titre', 'description', 'prix', 'id_utilisateur'], // ✅ FIX: id_utilisateur
                include: [
                  {
                    model: Utilisateur,
                    as: 'vendeur',
                    attributes: ['id', 'prenom', 'nom']
                  }
                ]
              },
              {
                model: PhotoProduit,
                as: 'photos',
                attributes: ['url'],
                limit: 1
              }
            ]
          },
          {
            model: Service,
            as: 'service',
            required: false,
            include: [
              {
                model: Annonce,
                as: 'annonce',
                attributes: ['id', 'titre', 'description', 'prix', 'id_utilisateur'], // ✅ FIX: id_utilisateur
                include: [
                  {
                    model: Utilisateur,
                    as: 'vendeur',
                    attributes: ['id', 'prenom', 'nom']
                  }
                ]
              },
              {
                model: PhotoService,
                as: 'photos',
                attributes: ['url'],
                limit: 1
              }
            ]
          }
        ]
      });

      const lignesFormatees = lignes.map(l => {
        const lJson = l.toJSON();
        const isProduit = !!lJson.produit;
        const item = isProduit ? lJson.produit : lJson.service;
        const annonce = item.annonce;
        const photo = item.photos && item.photos.length > 0 ? item.photos[0].url : null;

        return {
          id: lJson.id,
          quantite: lJson.quantite,
          type: isProduit ? 'Produit' : 'Service',
          itemId: isProduit ? lJson.id_produit : lJson.id_service,
          annonceId: annonce.id,
          titre: annonce.titre,
          description: annonce.description,
          prixUnitaire: annonce.prix,
          sousTotal: annonce.prix * lJson.quantite,
          image: photo,
          vendeur: {
            id: annonce.vendeur.id,
            nom: `${annonce.vendeur.prenom} ${annonce.vendeur.nom}`
          }
        };
      });

      const total = lignesFormatees.reduce((sum, l) => sum + l.sousTotal, 0);

      return {
        transaction: {
          id: transaction.id,
          dateCreation: transaction.date_transaction
        },
        lignes: lignesFormatees,
        total
      };

    } catch (error) {
      console.error('❌ Erreur obtenirPanier:', error);
      throw error;
    }
  }

  /**
   * Ajouter un produit/service au panier
   */
  async ajouterAuPanier(userId, { type, itemId, quantite = 1 }) {
    try {
      if (!['Produit', 'Service'].includes(type)) {
        throw new Error('Type invalide (doit être "Produit" ou "Service")');
      }

      const Model = type === 'Produit' ? Produit : Service;
      const item = await Model.findByPk(itemId, {
        include: [
          {
            model: Annonce,
            as: 'annonce',
            attributes: ['id', 'prix', 'id_utilisateur', 'statut_annonce'] // ✅ FIX: id_utilisateur
          }
        ]
      });

      if (!item) {
        throw new Error(`${type} introuvable`);
      }

      if (item.annonce.statut_annonce !== 'Active') {
        throw new Error('Cette annonce n\'est plus disponible');
      }

      if (item.annonce.id_utilisateur === userId) { // ✅ FIX: id_utilisateur
        throw new Error('Vous ne pouvez pas acheter votre propre annonce');
      }

      let transaction = await Transaction.findOne({
        where: {
          id_acheteur: userId,
          statut_transaction: 'En_attente'
        }
      });

      if (!transaction) {
        transaction = await Transaction.create({
          id_acheteur: userId,
          id_vendeur: item.annonce.id_utilisateur, // ✅ FIX: id_utilisateur
          id_compte_paiement_vendeur: 1,
          montant: 0,
          statut_transaction: 'En_attente',
          commission: 0
        });
      }

      const ligneExistante = await LigneCommande.findOne({
        where: {
          id_transaction: transaction.id,
          etat: 'En_panier',
          ...(type === 'Produit' ? { id_produit: itemId } : { id_service: itemId })
        }
      });

      if (ligneExistante) {
        ligneExistante.quantite += quantite;
        await ligneExistante.save();
        return { message: 'Quantité mise à jour', ligne: ligneExistante };
      } else {
        const nouvelleLigne = await LigneCommande.create({
          id_transaction: transaction.id,
          quantite,
          etat: 'En_panier',
          id_produit: type === 'Produit' ? itemId : null,
          id_service: type === 'Service' ? itemId : null
        });
        return { message: 'Article ajouté au panier', ligne: nouvelleLigne };
      }

    } catch (error) {
      console.error('❌ Erreur ajouterAuPanier:', error);
      throw error;
    }
  }

  /**
   * Modifier la quantité d'une ligne
   */
  async modifierQuantite(userId, ligneId, nouvelleQuantite) {
    try {
      if (nouvelleQuantite < 1) {
        throw new Error('La quantité doit être au moins 1');
      }

      const ligne = await LigneCommande.findOne({
        where: { id: ligneId, etat: 'En_panier' },
        include: [
          {
            model: Transaction,
            as: 'transaction',
            where: { id_acheteur: userId, statut_transaction: 'En_attente' }
          }
        ]
      });

      if (!ligne) {
        throw new Error('Ligne de panier introuvable');
      }

      ligne.quantite = nouvelleQuantite;
      await ligne.save();

      return { message: 'Quantité mise à jour', ligne };

    } catch (error) {
      console.error('❌ Erreur modifierQuantite:', error);
      throw error;
    }
  }

  /**
   * Supprimer une ligne du panier
   */
  async supprimerLigne(userId, ligneId) {
    try {
      const ligne = await LigneCommande.findOne({
        where: { id: ligneId, etat: 'En_panier' },
        include: [
          {
            model: Transaction,
            as: 'transaction',
            where: { id_acheteur: userId, statut_transaction: 'En_attente' }
          }
        ]
      });

      if (!ligne) {
        throw new Error('Ligne de panier introuvable');
      }

      await ligne.destroy();

      const restant = await LigneCommande.count({
        where: { id_transaction: ligne.id_transaction, etat: 'En_panier' }
      });

      if (restant === 0) {
        await Transaction.destroy({ where: { id: ligne.id_transaction } });
      }

      return { message: 'Article retiré du panier' };

    } catch (error) {
      console.error('❌ Erreur supprimerLigne:', error);
      throw error;
    }
  }

  /**
   * Vider le panier
   */
  async viderPanier(userId) {
    try {
      const transaction = await Transaction.findOne({
        where: { id_acheteur: userId, statut_transaction: 'En_attente' }
      });

      if (!transaction) {
        return { message: 'Panier déjà vide' };
      }

      await LigneCommande.destroy({
        where: { id_transaction: transaction.id, etat: 'En_panier' }
      });

      await transaction.destroy();

      return { message: 'Panier vidé' };

    } catch (error) {
      console.error('❌ Erreur viderPanier:', error);
      throw error;
    }
  }

  /**
   * Valider le panier → Commande "En_attente_confirmation" + Notifications
   */
  async validerPanier(userId, comptePaiementId) {
    try {
      const transaction = await Transaction.findOne({
        where: { id_acheteur: userId, statut_transaction: 'En_attente' },
        include: [
          {
            model: LigneCommande,
            as: 'lignesCommande',
            where: { etat: 'En_panier' }
          }
        ]
      });

      if (!transaction || transaction.lignesCommande.length === 0) {
        throw new Error('Panier vide ou introuvable');
      }

      // Calculer montant + commission
      const lignes = await LigneCommande.findAll({
        where: { id_transaction: transaction.id, etat: 'En_panier' },
        include: [
          {
            model: Produit,
            as: 'produit',
            required: false,
            include: [{ model: Annonce, as: 'annonce', attributes: ['prix', 'statut_annonce'] }]
          },
          {
            model: Service,
            as: 'service',
            required: false,
            include: [{ model: Annonce, as: 'annonce', attributes: ['prix', 'statut_annonce'] }]
          }
        ]
      });

      const montantTotal = lignes.reduce((sum, l) => {
        const annonce = l.produit?.annonce || l.service?.annonce;
        if (annonce.statut_annonce !== 'Active') {
          throw new Error(`Article ${annonce.titre} n'est plus disponible`);
        }
        return sum + (annonce.prix * l.quantite);
      }, 0);

      const commission = montantTotal * 0.05; // 5% commission

      // Mettre à jour transaction
      transaction.montant = montantTotal;
      transaction.commission = commission;
      transaction.statut_transaction = 'En_attente_confirmation'; // ✅ NOUVEAU STATUT
      transaction.id_compte_paiement_vendeur = comptePaiementId;
      transaction.confirmation_acheteur = false; // ✅ AJOUT pour suivi
      transaction.confirmation_vendeur = false; // ✅ AJOUT pour suivi
      await transaction.save();

      // Mettre à jour lignes
      await LigneCommande.update(
        { etat: 'En_attente_confirmation' },
        { where: { id_transaction: transaction.id, etat: 'En_panier' } }
      );

      // ✅ Changer statut annonces → "En_attente"
      for (const ligne of lignes) {
        const annonceId = ligne.produit?.annonce.id || ligne.service?.annonce.id;
        await Annonce.update(
          { statut_annonce: 'En_attente' },
          { where: { id: annonceId } }
        );
      }

      // ✅ Envoyer notifications
      const { codeTransaction } = await notificationService.notifierNouvelleCommande(transaction.id);

      return {
        message: 'Commande validée et envoyée au vendeur',
        codeTransaction,
        transaction: {
          id: transaction.id,
          montant: montantTotal,
          commission,
          statut: 'En_attente_confirmation'
        }
      };

    } catch (error) {
      console.error('❌ Erreur validerPanier:', error);
      throw error;
    }
  }
}

module.exports = new PanierService();