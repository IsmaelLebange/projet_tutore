# Documentation d'Implémentation - Projet BusyKin

## Table des Matières
1. [Introduction](#1-introduction)
2. [Architecture Générale](#2-architecture-générale)
3. [Stack Technique](#3-stack-technique)
4. [Backend - Node.js/Express](#4-backend---nodejsexpress)
5. [Frontend - Flutter](#5-frontend---flutter)
6. [Base de Données](#6-base-de-données)
7. [API REST](#7-api-rest)
8. [Authentification et Sécurité](#8-authentification-et-sécurité)
9. [Fonctionnalités Principales](#9-fonctionnalités-principales)
10. [Gestion des Fichiers](#10-gestion-des-fichiers)
11. [Tests et Déploiement](#11-tests-et-déploiement)

---

## 1. Introduction

### 1.1 Contexte du Projet
BusyKin est une plateforme de marketplace permettant aux utilisateurs d'acheter, vendre des produits et proposer/rechercher des services. Le projet implémente une architecture client-serveur moderne avec un backend REST API et une application mobile multiplateforme.

### 1.2 Objectifs
- Créer une plateforme sécurisée de e-commerce et services
- Permettre la gestion d'annonces (produits et services)
- Implémenter un système de messagerie entre utilisateurs
- Fournir un panneau d'administration complet
- Assurer la scalabilité et la maintenabilité du code

---

## 2. Architecture Générale

### 2.1 Architecture Client-Serveur
```
┌─────────────────┐         HTTP/HTTPS         ┌──────────────────┐
│                 │ ◄────────────────────────► │                  │
│  Application    │         REST API           │   Serveur API    │
│  Flutter        │         (JSON)             │   Node.js        │
│  (Mobile)       │                            │   Express        │
└─────────────────┘                            └──────────────────┘
                                                        │
                                                        │
                                                        ▼
                                                ┌──────────────────┐
                                                │   Base SQLite    │
                                                │   (Sequelize)    │
                                                └──────────────────┘
```

### 2.2 Modèle de Communication
- **Frontend ↔ Backend** : Communication via API REST
- **Format d'échange** : JSON
- **Authentification** : JWT (JSON Web Tokens)
- **Sécurité** : HTTPS, CORS configuré

### 2.3 Séparation des Responsabilités
- **Backend** : Logique métier, validation, persistance des données
- **Frontend** : Interface utilisateur, expérience utilisateur, présentation
- **Base de données** : Stockage et gestion des données

---

## 3. Stack Technique

### 3.1 Backend
| Technologie | Version | Rôle |
|------------|---------|------|
| Node.js | ≥18.0.0 | Runtime JavaScript serveur |
| Express | 5.1.0 | Framework web REST API |
| Sequelize | 6.37.7 | ORM pour base de données |
| SQLite3 | 5.1.7 | Base de données embarquée |
| JWT | 9.0.2 | Authentification par tokens |
| Bcrypt | 6.0.0 | Hachage des mots de passe |
| Multer | - | Gestion upload fichiers |
| CORS | 2.8.5 | Gestion des requêtes cross-origin |

### 3.2 Frontend
| Technologie | Version | Rôle |
|------------|---------|------|
| Flutter | - | Framework mobile multiplateforme |
| Dart | ^3.8.1 | Langage de programmation |
| http | ^1.5.0 | Client HTTP pour API calls |
| shared_preferences | ^2.5.3 | Stockage local (tokens) |
| file_picker | ^10.3.3 | Sélection de fichiers |
| image_picker | ^1.2.0 | Sélection d'images |

### 3.3 Outils de Développement
- **Nodemon** : Rechargement automatique du serveur
- **ESLint** : Linting JavaScript
- **Jest** : Tests unitaires backend
- **Flutter Test** : Tests frontend
- **Git** : Contrôle de version

---

## 4. Backend - Node.js/Express

### 4.1 Structure du Projet Backend
```
backend/
├── src/
│   ├── app.js                    # Configuration Express
│   ├── config/
│   │   ├── database.js           # Configuration Sequelize
│   │   └── express.js            # Middleware Express
│   ├── controllers/              # Contrôleurs (logique métier)
│   │   ├── authController.js     # Authentification
│   │   ├── userController.js     # Gestion utilisateurs
│   │   ├── produitController.js  # Gestion produits
│   │   ├── serviceController.js  # Gestion services
│   │   ├── annonceController.js  # Gestion annonces
│   │   ├── panierController.js   # Gestion panier
│   │   └── administration/       # Controllers admin
│   ├── models/                   # Modèles Sequelize
│   │   ├── Utilisateur.js
│   │   ├── Annonce.js
│   │   ├── Produit.js
│   │   ├── Service.js
│   │   ├── Message.js
│   │   └── ... (autres modèles)
│   ├── routes/                   # Définition des routes
│   │   ├── authRoutes.js
│   │   ├── userRoutes.js
│   │   ├── produitRoutes.js
│   │   └── ... (autres routes)
│   ├── middlewares/              # Middlewares personnalisés
│   │   ├── authMiddleware.js     # Vérification JWT
│   │   ├── verifierAdmin.js      # Vérification rôle admin
│   │   └── upload.js             # Gestion uploads Multer
│   ├── services/                 # Couche service (logique métier)
│   │   ├── utilisateurService.js
│   │   ├── produitService.js
│   │   └── ... (autres services)
│   └── scripts/                  # Scripts d'initialisation
│       ├── initialSetup.js
│       └── initialCategories.js
├── database/                     # Fichiers base de données
│   └── busykin_db.sqlite
├── uploads/                      # Fichiers uploadés
├── server.js                     # Point d'entrée application
├── package.json                  # Dépendances et scripts
└── .env                         # Variables d'environnement
```

### 4.2 Configuration de l'Application (server.js)
```javascript
const app = require('./src/app');
const { connectDB } = require('./src/config/database');
const initialiserAdmin = require('./src/scripts/initialSetup');
const initialCategories = require('./src/scripts/initialCategories');

const PORT = process.env.PORT || 8080;

connectDB()
    .then(async () => {
        await initialiserAdmin();
        await initialCategories();
        
        app.listen(PORT, () => {
            console.log(`🚀 Serveur sur port ${PORT}`);
        });
    })
    .catch((error) => {
        console.error('❌ ERREUR FATALE:', error);
        process.exit(1);
    });
```

**Explication** :
1. Connexion à la base de données
2. Initialisation de l'administrateur par défaut
3. Création des catégories initiales
4. Démarrage du serveur sur le port configuré

### 4.3 Configuration Express (app.js)
```javascript
const express = require('express');
const path = require('path');
const setupExpress = require('./config/express');
const authRoutes = require('./routes/authRoutes');
// ... autres imports

const app = express();

setupExpress(app);  // Middleware (CORS, JSON parser, etc.)

// Routes
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/annonces', annonceRoutes);
app.use('/api/categories', categorieRoutes);
app.use('/api/produits', produitRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/panier', panierRoutes);

// Route 404
app.use((req, res, next) => {
    res.status(404).json({ message: 'Route non trouvée' });
});

module.exports = app;
```

### 4.4 Configuration Base de Données (database.js)
```javascript
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize({
    dialect: process.env.DB_DIALECT,      // 'sqlite'
    storage: process.env.DB_STORAGE,      // chemin vers .sqlite
    logging: false,
    define: {
        freezeTableName: true,
    }
});

const connectDB = async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ Connexion DB OK');

        require('../models/index');  // Charge tous les modèles

        const syncOption = process.env.NODE_ENV === 'production' 
            ? { alter: true } 
            : { force: false };
        await sequelize.sync(syncOption);
        
        console.log('✅ Tables synchronisées');
    } catch (error) {
        console.error('❌ Erreur DB:', error);
        process.exit(1);
    }
};

module.exports = { sequelize, connectDB };
```

### 4.5 Architecture des Controllers
Les controllers suivent le pattern **Service-Controller** :

**Exemple : produitController.js**
```javascript
const produitService = require('../services/produitService');

class ProduitController {
  async obtenirTousProduits(req, res) {
    try {
      const options = {
        page: req.query.page,
        limit: req.query.limit,
        categorie: req.query.categorie,
        type: req.query.type,
        prixMin: req.query.prixMin,
        prixMax: req.query.prixMax,
        recherche: req.query.recherche
      };

      const resultat = await produitService.obtenirTousProduits(options);
      res.json(resultat);
    } catch (error) {
      console.error('❌ Erreur controller:', error);
      res.status(500).json({ 
        message: 'Erreur lors de la récupération des produits',
        error: error.message 
      });
    }
  }

  async obtenirProduitParId(req, res) {
    try {
      const produit = await produitService.obtenirProduitParId(req.params.id);
      res.json(produit);
    } catch (error) {
      if (error.message === 'Produit introuvable') {
        return res.status(404).json({ message: error.message });
      }
      res.status(500).json({ message: error.message });
    }
  }
}

module.exports = new ProduitController();
```

**Avantages** :
- Séparation de la logique métier (service) et de la gestion HTTP (controller)
- Facilite les tests unitaires
- Réutilisabilité du code

### 4.6 Scripts NPM Disponibles
```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "NODE_ENV=development nodemon server.js",
    "prod": "NODE_ENV=production node server.js",
    "dev-windows": "set NODE_ENV=development&& nodemon server.js",
    "prod-windows": "set NODE_ENV=production&& node server.js",
    "db:reset": "NODE_ENV=development node -e \"require('./src/config/database').connectDB()\"",
    "db:create-admin": "node -e \"require('./src/config/database').creerAdminParDefaut()\"",
    "test": "NODE_ENV=test jest",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix"
  }
}
```

---

## 5. Frontend - Flutter

### 5.1 Structure du Projet Frontend
```
frontend/
├── lib/
│   ├── main.dart                 # Point d'entrée application
│   ├── routes.dart               # Configuration des routes
│   ├── ecrans/                   # Écrans de l'application
│   │   ├── Accueil.dart
│   │   ├── PageCatalogue.dart
│   │   ├── Panier.dart
│   │   ├── Favoris.dart
│   │   ├── ProfilUtilisateur.dart
│   │   ├── Parametres.dart
│   │   ├── authentification/     # Écrans auth
│   │   │   ├── Connexion.dart
│   │   │   └── Inscription.dart
│   │   ├── annonces/             # Écrans annonces
│   │   ├── message/              # Écrans messagerie
│   │   └── administration/       # Écrans admin
│   ├── services/                 # Services API
│   │   ├── api.dart
│   │   ├── authService.dart
│   │   ├── produitService.dart
│   │   ├── serviceService.dart
│   │   ├── annonceService.dart
│   │   ├── panierService.dart
│   │   ├── messagerieService.dart
│   │   └── utilisateurService.dart
│   ├── models/                   # Modèles de données
│   │   ├── Utilisateur.dart
│   │   ├── Produit.dart
│   │   ├── Service.dart
│   │   ├── Annonce.dart
│   │   └── ... (autres modèles)
│   ├── composants/               # Composants réutilisables
│   │   ├── CarteProduit.dart
│   │   ├── CarteService.dart
│   │   └── ... (autres composants)
│   ├── contexte/                 # State management
│   ├── navigation/               # Navigation
│   └── utils/                    # Utilitaires
├── assets/
│   └── data/                     # Données statiques
│       ├── produits.json
│       └── services.json
├── test/                         # Tests
├── pubspec.yaml                  # Dépendances Flutter
└── README.md
```

### 5.2 Point d'Entrée (main.dart)
```dart
import 'package:flutter/material.dart';
import 'routes.dart';

void main() {
  runApp(MonApp());
}

class MonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plateforme Échange',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: getRoutes(),
    );
  }
}
```

### 5.3 Service d'Authentification (authService.dart)
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/utilisateur.dart';
import 'package:flutter/foundation.dart';

class AuthResponse {
  final Utilisateur? utilisateur;
  final String? token;
  final String? error;

  AuthResponse({this.utilisateur, this.token, this.error});
}

class AuthService {
  static final String _baseUrl = kIsWeb
      ? 'http://localhost:3000/api/auth'
      : 'http://10.0.2.2:3000/api/auth';

  static const String _tokenKey = 'token';
  static const String _roleKey = 'user_role';

  // Sauvegarde du token après connexion
  Future<void> _saveAuthData(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
  }

  // Récupération du token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Récupération du rôle
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Inscription
  Future<AuthResponse> inscription(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('\$_baseUrl/inscription'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final utilisateur = Utilisateur.fromJson(data['utilisateur']);
        final token = data['token'];
        
        await _saveAuthData(token, utilisateur.role);
        return AuthResponse(utilisateur: utilisateur, token: token);
      } else {
        final error = json.decode(response.body)['message'];
        return AuthResponse(error: error);
      }
    } catch (e) {
      return AuthResponse(error: 'Erreur réseau: \$e');
    }
  }

  // Connexion
  Future<AuthResponse> connexion(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('\$_baseUrl/connexion'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'mot_de_passe': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final utilisateur = Utilisateur.fromJson(data['utilisateur']);
        final token = data['token'];
        
        await _saveAuthData(token, utilisateur.role);
        return AuthResponse(utilisateur: utilisateur, token: token);
      } else {
        final error = json.decode(response.body)['message'];
        return AuthResponse(error: error);
      }
    } catch (e) {
      return AuthResponse(error: 'Erreur réseau: \$e');
    }
  }

  // Déconnexion
  Future<void> deconnexion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }
}
```

### 5.4 Modèles de Données
**Exemple : Produit.dart**
```dart
class Produit {
  final int id;
  final String titre;
  final String description;
  final double prix;
  final String categorie;
  final String? imageUrl;

  Produit({
    required this.id,
    required this.titre,
    required this.description,
    required this.prix,
    required this.categorie,
    this.imageUrl,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      prix: json['prix'].toDouble(),
      categorie: json['categorie'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'prix': prix,
      'categorie': categorie,
      'imageUrl': imageUrl,
    };
  }
}
```

### 5.5 Gestion des Requêtes HTTP Authentifiées
Toutes les requêtes authentifiées incluent le token JWT dans les headers :

```dart
Future<http.Response> _makeAuthenticatedRequest(String endpoint) async {
  final token = await authService.getToken();
  
  if (token == null) {
    throw Exception('Non authentifié');
  }

  return await http.get(
    Uri.parse('\$baseUrl\$endpoint'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer \$token',
    },
  );
}
```

---

## 6. Base de Données

### 6.1 Choix de SQLite
**Raisons du choix** :
- Légèreté : pas de serveur de base de données à gérer
- Facilité de déploiement : fichier unique
- Performance suffisante pour une application de taille moyenne
- Facilité de backup (simple copie de fichier)
- Idéal pour le développement et le prototypage

### 6.2 Schéma de Base de Données

#### Modèle Utilisateur
```javascript
const Utilisateur = sequelize.define('Utilisateur', {
    prenom: { type: DataTypes.STRING, allowNull: false },
    nom: { type: DataTypes.STRING, allowNull: false },
    email: { type: DataTypes.STRING, allowNull: false, unique: true },
    mot_de_passe: { type: DataTypes.STRING, allowNull: false },
    numero_de_telephone: { type: DataTypes.STRING, allowNull: true },
    date_inscription: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    reputation: { type: DataTypes.FLOAT, defaultValue: 0.0 },
    id_adresse_fixe: { 
        type: DataTypes.INTEGER, 
        references: { model: Adresse, key: 'id' }
    },
    etat: { type: DataTypes.STRING, defaultValue: 'Actif' },
    role: { 
        type: DataTypes.ENUM('utilisateur', 'admin', 'moderateur'),
        defaultValue: 'utilisateur' 
    }
}, { timestamps: false });
```

#### Modèle Annonce
```javascript
const Annonce = sequelize.define('Annonce', {
    titre: { type: DataTypes.STRING(255), allowNull: false },
    description: { type: DataTypes.TEXT, allowNull: true },
    prix: { type: DataTypes.FLOAT, allowNull: false },
    date_publication: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    statut_annonce: { type: DataTypes.STRING(50), defaultValue: 'Active' },
    id_utilisateur: { 
        type: DataTypes.INTEGER,
        references: { model: Utilisateur, key: 'id' }
    },
    id_adresse: { 
        type: DataTypes.INTEGER,
        references: { model: Adresse, key: 'id' }
    }
}, { timestamps: false });
```

#### Modèle Produit
```javascript
const Produit = sequelize.define('Produit', {
    etat: { type: DataTypes.STRING(50), allowNull: false },
    num: { type: DataTypes.INTEGER, allowNull: true },
    id_annonce: { 
        type: DataTypes.INTEGER,
        unique: true,
        references: { model: Annonce, key: 'id' }
    },
    id_type: { 
        type: DataTypes.INTEGER,
        references: { model: TypeProduit, key: 'id' }
    }
}, { timestamps: false });
```

#### Modèle Service
```javascript
const Service = sequelize.define('Service', {
    type_service: { type: DataTypes.STRING(100), allowNull: false },
    disponibilite: { type: DataTypes.STRING(50), allowNull: false },
    num: { type: DataTypes.INTEGER, allowNull: true },
    id_annonce: { 
        type: DataTypes.INTEGER,
        unique: true,
        references: { model: Annonce, key: 'id' }
    },
    id_type: { 
        type: DataTypes.INTEGER,
        references: { model: TypeService, key: 'id' }
    }
}, { timestamps: false });
```

### 6.3 Relations Entre Tables

**Diagramme des Relations** :
```
Utilisateur (1) ──┬── (N) Annonce
                  │
                  ├── (N) Message (émetteur)
                  │
                  └── (N) Message (destinataire)

Annonce (1) ──┬── (1) Produit
              │
              └── (1) Service

Produit (N) ──── (1) TypeProduit
Service (N) ──── (1) TypeService

Annonce (N) ──── (1) Adresse

TypeProduit (N) ──── (1) CategorieProduit
TypeService (N) ──── (1) CategorieService
```

**Relations Sequelize** :
```javascript
// Utilisateur ↔ Annonce
Utilisateur.hasMany(Annonce, { foreignKey: 'id_utilisateur', as: 'annonces' });
Annonce.belongsTo(Utilisateur, { foreignKey: 'id_utilisateur', as: 'vendeur' });

// Annonce ↔ Produit (1:1)
Annonce.hasOne(Produit, { foreignKey: 'id_annonce', as: 'produit' });
Produit.belongsTo(Annonce, { foreignKey: 'id_annonce', as: 'annonce' });

// Annonce ↔ Service (1:1)
Annonce.hasOne(Service, { foreignKey: 'id_annonce', as: 'service' });
Service.belongsTo(Annonce, { foreignKey: 'id_annonce', as: 'annonce' });

// Produit ↔ TypeProduit
TypeProduit.hasMany(Produit, { foreignKey: 'id_type', as: 'produits' });
Produit.belongsTo(TypeProduit, { foreignKey: 'id_type', as: 'type' });
```

---

## 7. API REST

### 7.1 Structure des Endpoints

#### Authentification (`/api/auth`)
| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| POST | `/inscription` | Créer un compte utilisateur | Non |
| POST | `/connexion` | Se connecter | Non |

#### Utilisateurs (`/api/user`)
| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/profil` | Récupérer profil utilisateur | Oui |
| PUT | `/profil` | Modifier profil utilisateur | Oui |
| GET | `/:id` | Récupérer un utilisateur par ID | Oui |

#### Produits (`/api/produits`)
| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/` | Liste tous les produits | Non |
| GET | `/:id` | Détails d'un produit | Non |
| POST | `/` | Créer un produit | Oui |
| PUT | `/:id` | Modifier un produit | Oui |
| DELETE | `/:id` | Supprimer un produit | Oui |

#### Services (`/api/services`)
| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/` | Liste tous les services | Non |
| GET | `/:id` | Détails d'un service | Non |
| POST | `/` | Créer un service | Oui |
| PUT | `/:id` | Modifier un service | Oui |
| DELETE | `/:id` | Supprimer un service | Oui |

#### Annonces (`/api/annonces`)
| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/` | Liste toutes les annonces | Non |
| GET | `/:id` | Détails d'une annonce | Non |
| GET | `/utilisateur/:id` | Annonces d'un utilisateur | Oui |
| POST | `/` | Créer une annonce | Oui |
| PUT | `/:id` | Modifier une annonce | Oui |
| DELETE | `/:id` | Supprimer une annonce | Oui |

#### Panier (`/api/panier`)
| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/` | Récupérer le panier | Oui |
| POST | `/ajouter` | Ajouter au panier | Oui |
| PUT | `/modifier/:id` | Modifier quantité | Oui |
| DELETE | `/supprimer/:id` | Retirer du panier | Oui |

#### Administration (`/api/admin`)
| Méthode | Endpoint | Description | Auth | Rôle |
|---------|----------|-------------|------|------|
| GET | `/utilisateurs` | Liste utilisateurs | Oui | Admin |
| PUT | `/utilisateurs/:id/statut` | Modifier statut | Oui | Admin |
| DELETE | `/utilisateurs/:id` | Supprimer utilisateur | Oui | Admin |
| GET | `/annonces` | Liste annonces | Oui | Admin |
| PUT | `/annonces/:id/statut` | Modifier statut annonce | Oui | Admin |
| DELETE | `/annonces/:id` | Supprimer annonce | Oui | Admin |

### 7.2 Format des Requêtes et Réponses

#### Exemple : Inscription
**Requête POST /api/auth/inscription**
```json
{
  "nom": "Dupont",
  "prenom": "Jean",
  "email": "jean.dupont@email.com",
  "mot_de_passe": "motdepasse123",
  "numero_de_telephone": "0123456789",
  "adresse_fixe": {
    "rue": "123 Rue Principale",
    "quartier": "Centre-Ville",
    "commune": "Paris"
  }
}
```

**Réponse (201 Created)**
```json
{
  "message": "Inscription réussie",
  "utilisateur": {
    "id": 1,
    "nom": "Dupont",
    "prenom": "Jean",
    "email": "jean.dupont@email.com",
    "role": "utilisateur",
    "reputation": 0.0,
    "date_inscription": "2024-11-12T22:30:00.000Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Exemple : Récupération des Produits
**Requête GET /api/produits?page=1&limit=20&categorie=Electronique**

**Réponse (200 OK)**
```json
{
  "produits": [
    {
      "id": 1,
      "titre": "Smartphone XYZ",
      "description": "Dernier modèle...",
      "prix": 599.99,
      "etat": "Neuf",
      "annonce": {
        "id": 1,
        "statut_annonce": "Active",
        "date_publication": "2024-11-10T10:00:00.000Z",
        "vendeur": {
          "id": 2,
          "prenom": "Marie",
          "nom": "Martin",
          "reputation": 4.5
        }
      },
      "type": {
        "nom": "Téléphones",
        "categorie": {
          "nom": "Electronique"
        }
      },
      "photos": [
        { "url": "/uploads/photo1.jpg" }
      ]
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3
  }
}
```

### 7.3 Gestion des Erreurs
Format standard des réponses d'erreur :
```json
{
  "message": "Description de l'erreur",
  "error": "Détails techniques (optionnel)"
}
```

**Codes HTTP utilisés** :
- `200` : Succès
- `201` : Ressource créée
- `400` : Mauvaise requête
- `401` : Non authentifié
- `403` : Accès interdit
- `404` : Ressource non trouvée
- `409` : Conflit (ex: email déjà utilisé)
- `500` : Erreur serveur

---

## 8. Authentification et Sécurité

### 8.1 JWT (JSON Web Tokens)

#### Génération du Token
```javascript
const jwt = require('jsonwebtoken');

const genererToken = (idUtilisateur) => {
    return jwt.sign(
        { idUtilisateur }, 
        process.env.JWT_SECRET, 
        { expiresIn: '1d' }
    );
};
```

#### Middleware d'Authentification
```javascript
const authentifier = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    
    if (!authHeader) {
        return res.status(401).json({ message: 'Token manquant' });
    }

    if (!authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Format invalide' });
    }
    
    const token = authHeader.substring(7);
    
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.idUtilisateur = decoded.idUtilisateur;
        next();
    } catch (error) {
        return res.status(403).json({ message: 'Token invalide ou expiré' });
    }
};
```

### 8.2 Hachage des Mots de Passe
```javascript
const bcrypt = require('bcrypt');
const NOMBRE_CYCLES_HACHAGE = 10;

// Lors de l'inscription
const motDePasseHache = await bcrypt.hash(mot_de_passe, NOMBRE_CYCLES_HACHAGE);

// Lors de la connexion
const motDePasseValide = await bcrypt.compare(mot_de_passe, utilisateur.mot_de_passe);
```

### 8.3 Vérification des Rôles
```javascript
const verifierAdmin = (req, res, next) => {
    if (!req.utilisateur) {
        return res.status(401).json({ message: 'Non authentifié' });
    }

    if (req.utilisateur.role !== 'admin') {
        return res.status(403).json({ 
            message: 'Accès refusé. Droits administrateur requis.' 
        });
    }

    next();
};

// Utilisation
router.get('/admin/utilisateurs', authentifier, verifierAdmin, controller.listUsers);
```

### 8.4 CORS (Cross-Origin Resource Sharing)
```javascript
const cors = require('cors');

app.use(cors({
    origin: process.env.FRONTEND_URL || '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
```

### 8.5 Validation des Données
Toutes les entrées utilisateur sont validées :
```javascript
const inscription = async (req, res) => {
    const { nom, prenom, email, mot_de_passe, adresse_fixe } = req.body;

    // Validation
    if (!email || !mot_de_passe || !nom || !prenom) {
        return res.status(400).json({ 
            message: 'Données manquantes pour l\'inscription.' 
        });
    }

    // Vérification email unique
    const utilisateurExistant = await utilisateurService.trouverUtilisateurParEmail(email);
    if (utilisateurExistant) {
        return res.status(409).json({ 
            message: 'Cet email est déjà utilisé.' 
        });
    }

    // ...
};
```

### 8.6 Sécurité des Fichiers Uploadés
```javascript
const multer = require('multer');

const fileFilter = (req, file, cb) => {
    const allowedMimetypes = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp'
    ];

    if (allowedMimetypes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error('Seules les images sont autorisées'), false);
    }
};

const upload = multer({ 
    storage, 
    fileFilter, 
    limits: { fileSize: 5 * 1024 * 1024 } // 5 Mo max
});
```

---

## 9. Fonctionnalités Principales

### 9.1 Système d'Authentification
**Inscription** :
1. Utilisateur fournit ses informations
2. Validation des données
3. Vérification de l'unicité de l'email
4. Hachage du mot de passe avec bcrypt
5. Création de l'utilisateur en base
6. Génération du token JWT
7. Retour du token et des informations utilisateur

**Connexion** :
1. Utilisateur fournit email et mot de passe
2. Recherche de l'utilisateur par email
3. Comparaison du mot de passe haché
4. Génération du token JWT
5. Retour du token et des informations utilisateur

### 9.2 Gestion des Annonces
**Création d'une Annonce** :
1. Utilisateur authentifié remplit le formulaire
2. Upload des photos (via Multer)
3. Validation des données
4. Création de l'annonce en base
5. Création du produit ou service associé
6. Enregistrement des photos

**Modification d'une Annonce** :
1. Vérification de la propriété (utilisateur = créateur)
2. Mise à jour des champs modifiés
3. Gestion des nouvelles photos

**Suppression d'une Annonce** :
1. Vérification de la propriété ou rôle admin
2. Suppression en cascade (photos, produit/service)
3. Suppression de l'annonce

### 9.3 Système de Panier
**Fonctionnalités** :
- Ajouter un produit/service au panier
- Modifier la quantité
- Retirer un élément
- Visualiser le total
- Passer commande

**Implémentation** :
```javascript
class PanierService {
  async ajouterAuPanier(idUtilisateur, idAnnonce, quantite) {
    // Vérifier si l'article existe déjà
    let ligneCommande = await LigneCommande.findOne({
      where: { id_utilisateur: idUtilisateur, id_annonce: idAnnonce }
    });

    if (ligneCommande) {
      // Mettre à jour la quantité
      ligneCommande.quantite += quantite;
      await ligneCommande.save();
    } else {
      // Créer nouvelle ligne
      ligneCommande = await LigneCommande.create({
        id_utilisateur: idUtilisateur,
        id_annonce: idAnnonce,
        quantite,
        date_ajout: new Date()
      });
    }

    return ligneCommande;
  }

  async obtenirPanier(idUtilisateur) {
    const lignes = await LigneCommande.findAll({
      where: { id_utilisateur: idUtilisateur },
      include: [
        {
          model: Annonce,
          as: 'annonce',
          include: ['photos', 'vendeur']
        }
      ]
    });

    const total = lignes.reduce((sum, ligne) => {
      return sum + (ligne.quantite * ligne.annonce.prix);
    }, 0);

    return { lignes, total };
  }
}
```

### 9.4 Système de Messagerie
**Fonctionnalités** :
- Envoyer un message à un vendeur
- Consulter ses conversations
- Marquer les messages comme lus

**Structure des Messages** :
```javascript
const Message = sequelize.define('Message', {
    contenu: { type: DataTypes.TEXT, allowNull: false },
    date_envoi: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    lu: { type: DataTypes.BOOLEAN, defaultValue: false },
    id_emetteur: { 
        type: DataTypes.INTEGER,
        references: { model: Utilisateur, key: 'id' }
    },
    id_destinataire: { 
        type: DataTypes.INTEGER,
        references: { model: Utilisateur, key: 'id' }
    }
});
```

### 9.5 Panneau d'Administration
**Fonctionnalités Admin** :
- Gestion des utilisateurs (liste, suspension, suppression)
- Gestion des annonces (validation, suppression)
- Modération des messages
- Statistiques de la plateforme

**Protection** :
- Middleware `verifierAdmin` sur toutes les routes admin
- Vérification du rôle `admin` dans le token JWT

### 9.6 Système de Notation
**Fonctionnalités** :
- Noter un vendeur après une transaction
- Calcul de la réputation moyenne
- Affichage des notes sur le profil

---

## 10. Gestion des Fichiers

### 10.1 Configuration Multer
```javascript
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => {
        const ext = path.extname(file.originalname);
        const filename = `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
        cb(null, filename);
    }
});

const upload = multer({ 
    storage, 
    fileFilter, 
    limits: { fileSize: 5 * 1024 * 1024 } 
});
```

### 10.2 Upload depuis Flutter
```dart
Future<String?> uploadImage(File image) async {
  try {
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('$baseUrl/api/produits/upload')
    );
    
    // Ajouter le token d'authentification
    final token = await authService.getToken();
    request.headers['Authorization'] = 'Bearer $token';
    
    // Ajouter le fichier
    request.files.add(
      await http.MultipartFile.fromPath('photo', image.path)
    );
    
    var response = await request.send();
    
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      return jsonData['url'];
    }
    
    return null;
  } catch (e) {
    print('Erreur upload: $e');
    return null;
  }
}
```

### 10.3 Servir les Fichiers Statiques
```javascript
// Dans app.js
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));
```

**Accès** :
- URL : `http://localhost:3000/uploads/1699800000-123456789.jpg`
- Utilisé dans les réponses API pour les URLs d'images

---

## 11. Tests et Déploiement

### 11.1 Tests Backend (Jest)
```javascript
// test/authController.test.js
const request = require('supertest');
const app = require('../src/app');

describe('Auth Controller', () => {
  test('POST /api/auth/inscription - succès', async () => {
    const response = await request(app)
      .post('/api/auth/inscription')
      .send({
        nom: 'Test',
        prenom: 'User',
        email: 'test@test.com',
        mot_de_passe: 'password123',
        adresse_fixe: { commune: 'Paris' }
      });

    expect(response.statusCode).toBe(201);
    expect(response.body).toHaveProperty('token');
    expect(response.body.utilisateur.email).toBe('test@test.com');
  });

  test('POST /api/auth/connexion - échec mot de passe', async () => {
    const response = await request(app)
      .post('/api/auth/connexion')
      .send({
        email: 'test@test.com',
        mot_de_passe: 'wrongpassword'
      });

    expect(response.statusCode).toBe(401);
  });
});
```

**Lancer les tests** :
```bash
npm test
```

### 11.2 Tests Frontend (Flutter Test)
```dart
// test/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/authService.dart';

void main() {
  group('AuthService', () {
    test('inscription avec données valides', () async {
      final authService = AuthService();
      
      final response = await authService.inscription({
        'nom': 'Test',
        'prenom': 'User',
        'email': 'test@test.com',
        'mot_de_passe': 'password123',
        'adresse_fixe': {'commune': 'Paris'}
      });

      expect(response.utilisateur, isNotNull);
      expect(response.token, isNotNull);
      expect(response.error, isNull);
    });
  });
}
```

**Lancer les tests** :
```bash
flutter test
```

### 11.3 Linting
**Backend** :
```bash
npm run lint        # Vérifier le code
npm run lint:fix    # Corriger automatiquement
```

**Frontend** :
```bash
flutter analyze
```

### 11.4 Déploiement

#### Préparation du Backend
1. **Variables d'environnement** :
```env
NODE_ENV=production
PORT=3000
JWT_SECRET=votre_secret_fort_et_unique
DB_STORAGE=./database/busykin_db.sqlite
```

2. **Installation des dépendances** :
```bash
npm install --production
```

3. **Démarrage** :
```bash
npm run prod
```

#### Build Flutter
**Android** :
```bash
flutter build apk --release
```

**iOS** :
```bash
flutter build ios --release
```

**Web** :
```bash
flutter build web --release
```

### 11.5 Backup de la Base de Données
```bash
npm run db:backup
```
Crée une copie de `busykin_db.sqlite` avec horodatage.

---

## 12. Conclusion

### 12.1 Points Forts de l'Implémentation
✅ **Architecture moderne** : Séparation claire backend/frontend  
✅ **Sécurité** : JWT, bcrypt, validation des données  
✅ **Scalabilité** : Structure modulaire facilement extensible  
✅ **Maintenabilité** : Code organisé, commenté, suivant les bonnes pratiques  
✅ **Performance** : Optimisations des requêtes, pagination  
✅ **Multiplateforme** : Application Flutter pour Android, iOS, Web  

### 12.2 Améliorations Possibles
🔄 **Migration vers PostgreSQL/MySQL** pour production à grande échelle  
🔄 **Implémentation de WebSockets** pour messagerie temps réel  
🔄 **Système de cache** (Redis) pour améliorer les performances  
🔄 **Tests d'intégration** plus complets  
🔄 **CI/CD** pour automatiser les déploiements  
🔄 **Monitoring et logs** centralisés  
🔄 **Internationalisation** (i18n) pour support multilingue  

### 12.3 Technologies Acquises
- Développement d'API REST avec Node.js/Express
- ORM Sequelize et gestion de base de données
- Authentification JWT et sécurité web
- Développement mobile avec Flutter
- Architecture client-serveur
- Gestion d'état et communication HTTP
- Upload et gestion de fichiers
- Tests unitaires et intégration

---

## Annexes

### A. Variables d'Environnement (.env)
```env
# Configuration du Serveur
PORT=3000
NODE_ENV=development
JWT_SECRET=votre_secret_unique_et_complexe

# Configuration de la Base de Données
DB_DIALECT=sqlite
DB_STORAGE=./database/busykin_db.sqlite

# Admin par défaut
DEFAULT_ADMIN_EMAIL=admin@busykin.com
DEFAULT_ADMIN_PASSWORD=admin123
DEFAULT_ADMIN_FIRSTNAME=System
DEFAULT_ADMIN_LASTNAME=Admin

# Frontend (optionnel)
FRONTEND_URL=http://localhost:8080
```

### B. Commandes Utiles

**Backend** :
```bash
# Développement
npm run dev              # Démarrer en mode dev avec nodemon

# Production
npm run prod             # Démarrer en mode production

# Base de données
npm run db:reset         # Réinitialiser la DB (dev)
npm run db:create-admin  # Créer admin par défaut
npm run db:backup        # Backup de la DB

# Tests et qualité
npm test                 # Lancer les tests
npm run lint             # Vérifier le code
npm run lint:fix         # Corriger le code
```

**Frontend** :
```bash
# Développement
flutter run              # Lancer l'app en mode dev

# Build
flutter build apk        # Build Android
flutter build ios        # Build iOS
flutter build web        # Build Web

# Tests et qualité
flutter test             # Lancer les tests
flutter analyze          # Analyser le code
flutter doctor           # Vérifier l'installation
```

### C. Ressources et Références
- **Documentation Express** : https://expressjs.com/
- **Documentation Sequelize** : https://sequelize.org/
- **Documentation Flutter** : https://flutter.dev/
- **Documentation JWT** : https://jwt.io/
- **Node.js Best Practices** : https://github.com/goldbergyoni/nodebestpractices
- **Flutter Architecture Samples** : https://github.com/brianegan/flutter_architecture_samples

---

**Document rédigé le** : 12 Novembre 2024  
**Version** : 1.0  
**Projet** : BusyKin - Plateforme de Marketplace  
**Auteur** : Documentation technique du projet tutoré
