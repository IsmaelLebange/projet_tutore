const Notification = require('../models/Notification');
const Utilisateur = require('../models/utilisateur');
const Transaction = require('../models/Transaction');

class NotificationService {
  // Envoyer notification à un utilisateur
  async envoyerNotification(userId, { titre, message, type, transactionId = null }) {
    try {
      return await Notification.create({
        id_utilisateur: userId,
        titre,
        message,
        type_notification: type,
        id_transaction: transactionId,
      });
    } catch (error) {
      console.error('❌ Erreur envoyerNotification:', error);
      throw error;
    }
  }

  // Notifications d'une nouvelle commande
  async notifierNouvelleCommande(transactionId) {
    try {
      const transaction = await Transaction.findByPk(transactionId, {
        include: [
          { model: Utilisateur, as: 'acheteur', attributes: ['prenom', 'nom'] },
          { model: Utilisateur, as: 'vendeur', attributes: ['prenom', 'nom'] }
        ]
      });

      if (!transaction) throw new Error('Transaction introuvable');

      const codeTransaction = `CMD-${transaction.id.toString().padStart(6, '0')}`;

      // Notification au vendeur
      await this.envoyerNotification(transaction.id_vendeur, {
        titre: 'Nouvelle commande reçue',
        message: `${transaction.acheteur.prenom} ${transaction.acheteur.nom} a passé une commande (${codeTransaction}). Confirmez pour valider la transaction.`,
        type: 'commande_recue',
        transactionId: transaction.id
      });

      // Notification à l'acheteur
      await this.envoyerNotification(transaction.id_acheteur, {
        titre: 'Commande confirmée',
        message: `Votre commande ${codeTransaction} a été envoyée au vendeur. Montant: ${transaction.montant} FC.`,
        type: 'commande_confirmee',
        transactionId: transaction.id
      });

      return { codeTransaction };
    } catch (error) {
      console.error('❌ Erreur notifierNouvelleCommande:', error);
      throw error;
    }
  }

  // Confirmer transaction (acheteur/vendeur)
  async confirmerTransaction(userId, transactionId) {
    try {
      const transaction = await Transaction.findByPk(transactionId);
      if (!transaction) throw new Error('Transaction introuvable');

      const isAcheteur = transaction.id_acheteur === userId;
      const isVendeur = transaction.id_vendeur === userId;

      if (!isAcheteur && !isVendeur) {
        throw new Error('Vous n\'êtes pas autorisé à confirmer cette transaction');
      }

      // Marquer confirmation
      if (isAcheteur) {
        transaction.confirmation_acheteur = true;
      } else {
        transaction.confirmation_vendeur = true;
      }

      // Si les deux ont confirmé → transaction validée
      if (transaction.confirmation_acheteur && transaction.confirmation_vendeur) {
        transaction.statut_transaction = 'Validée';
        const commission = transaction.montant * 0.05; // 5% commission
        transaction.commission = commission;

        // Notifier les deux parties
        await this.envoyerNotification(transaction.id_acheteur, {
          titre: 'Transaction validée',
          message: `Votre commande CMD-${transaction.id.toString().padStart(6, '0')} est validée. Paiement effectué.`,
          type: 'transaction_validee',
          transactionId: transaction.id
        });

        await this.envoyerNotification(transaction.id_vendeur, {
          titre: 'Transaction validée',
          message: `Commande CMD-${transaction.id.toString().padStart(6, '0')} validée. Vous recevrez ${(transaction.montant - commission).toFixed(0)} FC.`,
          type: 'transaction_validee',
          transactionId: transaction.id
        });
      }

      await transaction.save();
      return transaction;
    } catch (error) {
      console.error('❌ Erreur confirmerTransaction:', error);
      throw error;
    }
  }

  // Obtenir notifications utilisateur
  async obtenirNotifications(userId) {
    try {
      return await Notification.findAll({
        where: { id_utilisateur: userId },
        include: [
          {
            model: Transaction,
            as: 'transaction',
            attributes: ['id', 'montant', 'statut_transaction'],
            required: false
          }
        ],
        order: [['createdAt', 'DESC']]
      });
    } catch (error) {
      console.error('❌ Erreur obtenirNotifications:', error);
      throw error;
    }
  }

  // Marquer comme lu
  async marquerLu(userId, notificationId) {
    try {
      const notification = await Notification.findOne({
        where: { id: notificationId, id_utilisateur: userId }
      });

      if (!notification) throw new Error('Notification introuvable');

      notification.est_lu = true;
      await notification.save();
      return notification;
    } catch (error) {
      console.error('❌ Erreur marquerLu:', error);
      throw error;
    }
  }
}

module.exports = new NotificationService();