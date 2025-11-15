const Notification = require('../models/Notification');
const Utilisateur = require('../models/utilisateur');
const Transaction = require('../models/Transaction');

class NotificationService {
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

  async notifierNouvelleCommande(transactionId) {
    try {
      console.log('🔍 notifierNouvelleCommande appelée avec transactionId:', transactionId); // ✅ DEBUG

      if (!transactionId) {
        throw new Error('transactionId requis');
      }

      const transaction = await Transaction.findByPk(transactionId, {
        include: [
          { 
            model: Utilisateur, 
            as: 'acheteur', 
            attributes: ['prenom', 'nom'],
            foreignKey: 'id_acheteur' // ✅ FIX: Spécifier la clé
          },
          { 
            model: Utilisateur, 
            as: 'vendeur', 
            attributes: ['prenom', 'nom'],
            foreignKey: 'id_vendeur' // ✅ FIX: Spécifier la clé
          }
        ]
      });

      console.log('🔍 Transaction trouvée:', transaction ? `ID: ${transaction.id}` : 'NULL'); // ✅ DEBUG

      if (!transaction) {
        throw new Error('Transaction introuvable');
      }

      // ✅ Vérifier que les relations existent
      if (!transaction.id_acheteur || !transaction.id_vendeur) {
        throw new Error('Transaction incomplète: acheteur ou vendeur manquant');
      }

      const codeTransaction = `CMD-${transaction.id.toString().padStart(6, '0')}`;

      console.log('🔍 Envoi notifications:', {
        vendeur: transaction.id_vendeur,
        acheteur: transaction.id_acheteur,
        code: codeTransaction
      }); // ✅ DEBUG

      // Notification au vendeur
      await this.envoyerNotification(transaction.id_vendeur, {
        titre: 'Nouvelle commande reçue',
        message: `Une nouvelle commande (${codeTransaction}) a été passée. Confirmez pour valider la transaction.`,
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

  // ✅ FIX: Simplifier les autres méthodes avec meilleure gestion d'erreurs
  async confirmerTransaction(userId, transactionId) {
    try {
      if (!userId || !transactionId) {
        throw new Error('userId et transactionId requis');
      }

      const transaction = await Transaction.findByPk(transactionId);
      if (!transaction) {
        throw new Error('Transaction introuvable');
      }

      const isAcheteur = transaction.id_acheteur === userId;
      const isVendeur = transaction.id_vendeur === userId;

      if (!isAcheteur && !isVendeur) {
        throw new Error('Vous n\'êtes pas autorisé à confirmer cette transaction');
      }

      if (isAcheteur) {
        transaction.confirmation_acheteur = true;
      } else {
        transaction.confirmation_vendeur = true;
      }

      if (transaction.confirmation_acheteur && transaction.confirmation_vendeur) {
        transaction.statut_transaction = 'Validée';
        const commission = transaction.montant * 0.05;
        transaction.commission = commission;

        // Notifications simplifiées
        await this.envoyerNotification(transaction.id_acheteur, {
          titre: 'Transaction validée',
          message: `Votre commande CMD-${transaction.id.toString().padStart(6, '0')} est validée.`,
          type: 'transaction_validee',
          transactionId: transaction.id
        });

        await this.envoyerNotification(transaction.id_vendeur, {
          titre: 'Transaction validée',
          message: `Commande CMD-${transaction.id.toString().padStart(6, '0')} validée.`,
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

  async obtenirNotifications(userId) {
    try {
      if (!userId) {
        throw new Error('userId requis');
      }

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

  async marquerLu(userId, notificationId) {
    try {
      if (!userId || !notificationId) {
        throw new Error('userId et notificationId requis');
      }

      const notification = await Notification.findOne({
        where: { id: notificationId, id_utilisateur: userId }
      });

      if (!notification) {
        throw new Error('Notification introuvable');
      }

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