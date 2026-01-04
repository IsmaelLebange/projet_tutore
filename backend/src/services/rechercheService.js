const Annonce = require('../models/Annonce');
const Utilisateur = require('../models/utilisateur');
const Adresse = require('../models/Adresse');
const Produit = require('../models/Produit');
const PhotoProduit = require('../models/PhotoProduit');
const PhotoUtilisateur = require('../models/PhotoUtilisateur');
const CategorieProduit = require('../models/CategorieProduit');
const TypeProduit = require('../models/TypeProduit');
const { Op } = require('sequelize');
const PhotoService = require('../models/PhotoService');
const CategorieService = require('../models/CategorieService');
const TypeService = require('../models/TypeService');
const Service = require('../models/Service');

class RechercheService {
    async rechercherProduit(q) {
        try {
            if (!q || q.trim() == "") return [];

            // On sépare les mots pour une recherche plus flexible
            const mots = q.trim().split(/\s+/);

            return await Produit.findAll({
                include: [
                    {
                        model: Annonce,
                        as: 'annonce',
                        include: [{
                            model: Utilisateur,
                            as: 'vendeur',
                            include: [{
                                model: Adresse,
                                as: 'adresseFixe' // Variable adresse
                            }]
                        }],
                    },
                    {
                        model: TypeProduit,
                        as: 'type',
                        include: [{
                            model: CategorieProduit,
                            as: 'categorie'
                        }]
                    },
                    {
                        model: PhotoProduit,
                        as: 'photos',
                    }
                ],
                where: {
                    [Op.and]: mots.map(mot => ({
                        [Op.or]: [
                            // Recherche dans l'Annonce (titre, description, statut)
                            { "$annonce.titre$": { [Op.like]: `%${mot}%` } },
                            { "$annonce.description$": { [Op.like]: `%${mot}%` } },

                            // Recherche dans le Type et la Catégorie
                            { "$type.nom_type$": { [Op.like]: `%${mot}%` } },
                            { "$type.categorie.nom_categorie$": { [Op.like]: `%${mot}%` } },

                            // Recherche dans l'Adresse (Ville, Quartier, Avenue)
                            { "$annonce.vendeur.adresseFixe.ville$": { [Op.like]: `%${mot}%` } },
                            { "$annonce.vendeur.adresseFixe.quartier$": { [Op.like]: `%${mot}%` } },
                            { "$annonce.vendeur.adresseFixe.rue$": { [Op.like]: `%${mot}%` } }
                        ]
                    }))
                }
            });
        } catch (e) {
            console.error("Erreur lors de la recherche complète :", e);
            return [];
        }
    }

    async rechercherService(q) {
        try {
            if (!q || q.trim() == "") return [];
            const mots = q.trim().split(/\s+/);
            return await Service.findAll({
                include: [
                    {
                        model: Annonce,
                        as: 'annonce',
                        include: [{
                            model: Utilisateur,
                            as: 'vendeur',
                            include: [{
                                model: Adresse,
                                as: 'adresseFixe',
                            }]
                        }],
                    },
                    {
                        model: TypeService,
                        as: 'type',

                        include: [{
                            model: CategorieService,
                            as: 'categorie'
                        }]
                    },
                    {
                        model: PhotoService,
                        as: 'photos',
                    }
                ],
                where: {
                    [Op.and]: mots.map(mot => ({
                        [Op.or]: [
                            { "$annonce.titre$": { [Op.like]: `%${mot}%` } },
                            { "$annonce.description$": { [Op.like]: `%${mot}%` } },

                            { "$type.nom_type$": { [Op.like]: `%${mot}%` } },
                            { "$type.categorie.nom_categorie$": { [Op.like]: `%${mot}%` } },

                            { "$annonce.vendeur.adresseFixe.ville$": { [Op.like]: `%${mot}%` } },
                            { "$annonce.vendeur.adresseFixe.quartier$": { [Op.like]: `%${mot}%` } },
                            { "$annonce.vendeur.adresseFixe.rue$": { [Op.like]: `%${mot}%` } }
                        ]
                    }))
                }
            });
        } catch (e) {
            console.error("Erreur lors de la recherche globale", e);
        }
    }

    async rechercherAnnonce(q) {
        try {

            const [produit,service]=await Promise.all([this.rechercherProduit(q), this.rechercherService(q)])
            return [...produit,...service];
        }catch (e) {
            console.error("Erreur lors de la recherche globale", e);
        }
    }
}

module.exports = new RechercheService();