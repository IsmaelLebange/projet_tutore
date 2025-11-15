# Documentation d'Implémentation - Projet BusyKin

---

## 1. Architecture et Technologies

### Architecture Client-Serveur
Le projet BusyKin implémente une architecture moderne séparant le backend (API REST Node.js/Express) et le frontend (application mobile Flutter). La communication s'effectue via HTTP avec authentification JWT.

```
Application Flutter  ◄──► API REST Node.js/Express  ◄──► Base SQLite
   (Mobile)                   (Backend)                  (Sequelize ORM)
```

### Stack Technique
**Backend:** Node.js 18+, Express 5.1, Sequelize 6.37, SQLite3 5.1, JWT 9.0, Bcrypt 6.0  
**Frontend:** Flutter/Dart 3.8, http 1.5, shared_preferences 2.5

---

## 2. Backend - API REST

### Structure
```
backend/src/
├── controllers/    # Logique HTTP
├── models/        # Modèles Sequelize
├── routes/        # Endpoints API
├── services/      # Logique métier
└── middlewares/   # Auth, validation
```

### Modèles Principaux
**Utilisateur:** `{prenom, nom, email, mot_de_passe, role, reputation, etat}`  
**Annonce:** `{titre, description, prix, statut, id_utilisateur, id_adresse}`  
**Produit/Service:** Hérite d'Annonce avec attributs spécifiques

### Endpoints API
- **Auth:** `POST /api/auth/inscription`, `POST /api/auth/connexion`
- **Produits:** `GET/POST/PUT/DELETE /api/produits`
- **Services:** `GET/POST/PUT/DELETE /api/services`
- **Annonces:** `GET/POST/PUT/DELETE /api/annonces`
- **Panier:** `GET /api/panier`, `POST /api/panier/ajouter`
- **Admin:** `GET /api/admin/utilisateurs` (rôle admin requis)

### Sécurité
```javascript
// JWT - Génération token
const token = jwt.sign({ idUtilisateur }, SECRET, { expiresIn: '1d' });

// Middleware authentification
const authentifier = (req, res, next) => {
    const token = req.headers['authorization']?.substring(7);
    try {
        const decoded = jwt.verify(token, SECRET);
        req.idUtilisateur = decoded.idUtilisateur;
        next();
    } catch { res.status(403).json({ message: 'Token invalide' }); }
};

// Bcrypt - Hachage mot de passe
const hash = await bcrypt.hash(password, 10);
const valid = await bcrypt.compare(password, hash);
```

---

## 3. Frontend - Flutter

### Structure
```
lib/
├── ecrans/        # Pages UI
├── services/      # API calls
├── models/        # Classes données
└── composants/    # Widgets réutilisables
```

### Services API
```dart
class AuthService {
  Future<AuthResponse> connexion(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/connexion'),
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
}
```

### Modèles
```dart
class Produit {
  final int id;
  final String titre, description;
  final double prix;
  
  factory Produit.fromJson(Map<String, dynamic> json) => Produit(
    id: json['id'],
    titre: json['titre'],
    description: json['description'],
    prix: json['prix'].toDouble(),
  );
}
```

---

## 4. Fonctionnalités Implémentées

### Authentification
- **Inscription:** Validation email unique, hachage bcrypt, création compte, génération JWT
- **Connexion:** Vérification identifiants, génération token, stockage local
- Token stocké dans `shared_preferences`, envoyé dans header `Authorization: ******` pour requêtes protégées

### Gestion Annonces
- **Création:** Upload photos (Multer), validation, enregistrement DB
- **Modification:** Vérification propriété, mise à jour
- **Suppression:** Cascade (photos, produit/service)
- **Recherche:** Filtres catégorie, type, prix, localisation

### Panier
```javascript
async ajouterAuPanier(idUtilisateur, idAnnonce, quantite) {
  let ligne = await LigneCommande.findOne({
    where: { id_utilisateur: idUtilisateur, id_annonce: idAnnonce }
  });
  
  if (ligne) {
    ligne.quantite += quantite;
    await ligne.save();
  } else {
    ligne = await LigneCommande.create({ id_utilisateur, id_annonce, quantite });
  }
  return ligne;
}
```

### Messagerie
Messages entre utilisateurs (acheteur-vendeur) avec statut lu/non lu, stockage DB

### Administration
- Gestion utilisateurs (suspension, suppression)
- Modération annonces (validation, retrait)
- Middleware `verifierAdmin` vérifie rôle sur routes admin

---

## 5. Points Forts et Améliorations

### Points Forts
✅ **Architecture moderne:** Séparation claire backend/frontend  
✅ **Sécurité robuste:** JWT, bcrypt, validation données  
✅ **API REST complète:** Endpoints documentés, codes HTTP standards  
✅ **Mobile multiplateforme:** Flutter Android/iOS  
✅ **Code organisé:** Pattern MVC, services réutilisables  

### Technologies Maîtrisées
- API REST avec Node.js/Express
- ORM Sequelize et SQLite
- Authentification JWT et sécurité web
- Développement mobile Flutter/Dart
- Architecture client-serveur

### Améliorations Futures
🔄 Migration PostgreSQL pour scalabilité  
🔄 WebSockets pour messagerie temps réel  
🔄 Cache Redis pour performance  
🔄 Tests d'intégration complets  
🔄 CI/CD automatisé  

---

**Document:** Documentation Implémentation BusyKin  
**Date:** 14 Novembre 2024  
**Technologies:** Node.js, Express, Flutter, SQLite, JWT, Bcrypt
