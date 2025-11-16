const Transaction = require('../models/Transaction');
const LigneCommande = require('../models/LigneCommande');
const Produit = require('../models/Produit');
const Service = require('../models/Service');
const Annonce = require('../models/Annonce');
const Utilisateur = require('../models/Utilisateur');
const { Op } = require('sequelize');

class TransactionController {
  /**
   * Obtenir la liste des transactions pour l'utilisateur connecté (acheteur ou vendeur)
   */
  async obtenirTransactions(req, res) {
    try {
      const userId = req.idUtilisateur;

      const transactions = await Transaction.findAll({
        where: {
          [Op.or]: [
            { id_acheteur: userId },
            { id_vendeur: userId }
          ]
        },
        include: [
          {
            model: Utilisateur,
            as: 'acheteur',
            attributes: ['id', 'prenom', 'nom']
          },
          {
            model: Utilisateur,
            as: 'vendeur',
            attributes: ['id', 'prenom', 'nom']
          },
          {
            model: LigneCommande,
            as: 'lignesCommande',
            attributes: ['id']
          }
        ],
        order: [['date_transaction', 'DESC']]
      });

      const transactionsFormatees = transactions.map(t => ({
        id: t.id,
        date_transaction: t.date_transaction,
        montant: t.montant,
        statut_transaction: t.statut_transaction,
        id_acheteur: t.id_acheteur,
        id_vendeur: t.id_vendeur,
        acheteur: t.acheteur,
        vendeur: t.vendeur,
        nombreLignes: t.lignesCommande ? t.lignesCommande.length : 0
      }));

      return res.status(200).json(transactionsFormatees);

    } catch (error) {
      console.error('❌ Erreur obtenirTransactions:', error);
      return res.status(500).json({ message: 'Erreur lors de la récupération des transactions' });
    }
  }

  /**
   * Obtenir les détails complets d'une facture (transaction validée)
   */
  async getFacture(req, res) {
    try {
      const userId = req.idUtilisateur;
      const { transactionId } = req.params;

      const transaction = await Transaction.findByPk(transactionId, {
        include: [
          {
            model: Utilisateur,
            as: 'acheteur',
            attributes: ['id', 'prenom', 'nom', 'email', 'numero_de_telephone']
          },
          {
            model: Utilisateur,
            as: 'vendeur',
            attributes: ['id', 'prenom', 'nom', 'email', 'numero_de_telephone']
          },
          {
            model: LigneCommande,
            as: 'lignesCommande',
            include: [
              {
                model: Produit,
                as: 'produit',
                required: false,
                include: [
                  {
                    model: Annonce,
                    as: 'annonce',
                    attributes: ['id', 'titre', 'description', 'prix']
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
                    attributes: ['id', 'titre', 'description', 'prix']
                  }
                ]
              }
            ]
          }
        ]
      });

      if (!transaction) {
        return res.status(404).json({ message: 'Transaction introuvable' });
      }

      // Vérifier que l'utilisateur est autorisé (acheteur ou vendeur)
      if (transaction.id_acheteur !== userId && transaction.id_vendeur !== userId) {
        return res.status(403).json({ message: 'Accès non autorisé à cette transaction' });
      }

      // Formater les lignes de commande
      const lignesFormatees = transaction.lignesCommande.map(ligne => {
        const isProduit = !!ligne.produit;
        const item = isProduit ? ligne.produit : ligne.service;
        const annonce = item.annonce;

        return {
          id: ligne.id,
          quantite: ligne.quantite,
          type: isProduit ? 'Produit' : 'Service',
          titre: annonce.titre,
          description: annonce.description,
          prixUnitaire: annonce.prix,
          sousTotal: annonce.prix * ligne.quantite
        };
      });

      const codeTransaction = `CMD-${transaction.id.toString().padStart(6, '0')}`;

      const facture = {
        id: transaction.id,
        codeTransaction,
        date_transaction: transaction.date_transaction,
        montant: transaction.montant,
        commission: transaction.commission,
        statut_transaction: transaction.statut_transaction,
        acheteur: {
          id: transaction.acheteur.id,
          nom: `${transaction.acheteur.prenom} ${transaction.acheteur.nom}`,
          email: transaction.acheteur.email,
          telephone: transaction.acheteur.numero_de_telephone
        },
        vendeur: {
          id: transaction.vendeur.id,
          nom: `${transaction.vendeur.prenom} ${transaction.vendeur.nom}`,
          email: transaction.vendeur.email,
          telephone: transaction.vendeur.numero_de_telephone
        },
        lignes: lignesFormatees,
        total: lignesFormatees.reduce((sum, l) => sum + l.sousTotal, 0)
      };

      return res.status(200).json(facture);

    } catch (error) {
      console.error('❌ Erreur getFacture:', error);
      return res.status(500).json({ message: 'Erreur lors de la récupération de la facture' });
    }
  }
}

module.exports = new TransactionController();
