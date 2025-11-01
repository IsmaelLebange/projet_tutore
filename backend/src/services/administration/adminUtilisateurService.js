// services/administration/utilisateurService.js
const { Op } = require('sequelize');
const Utilisateur = require('../../models/utilisateur');
const Adresse = require('../../models/Adresse');


class AdminUtilisateurService {


    static async obtenirUtilisateurs(options = {}) {
        const { page = 1, limit = 50, recherche = '', role = '', etat = '' } = options;

        const whereClause = {};

        if (recherche) {
            whereClause[Op.or] = [
                { nom: { [Op.like]: `%${recherche}%` } },
                { prenom: { [Op.like]: `%${recherche}%` } },
                { email: { [Op.like]: `%${recherche}%` } }
            ];
        }

        if (role) whereClause.role = role;
        if (etat) whereClause.etat = etat;

        // JUSTIFICATION: Assurer que 'limit' et 'page' sont des entiers pour éviter les problèmes 
        // dans la requête Sequelize et l'affichage.
        const parsedLimit = parseInt(limit, 10);
        const parsedPage = parseInt(page, 10);

        const offset = (parsedPage - 1) * parsedLimit;

        const { count, rows: utilisateurs } = await Utilisateur.findAndCountAll({
            where: whereClause,
            include: [{
                model: Adresse,
                as: 'adresseFixe',
                attributes: ['id','rue', 'ville',  'quartier']
            }],
            attributes: { exclude: ['mot_de_passe'] },
            order: [['date_inscription', 'DESC']],
            // JUSTIFICATION: Utiliser la variable parsée
            limit: parsedLimit, 
            offset: offset
        });

        // JUSTIFICATION: Correction des logs et de la pagination pour utiliser les variables correctement
        console.log('📥 Requête utilisateurs reçue:', { page: parsedPage, limit: parsedLimit, recherche, role, etat });
        console.log(`📤 ${utilisateurs.length} utilisateurs retournés`);

        return {
            utilisateurs,
            pagination: {
                page: parsedPage,
                limit: parsedLimit,
                total: count,
                pages: Math.ceil(count / parsedLimit)
            }
        };
    }


    /**
     * Change l'état d'un utilisateur
     */
    static async changerEtatUtilisateur(id, etat) {
        if (!['Actif', 'Bloqué'].includes(etat)) {
            throw new Error('État invalide');
        }

        const [lignesAffectees] = await Utilisateur.update(
            { etat },
            { where: { id } }
        );

        if (lignesAffectees === 0) {
            throw new Error('Utilisateur non trouvé');
        }

        return { message: `Utilisateur ${etat === 'Bloqué' ? 'bloqué' : 'débloqué'} avec succès` };
    }

    /**
     * Change le rôle d'un utilisateur
     */
    static async changerRoleUtilisateur(id, role, idAdminActuel) {
        if (!['utilisateur', 'admin', 'moderateur'].includes(role)) {
            throw new Error('Rôle invalide');
        }

        // Empêcher un admin de se retirer ses propres droits
        if (parseInt(id) === parseInt(idAdminActuel) && role !== 'admin') {
            throw new Error('Vous ne pouvez pas retirer vos propres droits administrateur');
        }

        const [lignesAffectees] = await Utilisateur.update(
            { role },
            { where: { id } }
        );

        if (lignesAffectees === 0) {
            throw new Error('Utilisateur non trouvé');
        }

        return { message: `Rôle changé en ${role} avec succès` };
    }
}

module.exports = AdminUtilisateurService;