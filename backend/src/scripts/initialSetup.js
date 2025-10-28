// scripts/initialSetup.js
const utilisateurService = require('../services/utilisateurService');
const adresseService = require('../services/adresseService');
const bcrypt = require('bcrypt');

const initialiserAdmin = async () => {
    try {
        console.log('👑 Vérification admin...');
        
        const emailAdmin = 'admin@busykin.com';
        const adminExistant = await utilisateurService.trouverUtilisateurParEmail(emailAdmin);
        
        if (adminExistant) {
            console.log('✅ Admin existe déjà');
            return adminExistant;
        }

        console.log('Création admin...');

        // ✅ UTILISE LE SERVICE ADRESSE
        const adresseAdmin = await adresseService.creerAdresse({
            rue: '123 Avenue Admin',
            quartier: 'Centre Ville',
            ville: 'Admin City',
            commune: 'Admin Commune',
            latitude: null,
            longitude: null,
        });

        // ✅ UTILISE LE SERVICE UTILISATEUR
        const motDePasseHache = await bcrypt.hash('admin123', 10);
        const admin = await utilisateurService.creerUtilisateur({
            nom: 'Admin',
            prenom: 'System',
            email: emailAdmin,
            mot_de_passe: motDePasseHache,
            numero_de_telephone: '+1234567890',
            id_adresse_fixe: adresseAdmin.id,
            role: 'admin',
            etat: 'Actif',
            reputation: 5.0
        });

        console.log('✅ Admin créé avec succès!');
        console.log('📧 Email: admin@busykin.com');
        console.log('🔐 Mot de passe: admin123');

        return admin;

    } catch (error) {
        console.error('❌ Erreur création admin:', error);
        throw error;
    }
};

module.exports = initialiserAdmin;