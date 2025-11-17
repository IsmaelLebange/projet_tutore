const transactionService = require('../services/transactionService');

const getUserId = (req) => {
  return req.idUtilisateur || req.user?.id || req.userId;
};

// Obtenir toutes les transactions de l'utilisateur
async function obtenirMesTransactions(req, res) {
  try {
    const userId = getUserId(req);
    console.log('🔍 obtenirMesTransactions - userId:', userId);
    
    if (!userId) {
      return res.status(401).json({ message: 'Utilisateur non authentifié' });
    }

    const transactions = await transactionService.obtenirTransactionsUtilisateur(userId);
    return res.json(transactions);
  } catch (error) {
    console.error('❌ Erreur obtenirMesTransactions:', error);
    return res.status(500).json({ message: error.message });
  }
}

// Obtenir le détail d'une transaction
async function obtenirDetailTransaction(req, res) {
  try {
    const userId = getUserId(req);
    const { id } = req.params;
    
    console.log('🔍 obtenirDetailTransaction - userId:', userId, 'transactionId:', id);
    
    if (!userId) {
      return res.status(401).json({ message: 'Utilisateur non authentifié' });
    }

    if (!id) {
      return res.status(400).json({ message: 'ID de transaction requis' });
    }

    const transaction = await transactionService.obtenirDetailTransaction(parseInt(id), userId);
    return res.json(transaction);
  } catch (error) {
    console.error('❌ Erreur obtenirDetailTransaction:', error);
    
    if (error.message.includes('introuvable')) {
      return res.status(404).json({ message: error.message });
    }
    if (error.message.includes('autorisé')) {
      return res.status(403).json({ message: error.message });
    }
    
    return res.status(500).json({ message: error.message });
  }
}

// Confirmer la réception (acheteur) ou l'envoi (vendeur)
async function confirmerTransaction(req, res) {
  try {
    const userId = getUserId(req);
    const { id } = req.params;
    
    console.log('🔍 confirmerTransaction - userId:', userId, 'transactionId:', id);
    
    if (!userId) {
      return res.status(401).json({ message: 'Utilisateur non authentifié' });
    }

    const transaction = await transactionService.confirmerTransaction(parseInt(id), userId);
    return res.json({ 
      message: 'Confirmation enregistrée avec succès',
      transaction 
    });
  } catch (error) {
    console.error('❌ Erreur confirmerTransaction:', error);
    return res.status(500).json({ message: error.message });
  }
}

module.exports = {
  obtenirMesTransactions,
  obtenirDetailTransaction,
  confirmerTransaction,
};