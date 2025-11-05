// scripts/initialCategories.js
const CategorieProduit = require('../models/CategorieProduit');
const TypeProduit = require('../models/TypeProduit');
const CategorieService = require('../models/CategorieService');
const TypeService = require('../models/TypeService');

const initialiserCategoriesEtTypes = async () => {
  try {
    console.log('📦 Vérification des catégories et types...');

    const nbCatProd = await CategorieProduit.count();
    const nbCatServ = await CategorieService.count();

    if (nbCatProd > 0 && nbCatServ > 0) {
      console.log('✅ Catégories déjà initialisées.');
      return;
    }

    console.log('⏳ Insertion des catégories et types de base...');

    // --- PRODUITS ---
    const categoriesProduits = [
      { nom_categorie: 'Électronique', types: ['Smartphone', 'Ordinateur', 'Tablette', 'Casque audio', 'Télévision'] },
      { nom_categorie: 'Vêtements', types: ['Homme', 'Femme', 'Enfant', 'Chaussures', 'Accessoires'] },
      { nom_categorie: 'Maison & Décoration', types: ['Mobilier', 'Cuisine', 'Éclairage', 'Textile', 'Décoration murale'] },
      { nom_categorie: 'Véhicules', types: ['Voiture', 'Moto', 'Vélo', 'Camion', 'Accessoires Auto'] },
      { nom_categorie: 'Informatique', types: ['Composant PC', 'Périphérique', 'Imprimante', 'Logiciel', 'Serveur'] },
      { nom_categorie: 'Beauté & Santé', types: ['Cosmétiques', 'Parfum', 'Hygiène', 'Accessoires beauté', 'Santé'] },
      { nom_categorie: 'Sport & Loisirs', types: ['Vêtements sport', 'Matériel sport', 'Fitness', 'Camping', 'Jeux de société'] }
    ];

    for (const cat of categoriesProduits) {
      const newCat = await CategorieProduit.create({ nom_categorie: cat.nom_categorie });
      for (const type of cat.types) {
        await TypeProduit.create({ nom_type: type, id_categorie: newCat.id });
      }
    }

    // --- SERVICES ---
    const categoriesServices = [
      { nom_categorie: 'Réparation', types: ['Électronique', 'Véhicule', 'Maison', 'Plomberie', 'Électricité'] },
      { nom_categorie: 'Cours', types: ['Scolaire', 'Langue', 'Musique', 'Informatique', 'Sport'] },
      { nom_categorie: 'Santé & Bien-être', types: ['Massage', 'Coiffure', 'Esthétique', 'Coaching', 'Nutrition'] },
      { nom_categorie: 'Transport', types: ['Livraison', 'Déménagement', 'Taxi', 'Chauffeur privé', 'Location véhicule'] },
      { nom_categorie: 'BTP & Artisanat', types: ['Maçonnerie', 'Menuiserie', 'Peinture', 'Plomberie', 'Électricité'] },
      { nom_categorie: 'Événementiel', types: ['Photographe', 'DJ', 'Traiteur', 'Décoration', 'Location matériel'] }
    ];

    for (const cat of categoriesServices) {
      const newCat = await CategorieService.create({ nom_categorie: cat.nom_categorie });
      for (const type of cat.types) {
        await TypeService.create({ nom_type: type, id_categorie: newCat.id });
      }
    }

    console.log('✅ Catégories et types initialisés avec succès !');

  } catch (error) {
    console.error('❌ Erreur lors de l’initialisation des catégories:', error);
  }
};

module.exports = initialiserCategoriesEtTypes;
