const { Op } = require('sequelize');
const LigneCommande = require('../models/LigneCommande');
const Transaction = require('../models/Transaction');
const Produit = require('../models/Produit');
const Service = require('../models/Service');
const Annonce = require('../models/Annonce');
const Utilisateur = require('../models/utilisateur');
const PhotoProduit = require('../models/PhotoProduit');
const PhotoService = require('../models/PhotoService');

class PanierService {

    
  /**
   * Récupérer le panier d'un utilisateur (transaction en attente + lignes "En_panier")
   */
  async obtenirPanier(userId) {
    try {
      // Trouver ou créer une transaction "En_attente" pour cet utilisateur (panier actif)
      let transaction = await Transaction.findOne({
        where: {
          id_acheteur: userId,
          statut_transaction: 'En_attente'
        }
      });

      if (!transaction) {
        // Pas de panier actif
        return { transaction: null, lignes: [], total: 0 };
      }

      // Récupérer les lignes de commande du panier
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
                attributes: ['id', 'titre', 'description', 'prix'],
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
                attributes: ['id', 'titre', 'description', 'prix'],
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

      // Formater les lignes
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
      // Valider le type
      if (!['Produit', 'Service'].includes(type)) {
        throw new Error('Type invalide (doit être "Produit" ou "Service")');
      }

      // Récupérer l'annonce (pour le prix et vérifier l'existence)
      const Model = type === 'Produit' ? Produit : Service;
      const item = await Model.findByPk(itemId, {
        include: [
          {
            model: Annonce,
            as: 'annonce',
            attributes: ['id', 'prix', 'id_vendeur', 'statut_annonce']
          }
        ]
      });

      if (!item) {
        throw new Error(`${type} introuvable`);
      }

      if (item.annonce.statut_annonce !== 'Active') {
        throw new Error('Cette annonce n\'est plus disponible');
      }

      if (item.annonce.id_vendeur === userId) {
        throw new Error('Vous ne pouvez pas acheter votre propre annonce');
      }

      // Trouver ou créer transaction "En_attente"
      let transaction = await Transaction.findOne({
        where: {
          id_acheteur: userId,
          statut_transaction: 'En_attente'
        }
      });

      if (!transaction) {
        // Créer une transaction temporaire (on définira le vendeur final à la validation)
        transaction = await Transaction.create({
          id_acheteur: userId,
          id_vendeur: item.annonce.id_vendeur, // vendeur du premier item
          id_compte_paiement_vendeur: 1, // placeholder (sera mis à jour à la validation)
          montant: 0,
          statut_transaction: 'En_attente',
          commission: 0
        });
      }

      // Vérifier si l'item est déjà dans le panier
      const ligneExistante = await LigneCommande.findOne({
        where: {
          id_transaction: transaction.id,
          etat: 'En_panier',
          ...(type === 'Produit' ? { id_produit: itemId } : { id_service: itemId })
        }
      });

      if (ligneExistante) {
        // Incrémenter la quantité
        ligneExistante.quantite += quantite;
        await ligneExistante.save();
        return { message: 'Quantité mise à jour', ligne: ligneExistante };
      } else {
        // Créer nouvelle ligne
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

      // Si le panier est vide, supprimer la transaction
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
   * Valider le panier (passer en "Confirmée")
   * TODO: logique de paiement, mise à jour vendeur/compte, etc.
   */
  async validerPanier(userId, comptePaiementVendeurId) {
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

      // Calculer le montant total
      const lignes = await LigneCommande.findAll({
        where: { id_transaction: transaction.id, etat: 'En_panier' },
        include: [
          {
            model: Produit,
            as: 'produit',
            required: false,
            include: [{ model: Annonce, as: 'annonce', attributes: ['prix'] }]
          },
          {
            model: Service,
            as: 'service',
            required: false,
            include: [{ model: Annonce, as: 'annonce', attributes: ['prix'] }]
          }
        ]
      });

      const montantTotal = lignes.reduce((sum, l) => {
        const prix = l.produit ? l.produit.annonce.prix : l.service.annonce.prix;
        return sum + (prix * l.quantite);
      }, 0);

      const commission = montantTotal * 0.05; // 5% de commission exemple

      // Mettre à jour la transaction
      transaction.montant = montantTotal;
      transaction.commission = commission;
      transaction.statut_transaction = 'Confirmée';
      transaction.id_compte_paiement_vendeur = comptePaiementVendeurId;
      await transaction.save();

      // Mettre à jour les lignes
      await LigneCommande.update(
        { etat: 'Confirmée' },
        { where: { id_transaction: transaction.id, etat: 'En_panier' } }
      );

      return {
        message: 'Commande validée',
        transaction: {
          id: transaction.id,
          montant: montantTotal,
          commission
        }
      };

    } catch (error) {
      console.error('❌ Erreur validerPanier:', error);
      throw error;
    }
  }
}

module.exports = new PanierService();