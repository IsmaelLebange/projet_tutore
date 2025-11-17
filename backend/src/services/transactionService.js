const Transaction = require('../models/Transaction');
const LigneCommande = require('../models/LigneCommande');
const Utilisateur = require('../models/utilisateur');
const ComptePaiement = require('../models/ComptePaiement');
const Produit = require('../models/Produit');
const Service = require('../models/Service');
const Annonce = require('../models/Annonce');
const Adresse = require('../models/Adresse');
const PhotoProduit = require('../models/PhotoProduit');
const PhotoService = require('../models/PhotoService');

class TransactionService {
  
  /**
   * Obtenir toutes les transactions d'un utilisateur (acheteur ou vendeur)
   */
  async obtenirTransactionsUtilisateur(userId) {
    try {
      console.log('📦 Recherche transactions pour userId:', userId);

      const transactions = await Transaction.findAll({
        where: {
          [require('sequelize').Op.or]: [
            { id_acheteur: userId },
            { id_vendeur: userId }
          ]
        },
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
                    attributes: ['titre', 'prix']
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
                    attributes: ['titre', 'prix']
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
          }
        ],
        order: [['date_transaction', 'DESC']]
      });

      console.log(`✅ ${transactions.length} transaction(s) trouvée(s)`);

      // Formater les transactions
      return transactions.map(t => {
        const tJson = t.toJSON();
        const isAcheteur = tJson.id_acheteur === userId;
        
        // Compter les articles
        const nbArticles = tJson.lignesCommande?.reduce((sum, ligne) => sum + ligne.quantite, 0) || 0;

        // Récupérer la première image
        let premiereImage = null;
        if (tJson.lignesCommande && tJson.lignesCommande.length > 0) {
          const premiereLigne = tJson.lignesCommande[0];
          if (premiereLigne.produit?.photos?.length > 0) {
            premiereImage = premiereLigne.produit.photos[0].url;
          } else if (premiereLigne.service?.photos?.length > 0) {
            premiereImage = premiereLigne.service.photos[0].url;
          }
        }

        return {
          id: tJson.id,
          code: `FAC-${tJson.id.toString().padStart(6, '0')}`,
          dateTransaction: tJson.date_transaction,
          montant: tJson.montant,
          commission: tJson.commission,
          statut: tJson.statut_transaction,
          role: isAcheteur ? 'acheteur' : 'vendeur',
          nbArticles,
          premiereImage,
          acheteur: {
            id: tJson.acheteur.id,
            nom: `${tJson.acheteur.prenom} ${tJson.acheteur.nom}`,
            email: tJson.acheteur.email,
            telephone: tJson.acheteur.numero_de_telephone
          },
          vendeur: {
            id: tJson.vendeur.id,
            nom: `${tJson.vendeur.prenom} ${tJson.vendeur.nom}`,
            email: tJson.vendeur.email,
            telephone: tJson.vendeur.numero_de_telephone
          }
        };
      });

    } catch (error) {
      console.error('❌ Erreur obtenirTransactionsUtilisateur:', error);
      throw error;
    }
  }

  /**
   * Obtenir le détail complet d'une transaction
   */
  async obtenirDetailTransaction(transactionId, userId) {
    try {
      console.log('🔍 Recherche détail transaction:', transactionId, 'pour user:', userId);

      const transaction = await Transaction.findByPk(transactionId, {
        include: [
          {
            model: Utilisateur,
            as: 'acheteur',
            attributes: ['id', 'prenom', 'nom', 'email', 'numero_de_telephone', 'reputation'],
            include: [
              {
                model: Adresse,
                as: 'adresseFixe',
                attributes: ['ville', 'quartier', 'rue']
              }
            ]
          },
          {
            model: Utilisateur,
            as: 'vendeur',
            attributes: ['id', 'prenom', 'nom', 'email', 'numero_de_telephone', 'reputation'],
            include: [
              {
                model: Adresse,
                as: 'adresseFixe',
                attributes: ['ville', 'quartier', 'rue']
              }
            ]
          },
          {
            model: ComptePaiement,
            as: 'comptePaiementVendeur',
            attributes: ['entreprise', 'numero_compte']
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
                    attributes: ['id', 'titre', 'description', 'prix'],
                    include: [
                      {
                        model: Adresse,
                        as: 'adresseAnnonce',
                        attributes: ['ville', 'quartier', 'rue']
                      }
                    ]
                  },
                  {
                    model: PhotoProduit,
                    as: 'photos',
                    attributes: ['url']
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
                        model: Adresse,
                        as: 'adresseAnnonce',
                        attributes: ['ville', 'quartier', 'rue']
                      }
                    ]
                  },
                  {
                    model: PhotoService,
                    as: 'photos',
                    attributes: ['url']
                  }
                ]
              }
            ]
          }
        ]
      });

      if (!transaction) {
        throw new Error('Transaction introuvable');
      }

      const tJson = transaction.toJSON();

      // Vérifier que l'utilisateur est bien concerné par cette transaction
      if (tJson.id_acheteur !== userId && tJson.id_vendeur !== userId) {
        throw new Error('Vous n\'êtes pas autorisé à voir cette transaction');
      }

      const isAcheteur = tJson.id_acheteur === userId;

      // Formater les lignes de commande
      const articles = tJson.lignesCommande.map(ligne => {
        const item = ligne.produit || ligne.service;
        const annonce = item?.annonce;

        return {
          id: ligne.id,
          type: ligne.produit ? 'Produit' : 'Service',
          titre: annonce?.titre || 'N/A',
          description: annonce?.description || '',
          prixUnitaire: annonce?.prix || 0,
          quantite: ligne.quantite,
          sousTotal: (annonce?.prix || 0) * ligne.quantite,
          etat: ligne.etat,
          images: item?.photos?.map(p => p.url) || [],
          adresse: annonce?.adresseAnnonce ? {
            commune: annonce.adresseAnnonce.ville,
            quartier: annonce.adresseAnnonce.quartier,
            rue: annonce.adresseAnnonce.rue
          } : null
        };
      });

      return {
        id: tJson.id,
        code: `FAC-${tJson.id.toString().padStart(6, '0')}`,
        dateTransaction: tJson.date_transaction,
        montant: tJson.montant,
        commission: tJson.commission,
        montantNet: tJson.montant - tJson.commission,
        statut: tJson.statut_transaction,
        confirmationAcheteur: tJson.confirmation_acheteur || false,
        confirmationVendeur: tJson.confirmation_vendeur || false,
        role: isAcheteur ? 'acheteur' : 'vendeur',
        
        acheteur: {
          id: tJson.acheteur.id,
          nom: `${tJson.acheteur.prenom} ${tJson.acheteur.nom}`,
          email: tJson.acheteur.email,
          telephone: tJson.acheteur.numero_de_telephone,
          reputation: tJson.acheteur.reputation,
          adresse: tJson.acheteur.adresseFixe ? {
            commune: tJson.acheteur.adresseFixe.ville,
            quartier: tJson.acheteur.adresseFixe.quartier,
            rue: tJson.acheteur.adresseFixe.rue
          } : null
        },
        
        vendeur: {
          id: tJson.vendeur.id,
          nom: `${tJson.vendeur.prenom} ${tJson.vendeur.nom}`,
          email: tJson.vendeur.email,
          telephone: tJson.vendeur.numero_de_telephone,
          reputation: tJson.vendeur.reputation,
          adresse: tJson.vendeur.adresseFixe ? {
            commune: tJson.vendeur.adresseFixe.ville,
            quartier: tJson.vendeur.adresseFixe.quartier,
            rue: tJson.vendeur.adresseFixe.rue
          } : null
        },

        comptePaiement: tJson.comptePaiementVendeur ? {
          entreprise: tJson.comptePaiementVendeur.entreprise,
          numeroCompte: tJson.comptePaiementVendeur.numero_compte
        } : null,

        articles
      };

    } catch (error) {
      console.error('❌ Erreur obtenirDetailTransaction:', error);
      throw error;
    }
  }

  /**
   * Confirmer une transaction (acheteur ou vendeur)
   */
  async confirmerTransaction(transactionId, userId) {
    try {
      const transaction = await Transaction.findByPk(transactionId);

      if (!transaction) {
        throw new Error('Transaction introuvable');
      }

      const isAcheteur = transaction.id_acheteur === userId;
      const isVendeur = transaction.id_vendeur === userId;

      if (!isAcheteur && !isVendeur) {
        throw new Error('Vous n\'êtes pas autorisé à confirmer cette transaction');
      }

      // Mettre à jour la confirmation
      if (isAcheteur) {
        transaction.confirmation_acheteur = true;
      } else {
        transaction.confirmation_vendeur = true;
      }

      // Si les deux ont confirmé, passer à "Validée"
      if (transaction.confirmation_acheteur && transaction.confirmation_vendeur) {
        transaction.statut_transaction = 'Validée';
      } else {
        transaction.statut_transaction = 'En_attente_confirmation';
      }

      await transaction.save();

      console.log(`✅ Transaction ${transactionId} confirmée par ${isAcheteur ? 'acheteur' : 'vendeur'}`);

      return transaction;

    } catch (error) {
      console.error('❌ Erreur confirmerTransaction:', error);
      throw error;
    }
  }
}

module.exports = new TransactionService();