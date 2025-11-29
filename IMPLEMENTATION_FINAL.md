# Documentation d'Implémentation - Projet BusyKin

---

## 1. Architecture et Technologies du Projet

### Architecture Client-Serveur
Le projet BusyKin implémente une architecture client-serveur avec séparation complète du backend (API REST) et du frontend (application mobile). La communication s'effectue via protocole HTTP avec authentification par tokens JWT.

```
Application Mobile Flutter  ◄──► API REST Node.js/Express  ◄──► Base de Données SQLite
     (Client)                         (Serveur)                    (Sequelize ORM)
```

### Technologies Utilisées

**Backend:**
- Node.js 18+ - Runtime JavaScript côté serveur
- Express 5.1 - Framework web pour API REST
- Sequelize 6.37 - ORM pour gestion base de données
- SQLite3 5.1 - Base de données relationnelle
- JWT 9.0 - Authentification par tokens
- Bcrypt 6.0 - Hachage sécurisé des mots de passe
- Multer - Gestion des uploads de fichiers

**Frontend:**
- Flutter/Dart 3.8 - Framework mobile multiplateforme
- http 1.5 - Client HTTP pour appels API
- shared_preferences 2.5 - Stockage local des tokens
- file_picker 10.3 - Sélection de fichiers
- image_picker 1.2 - Sélection d'images

---

## 2. Implémentation du Backend

### Structure du Code Backend
```
backend/src/
├── controllers/     # Gestion des requêtes/réponses HTTP
├── models/         # Définition des modèles Sequelize
├── routes/         # Définition des endpoints API
├── services/       # Logique métier réutilisable
├── middlewares/    # Authentification et validation
└── config/         # Configuration DB et Express
```

### Modèles de Données
**Utilisateur:**
```javascript
const Utilisateur = sequelize.define('Utilisateur', {
    prenom: { type: DataTypes.STRING, allowNull: false },
    nom: { type: DataTypes.STRING, allowNull: false },
    email: { type: DataTypes.STRING, allowNull: false, unique: true },
    mot_de_passe: { type: DataTypes.STRING, allowNull: false },
    role: { type: DataTypes.ENUM('utilisateur', 'admin'), defaultValue: 'utilisateur' },
    reputation: { type: DataTypes.FLOAT, defaultValue: 0.0 },
    etat: { type: DataTypes.STRING, defaultValue: 'Actif' }
});
```

**Annonce:**
```javascript
const Annonce = sequelize.define('Annonce', {
    titre: { type: DataTypes.STRING(255), allowNull: false },
    description: { type: DataTypes.TEXT },
    prix: { type: DataTypes.FLOAT, allowNull: false },
    statut_annonce: { type: DataTypes.STRING(50), defaultValue: 'Active' },
    id_utilisateur: { type: DataTypes.INTEGER, references: Utilisateur },
    id_adresse: { type: DataTypes.INTEGER, references: Adresse }
});
```

### Endpoints API REST
**Authentification:**
- `POST /api/auth/inscription` - Création compte utilisateur
- `POST /api/auth/connexion` - Connexion et génération JWT

**Produits:**
- `GET /api/produits` - Liste tous les produits avec pagination
- `GET /api/produits/:id` - Détails d'un produit
- `POST /api/produits` - Créer un produit (auth requise)
- `PUT /api/produits/:id` - Modifier un produit (auth requise)
- `DELETE /api/produits/:id` - Supprimer un produit (auth requise)

**Services, Annonces, Panier, Administration:**
Endpoints similaires avec gestion CRUD complète

### Sécurité et Authentification
**Génération JWT:**
```javascript
const genererToken = (idUtilisateur) => {
    return jwt.sign({ idUtilisateur }, process.env.JWT_SECRET, { expiresIn: '1d' });
};
```

**Middleware d'authentification:**
```javascript
const authentifier = (req, res, next) => {
    const token = req.headers['authorization']?.substring(7); // Retire "Bearer "
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.idUtilisateur = decoded.idUtilisateur;
        next();
    } catch (error) {
        res.status(403).json({ message: 'Token invalide' });
    }
};
```

**Hachage des mots de passe:**
```javascript
// À l'inscription
const hash = await bcrypt.hash(mot_de_passe, 10);

// À la connexion
const valide = await bcrypt.compare(mot_de_passe, utilisateur.mot_de_passe);
```

---

## 3. Implémentation du Frontend

### Structure de l'Application Flutter
```
lib/
├── ecrans/          # Pages de l'application
│   ├── Accueil.dart
│   ├── authentification/
│   ├── annonces/
│   └── administration/
├── services/        # Communication avec l'API
│   ├── authService.dart
│   ├── produitService.dart
│   └── panierService.dart
├── models/          # Classes de données
│   ├── Utilisateur.dart
│   ├── Produit.dart
│   └── Annonce.dart
└── composants/      # Widgets réutilisables
```

### Services de Communication API
**Service d'authentification:**
```dart
class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:3000/api/auth';

  Future<AuthResponse> connexion(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/connexion'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'mot_de_passe': password}),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToken(data['token']);
      return AuthResponse(utilisateur: Utilisateur.fromJson(data['utilisateur']));
    }
    throw Exception('Connexion échouée');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
}
```

**Service Produits:**
```dart
class ProduitService {
  Future<List<Produit>> obtenirProduits() async {
    final response = await http.get(Uri.parse('$baseUrl/api/produits'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['produits'];
      return data.map((json) => Produit.fromJson(json)).toList();
    }
    throw Exception('Erreur récupération produits');
  }

  Future<Produit> creerProduit(Map<String, dynamic> data) async {
    final token = await authService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/produits'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '******',
      },
      body: json.encode(data),
    );
    
    if (response.statusCode == 201) {
      return Produit.fromJson(json.decode(response.body));
    }
    throw Exception('Erreur création produit');
  }
}
```

### Modèles de Données
```dart
class Produit {
  final int id;
  final String titre, description;
  final double prix;
  final String? imageUrl;

  Produit({required this.id, required this.titre, required this.description, 
           required this.prix, this.imageUrl});

  factory Produit.fromJson(Map<String, dynamic> json) => Produit(
    id: json['id'],
    titre: json['titre'],
    description: json['description'],
    prix: json['prix'].toDouble(),
    imageUrl: json['imageUrl'],
  );
}
```

---

## 4. Fonctionnalités Implémentées

### Système d'Authentification
**Inscription:**
1. Utilisateur remplit formulaire (nom, prénom, email, mot de passe, adresse)
2. Frontend envoie données à `/api/auth/inscription`
3. Backend valide unicité email et hache le mot de passe avec bcrypt
4. Création utilisateur en base de données
5. Génération token JWT avec expiration 1 jour
6. Retour token + données utilisateur au frontend
7. Stockage token localement avec shared_preferences

**Connexion:**
1. Utilisateur saisit email et mot de passe
2. Frontend envoie requête à `/api/auth/connexion`
3. Backend vérifie identifiants et compare mot de passe haché
4. Génération nouveau token JWT
5. Stockage token et redirection vers accueil

### Gestion des Annonces
**Création d'annonce:**
- Upload de photos avec Multer (limite 5MB, types image seulement)
- Validation des données (titre, description, prix obligatoires)
- Création annonce en base avec association à l'utilisateur
- Création produit ou service selon le type
- Enregistrement des URLs de photos

**Modification:**
- Vérification que l'utilisateur est propriétaire de l'annonce
- Mise à jour des champs modifiés
- Gestion ajout/suppression de photos

**Suppression:**
- Vérification propriété ou rôle administrateur
- Suppression en cascade (photos, produit/service associé, annonce)

### Système de Panier
**Implémentation:**
```javascript
async ajouterAuPanier(idUtilisateur, idAnnonce, quantite) {
  let ligne = await LigneCommande.findOne({
    where: { id_utilisateur: idUtilisateur, id_annonce: idAnnonce }
  });
  
  if (ligne) {
    ligne.quantite += quantite;
    await ligne.save();
  } else {
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
```

### Messagerie
**Fonctionnalités:**
- Envoi de messages entre utilisateurs (acheteur-vendeur)
- Stockage en base avec statut lu/non lu
- Consultation historique des conversations
- Affichage des messages non lus

**Modèle Message:**
```javascript
const Message = sequelize.define('Message', {
    contenu: { type: DataTypes.TEXT, allowNull: false },
    date_envoi: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    lu: { type: DataTypes.BOOLEAN, defaultValue: false },
    id_emetteur: { type: DataTypes.INTEGER, references: Utilisateur },
    id_destinataire: { type: DataTypes.INTEGER, references: Utilisateur }
});
```

### Panneau d'Administration
**Middleware de vérification:**
```javascript
const verifierAdmin = (req, res, next) => {
    if (!req.utilisateur || req.utilisateur.role !== 'admin') {
        return res.status(403).json({ message: 'Accès refusé' });
    }
    next();
};
```

**Fonctionnalités:**
- Gestion utilisateurs (liste, suspension, suppression)
- Modération annonces (validation, suppression)
- Statistiques de la plateforme
- Protection par middleware sur toutes les routes admin

---

## 5. Technologies et Compétences Maîtrisées

### Développement Backend
- **API REST avec Node.js/Express:** Création de routes, controllers, middlewares
- **ORM Sequelize:** Définition de modèles, relations, migrations
- **Base de données SQLite:** Gestion des données relationnelles
- **Authentification JWT:** Génération et vérification de tokens
- **Sécurité web:** Hachage bcrypt, validation des entrées, CORS
- **Gestion de fichiers:** Upload avec Multer, validation types/taille

### Développement Frontend
- **Flutter/Dart:** Développement d'application mobile multiplateforme
- **Communication HTTP:** Appels API REST, gestion réponses JSON
- **Sérialisation JSON:** Conversion objets Dart ↔ JSON
- **Gestion d'état:** Stockage local avec shared_preferences
- **Navigation:** Routes nommées et navigation entre écrans
- **Upload de fichiers:** Sélection et envoi d'images depuis mobile

### Architecture et Patterns
- **Architecture client-serveur:** Séparation frontend/backend
- **Pattern MVC adapté:** Routes, Controllers, Services, Models
- **Architecture en couches:** Séparation des responsabilités
- **API RESTful:** Respect des principes REST (GET, POST, PUT, DELETE)
- **Middleware pattern:** Authentification, validation, gestion erreurs

---

**Document:** Documentation Implémentation Technique  
**Projet:** BusyKin - Plateforme de Marketplace  
**Date:** 14 Novembre 2024  
**Technologies:** Node.js, Express, Flutter, SQLite, JWT, Bcrypt
