# Documentation d'Implémentation - Projet BusyKin
## Version Condensée (5 Pages)

---

## 1. Introduction et Architecture du Projet

### 1.1 Contexte et Objectifs
BusyKin est une plateforme de marketplace mobile permettant aux utilisateurs d'échanger des produits et de proposer/rechercher des services. Le projet implémente une architecture client-serveur moderne avec une séparation complète entre le backend (API REST) et le frontend (application mobile multiplateforme).

**Objectifs principaux :**
- Créer une plateforme sécurisée d'échange de biens et services
- Permettre la gestion complète d'annonces (produits et services)
- Implémenter un système de messagerie entre utilisateurs
- Fournir un panneau d'administration pour la modération
- Assurer une expérience utilisateur fluide sur mobile

### 1.2 Architecture Technique Globale

```
┌─────────────────┐      REST API/JSON      ┌──────────────────┐
│  Application    │ ◄──────────────────────► │   Serveur API    │
│  Flutter        │      HTTP/HTTPS          │   Node.js        │
│  (Mobile)       │      JWT Auth            │   Express        │
└─────────────────┘                          └──────────────────┘
     Android/iOS                                      │
                                                      ▼
                                              ┌──────────────────┐
                                              │  Base de Données │
                                              │     SQLite       │
                                              │   (Sequelize)    │
                                              └──────────────────┘
```

**Principes architecturaux :**
- **Séparation des responsabilités** : Backend (logique métier) / Frontend (présentation)
- **Communication RESTful** : Échange de données via JSON
- **Authentification stateless** : Tokens JWT pour sécuriser les requêtes
- **Architecture modulaire** : Code organisé en couches (routes, controllers, services, models)

### 1.3 Technologies Utilisées

**Backend (Serveur API):**
- **Node.js** (≥18.0.0) - Runtime JavaScript côté serveur
- **Express** (5.1.0) - Framework web pour API REST
- **Sequelize** (6.37.7) - ORM pour gestion base de données
- **SQLite3** (5.1.7) - Base de données relationnelle légère
- **JWT** (9.0.2) - Authentification par tokens
- **Bcrypt** (6.0.0) - Hachage sécurisé des mots de passe
- **Multer** - Gestion des uploads de fichiers
- **CORS** (2.8.5) - Gestion cross-origin

**Frontend (Application Mobile):**
- **Flutter** - Framework mobile multiplateforme (Android/iOS)
- **Dart** (^3.8.1) - Langage de programmation
- **http** (^1.5.0) - Client HTTP pour appels API
- **shared_preferences** (^2.5.3) - Stockage local des tokens
- **file_picker** (^10.3.3) - Sélection de fichiers
- **image_picker** (^1.2.0) - Sélection d'images

---

## 2. Implémentation Backend - API REST Node.js/Express

### 2.1 Structure et Organisation du Code

**Architecture des dossiers :**
```
backend/
├── src/
│   ├── app.js                  # Configuration Express
│   ├── config/
│   │   ├── database.js         # Connexion Sequelize
│   │   └── express.js          # Middlewares
│   ├── controllers/            # Logique HTTP (req/res)
│   │   ├── authController.js
│   │   ├── produitController.js
│   │   ├── serviceController.js
│   │   ├── annonceController.js
│   │   └── panierController.js
│   ├── models/                 # Modèles Sequelize (DB)
│   │   ├── Utilisateur.js
│   │   ├── Annonce.js
│   │   ├── Produit.js
│   │   ├── Service.js
│   │   └── Message.js
│   ├── routes/                 # Définition endpoints
│   │   ├── authRoutes.js
│   │   ├── produitRoutes.js
│   │   └── adminRoutes.js
│   ├── services/               # Logique métier
│   │   ├── utilisateurService.js
│   │   └── produitService.js
│   └── middlewares/            # Middlewares personnalisés
│       ├── authMiddleware.js   # Vérification JWT
│       └── upload.js           # Gestion uploads
├── database/                   # Fichier SQLite
└── server.js                   # Point d'entrée
```

**Pattern MVC adapté :**
- **Routes** : Définissent les endpoints et associent aux controllers
- **Controllers** : Gèrent les requêtes/réponses HTTP
- **Services** : Contiennent la logique métier réutilisable
- **Models** : Définissent la structure des données

### 2.2 Modèles de Données (Base de Données)

**Modèle Utilisateur :**
```javascript
const Utilisateur = sequelize.define('Utilisateur', {
    prenom: { type: DataTypes.STRING, allowNull: false },
    nom: { type: DataTypes.STRING, allowNull: false },
    email: { type: DataTypes.STRING, allowNull: false, unique: true },
    mot_de_passe: { type: DataTypes.STRING, allowNull: false },
    numero_de_telephone: { type: DataTypes.STRING },
    date_inscription: { type: DataTypes.DATE, defaultValue: NOW },
    reputation: { type: DataTypes.FLOAT, defaultValue: 0.0 },
    role: { 
        type: DataTypes.ENUM('utilisateur', 'admin', 'moderateur'),
        defaultValue: 'utilisateur' 
    },
    etat: { type: DataTypes.STRING, defaultValue: 'Actif' }
});
```

**Modèle Annonce :**
```javascript
const Annonce = sequelize.define('Annonce', {
    titre: { type: DataTypes.STRING(255), allowNull: false },
    description: { type: DataTypes.TEXT },
    prix: { type: DataTypes.FLOAT, allowNull: false },
    date_publication: { type: DataTypes.DATE, defaultValue: NOW },
    statut_annonce: { type: DataTypes.STRING(50), defaultValue: 'Active' },
    id_utilisateur: { type: DataTypes.INTEGER, references: Utilisateur },
    id_adresse: { type: DataTypes.INTEGER, references: Adresse }
});
```

**Relations entre entités :**
- Un **Utilisateur** peut créer plusieurs **Annonces** (1:N)
- Une **Annonce** peut être un **Produit** OU un **Service** (1:1)
- Un **Produit/Service** appartient à une **Catégorie** et un **Type** (N:1)
- Les **Messages** relient deux **Utilisateurs** (émetteur/destinataire)

### 2.3 API REST - Endpoints Implémentés

**Authentification (`/api/auth`) :**
| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| POST | `/inscription` | Créer un compte utilisateur | Non |
| POST | `/connexion` | Se connecter et obtenir JWT | Non |

**Gestion Produits (`/api/produits`) :**
| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/` | Liste tous les produits avec pagination | Non |
| GET | `/:id` | Détails d'un produit spécifique | Non |
| POST | `/` | Créer une annonce produit | Oui |
| PUT | `/:id` | Modifier un produit existant | Oui |
| DELETE | `/:id` | Supprimer un produit | Oui |

**Gestion Services (`/api/services`) :**
- Endpoints similaires aux produits avec spécificités services

**Gestion Annonces (`/api/annonces`) :**
| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/` | Liste toutes les annonces | Non |
| GET | `/:id` | Détails d'une annonce | Non |
| GET | `/utilisateur/:id` | Annonces d'un utilisateur | Oui |
| POST | `/` | Créer une annonce | Oui |
| PUT | `/:id` | Modifier une annonce | Oui |
| DELETE | `/:id` | Supprimer une annonce | Oui |

**Panier (`/api/panier`) :**
| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| GET | `/` | Récupérer le panier utilisateur | Oui |
| POST | `/ajouter` | Ajouter article au panier | Oui |
| PUT | `/modifier/:id` | Modifier quantité | Oui |
| DELETE | `/supprimer/:id` | Retirer du panier | Oui |

**Administration (`/api/admin`) :**
| Méthode | Endpoint | Description | Auth | Rôle |
|---------|----------|-------------|------|------|
| GET | `/utilisateurs` | Liste utilisateurs | Oui | Admin |
| PUT | `/utilisateurs/:id/statut` | Modifier statut user | Oui | Admin |
| DELETE | `/utilisateurs/:id` | Supprimer utilisateur | Oui | Admin |

### 2.4 Sécurité et Authentification

**Implémentation JWT :**
```javascript
// Génération du token lors de la connexion
const genererToken = (idUtilisateur) => {
    return jwt.sign(
        { idUtilisateur }, 
        process.env.JWT_SECRET, 
        { expiresIn: '1d' }
    );
};

// Middleware de vérification
const authentifier = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Token manquant' });
    }
    
    const token = authHeader.substring(7);
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.idUtilisateur = decoded.idUtilisateur;
        next();
    } catch (error) {
        return res.status(403).json({ message: 'Token invalide' });
    }
};
```

**Hachage des mots de passe :**
```javascript
// À l'inscription
const motDePasseHache = await bcrypt.hash(mot_de_passe, 10);

// À la connexion
const motDePasseValide = await bcrypt.compare(
    mot_de_passe, 
    utilisateur.mot_de_passe
);
```

**Sécurité des uploads :**
```javascript
const fileFilter = (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    if (allowedTypes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error('Type de fichier non autorisé'), false);
    }
};

const upload = multer({ 
    storage, 
    fileFilter, 
    limits: { fileSize: 5 * 1024 * 1024 } // 5 Mo max
});
```

---

## 3. Implémentation Frontend - Application Flutter

### 3.1 Structure de l'Application Mobile

**Organisation des dossiers :**
```
lib/
├── main.dart                   # Point d'entrée
├── routes.dart                 # Configuration routes
├── ecrans/                     # Pages de l'application
│   ├── Accueil.dart
│   ├── PageCatalogue.dart
│   ├── Panier.dart
│   ├── authentification/
│   │   ├── Connexion.dart
│   │   └── Inscription.dart
│   ├── annonces/
│   │   ├── CreerAnnonce.dart
│   │   └── DetailAnnonce.dart
│   └── administration/
├── services/                   # Services API
│   ├── authService.dart
│   ├── produitService.dart
│   ├── serviceService.dart
│   └── panierService.dart
├── models/                     # Modèles de données
│   ├── Utilisateur.dart
│   ├── Produit.dart
│   └── Annonce.dart
└── composants/                 # Widgets réutilisables
    ├── CarteProduit.dart
    └── CarteService.dart
```

### 3.2 Services de Communication API

**Service d'Authentification :**
```dart
class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api/auth';
  static const String _tokenKey = 'token';

  // Inscription
  Future<AuthResponse> inscription(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/inscription'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      await _saveToken(data['token']);
      return AuthResponse(
        utilisateur: Utilisateur.fromJson(data['utilisateur']),
        token: data['token']
      );
    }
    return AuthResponse(error: json.decode(response.body)['message']);
  }

  // Connexion
  Future<AuthResponse> connexion(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/connexion'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email, 
        'mot_de_passe': password
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data['token']);
      return AuthResponse(
        utilisateur: Utilisateur.fromJson(data['utilisateur']),
        token: data['token']
      );
    }
    return AuthResponse(error: 'Identifiants incorrects');
  }

  // Sauvegarde du token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
}
```

**Service Produits avec Authentification :**
```dart
class ProduitService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api/produits';

  Future<List<Produit>> obtenirProduits() async {
    final response = await http.get(Uri.parse(_baseUrl));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['produits'];
      return data.map((json) => Produit.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des produits');
  }

  Future<Produit> creerProduit(Map<String, dynamic> produitData) async {
    final token = await authService.getToken();
    
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '******',
      },
      body: json.encode(produitData),
    );

    if (response.statusCode == 201) {
      return Produit.fromJson(json.decode(response.body));
    }
    throw Exception('Erreur lors de la création du produit');
  }
}
```

### 3.3 Modèles de Données Flutter

**Classe Produit :**
```dart
class Produit {
  final int id;
  final String titre;
  final String description;
  final double prix;
  final String etat;
  final String? imageUrl;

  Produit({
    required this.id,
    required this.titre,
    required this.description,
    required this.prix,
    required this.etat,
    this.imageUrl,
  });

  // Désérialisation JSON
  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      prix: json['prix'].toDouble(),
      etat: json['etat'],
      imageUrl: json['imageUrl'],
    );
  }

  // Sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'prix': prix,
      'etat': etat,
      'imageUrl': imageUrl,
    };
  }
}
```

### 3.4 Navigation et Routage

**Configuration des routes :**
```dart
Map<String, WidgetBuilder> getRoutes() {
  return {
    '/': (context) => Accueil(),
    '/connexion': (context) => Connexion(),
    '/inscription': (context) => Inscription(),
    '/catalogue': (context) => PageCatalogue(),
    '/panier': (context) => Panier(),
    '/creer-annonce': (context) => CreerAnnonce(),
    '/detail-annonce': (context) => DetailAnnonce(),
    '/admin': (context) => PanneauAdmin(),
  };
}
```

---

## 4. Fonctionnalités Clés Implémentées

### 4.1 Système d'Authentification Complet

**Processus d'inscription :**
1. Utilisateur remplit formulaire (nom, prénom, email, mot de passe, adresse)
2. Frontend envoie données à `/api/auth/inscription`
3. Backend valide unicité email
4. Mot de passe haché avec bcrypt (10 cycles)
5. Création utilisateur en base de données
6. Génération token JWT
7. Retour token + données utilisateur au frontend
8. Stockage token localement (shared_preferences)

**Processus de connexion :**
1. Utilisateur saisit email et mot de passe
2. Frontend envoie à `/api/auth/connexion`
3. Backend recherche utilisateur par email
4. Comparaison mot de passe haché
5. Génération nouveau token JWT
6. Retour token + données utilisateur
7. Stockage token et redirection vers accueil

### 4.2 Gestion Complète des Annonces

**Création d'annonce (Produit ou Service) :**
```javascript
// Controller
async creerAnnonce(req, res) {
  // 1. Récupérer données formulaire + photos uploadées
  const { titre, description, prix, type } = req.body;
  const photos = req.files;
  
  // 2. Créer l'annonce
  const annonce = await Annonce.create({
    titre, description, prix,
    id_utilisateur: req.idUtilisateur,
    id_adresse: req.body.id_adresse
  });
  
  // 3. Créer produit ou service associé
  if (type === 'produit') {
    await Produit.create({
      etat: req.body.etat,
      id_annonce: annonce.id,
      id_type: req.body.id_type
    });
  }
  
  // 4. Enregistrer photos
  for (let photo of photos) {
    await PhotoProduit.create({
      url: `/uploads/${photo.filename}`,
      id_produit: produit.id
    });
  }
  
  res.status(201).json({ annonce, produit });
}
```

**Modification d'annonce :**
- Vérification que l'utilisateur est propriétaire
- Mise à jour des champs modifiés
- Gestion ajout/suppression de photos

**Suppression d'annonce :**
- Vérification propriété ou rôle admin
- Suppression cascade : photos, produit/service, annonce

### 4.3 Système de Panier

**Implémentation côté backend :**
```javascript
class PanierService {
  async ajouterAuPanier(idUtilisateur, idAnnonce, quantite) {
    // Vérifier si article déjà dans panier
    let ligne = await LigneCommande.findOne({
      where: { id_utilisateur: idUtilisateur, id_annonce: idAnnonce }
    });

    if (ligne) {
      // Augmenter quantité
      ligne.quantite += quantite;
      await ligne.save();
    } else {
      // Créer nouvelle ligne
      ligne = await LigneCommande.create({
        id_utilisateur: idUtilisateur,
        id_annonce: idAnnonce,
        quantite
      });
    }
    return ligne;
  }

  async obtenirPanier(idUtilisateur) {
    const lignes = await LigneCommande.findAll({
      where: { id_utilisateur: idUtilisateur },
      include: [{ model: Annonce, include: ['photos', 'vendeur'] }]
    });

    const total = lignes.reduce((sum, ligne) => 
      sum + (ligne.quantite * ligne.annonce.prix), 0
    );

    return { lignes, total };
  }
}
```

### 4.4 Messagerie Entre Utilisateurs

**Modèle Message :**
```javascript
const Message = sequelize.define('Message', {
    contenu: { type: DataTypes.TEXT, allowNull: false },
    date_envoi: { type: DataTypes.DATE, defaultValue: NOW },
    lu: { type: DataTypes.BOOLEAN, defaultValue: false },
    id_emetteur: { type: DataTypes.INTEGER, references: Utilisateur },
    id_destinataire: { type: DataTypes.INTEGER, references: Utilisateur }
});
```

**Fonctionnalités :**
- Envoyer message à un vendeur depuis l'annonce
- Consulter historique conversations
- Marquer messages comme lus
- Affichage en temps différé (polling)

### 4.5 Panneau d'Administration

**Middleware de vérification rôle admin :**
```javascript
const verifierAdmin = (req, res, next) => {
    if (!req.utilisateur) {
        return res.status(401).json({ message: 'Non authentifié' });
    }
    
    if (req.utilisateur.role !== 'admin') {
        return res.status(403).json({ 
            message: 'Accès refusé - Droits admin requis' 
        });
    }
    
    next();
};

// Utilisation
router.get('/admin/utilisateurs', 
    authentifier, 
    verifierAdmin, 
    adminController.listeUtilisateurs
);
```

**Fonctionnalités admin :**
- Liste et recherche utilisateurs
- Suspension/activation comptes
- Suppression utilisateurs
- Modération annonces (valider/rejeter)
- Statistiques plateforme (nombre users, annonces, transactions)

---

## 5. Points Forts et Perspectives

### 5.1 Points Forts de l'Implémentation

✅ **Architecture Moderne :**
- Séparation claire backend/frontend
- API REST respectant les standards
- Code modulaire et maintenable

✅ **Sécurité Robuste :**
- Authentification JWT avec expiration
- Mots de passe hachés avec bcrypt
- Validation des données entrantes
- Protection contre injections SQL (ORM)
- Gestion sécurisée des uploads

✅ **Expérience Utilisateur :**
- Application mobile native (Flutter)
- Interface intuitive et responsive
- Gestion d'état efficace
- Navigation fluide

✅ **Fonctionnalités Complètes :**
- Système d'authentification complet
- CRUD complet pour annonces
- Panier fonctionnel
- Messagerie entre utilisateurs
- Panneau administration

✅ **Scalabilité :**
- Architecture en couches extensible
- ORM facilitant migration DB
- Services réutilisables
- API documentée

### 5.2 Technologies Maîtrisées

Au cours de ce projet, les compétences suivantes ont été développées :

**Backend :**
- Développement API REST avec Node.js/Express
- Gestion base de données avec ORM Sequelize
- Authentification JWT et sécurité web
- Gestion uploads de fichiers
- Middleware et routing Express

**Frontend :**
- Développement mobile avec Flutter/Dart
- Communication HTTP et sérialisation JSON
- Gestion d'état et navigation
- Stockage local de données
- Upload de fichiers depuis mobile

**Architecture :**
- Pattern MVC adapté
- Architecture client-serveur
- Principes REST
- Séparation des responsabilités

### 5.3 Améliorations Futures Possibles

🔄 **Performance :**
- Mise en cache avec Redis
- Optimisation requêtes DB (eager loading)
- Compression des images uploadées
- Pagination côté serveur optimisée

🔄 **Fonctionnalités :**
- Notifications push en temps réel
- WebSockets pour chat instantané
- Système de paiement intégré
- Géolocalisation des annonces
- Système de notation amélioré
- Recherche avancée avec filtres

🔄 **Scalabilité :**
- Migration vers PostgreSQL/MySQL
- Microservices pour fonctionnalités critiques
- Load balancing
- CDN pour fichiers statiques

🔄 **Qualité :**
- Tests d'intégration complets
- CI/CD automatisé
- Monitoring et logging centralisés
- Documentation API avec Swagger

---

**Document rédigé le :** 14 Novembre 2024  
**Version :** Implémentation uniquement (5 pages)  
**Projet :** BusyKin - Plateforme de Marketplace  
**Technologies :** Node.js, Express, Flutter, SQLite, JWT, Bcrypt
