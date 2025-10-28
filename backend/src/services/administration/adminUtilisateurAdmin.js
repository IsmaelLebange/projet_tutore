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

        const offset = (page - 1) * limit;

        const { count, rows: utilisateurs } = await Utilisateur.findAndCountAll({
            where: whereClause,
            include: [{
                model: Adresse,
                as: 'adresseFixe',
                attributes: ['id', 'ville', 'commune', 'quartier']
            }],
            attributes: { exclude: ['mot_de_passe'] },
            order: [['date_inscription', 'DESC']],
            limit: parseInt(limit),
            offset: offset
        });

        return {
            utilisateurs,
            pagination: {
                page: parseInt(page),
                limit: parseInt(limit),
                total: count,
                pages: Math.ceil(count / limit)
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