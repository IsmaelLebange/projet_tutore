// src/models/index.js
// Ce fichier assure que tous les modèles sont chargés par Sequelize pour la synchronisation

require('./Adresse'); 
require('./utilisateur'); 
require('./ComptePaiement'); 

// Catégories/Types
require('./CategorieProduit');
require('./CategorieService');
require('./TypeProduit');
require('./TypeService');

// Annonces/Produits/Services
require('./Annonce');
require('./Produit');
require('./Service');

// Activités/Transactions
require('./PhotoProduit');
require('./PhotoService');
require('./Transaction');
require('./LigneCommande');
require('./Notation');
require('./Message');

// Le fichier n'a pas besoin d'exporter quoi que ce soit si son seul but est de charger les modèles