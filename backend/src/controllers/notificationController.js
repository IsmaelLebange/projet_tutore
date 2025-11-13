const notificationService = require('../services/notificationService');

const getUserId = (req) => req.idUtilisateur;

async function obtenirNotifications(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Non authentifié' });

    const notifications = await notificationService.obtenirNotifications(userId);
    return res.json(notifications);
  } catch (error) {
    console.error('❌ Erreur obtenirNotifications:', error);
    return res.status(500).json({ message: error.message });
  }
}

async function confirmerTransaction(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Non authentifié' });

    const { transactionId } = req.params;
    const transaction = await notificationService.confirmerTransaction(userId, parseInt(transactionId));

    return res.json({
      message: 'Confirmation enregistrée',
      transaction: {
        id: transaction.id,
        statut: transaction.statut_transaction,
        confirmation_acheteur: transaction.confirmation_acheteur,
        confirmation_vendeur: transaction.confirmation_vendeur,
      }
    });
  } catch (error) {
    console.error('❌ Erreur confirmerTransaction:', error);
    return res.status(500).json({ message: error.message });
  }
}

async function marquerLu(req, res) {
  try {
    const userId = getUserId(req);
    if (!userId) return res.status(401).json({ message: 'Non authentifié' });

    const { notificationId } = req.params;
    await notificationService.marquerLu(userId, parseInt(notificationId));

    return res.json({ message: 'Notification marquée comme lue' });
  } catch (error) {
    console.error('❌ Erreur marquerLu:', error);
    return res.status(500).json({ message: error.message });
  }
}

module.exports = {
  obtenirNotifications,
  confirmerTransaction,
  marquerLu,
};