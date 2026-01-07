# Documentation d'Implémentation - Projet BusyKin
## Résumé Exécutif (5 Pages)

---

## 1. Introduction et Architecture

### 1.1 Contexte du Projet
BusyKin est une plateforme de marketplace mobile permettant l'échange de produits et services entre utilisateurs. Le projet implémente une architecture client-serveur moderne avec séparation complète du backend (API REST) et du frontend (application mobile).

### 1.2 Architecture Technique
```
┌─────────────────┐      REST API/JSON      ┌──────────────────┐
│  Application    │ ◄──────────────────────► │   Serveur API    │
│  Flutter        │      HTTP/HTTPS          │   Node.js        │
│  (Mobile)       │                          │   Express        │
└─────────────────┘                          └──────────────────┘
                                                      │
                                                      ▼
                                              ┌──────────────────┐
                                              │  Base SQLite     │
                                              │  (Sequelize ORM) │
                                              └──────────────────┘
```

### 1.3 Stack Technique

**Backend:**
- Node.js (≥18.0.0) - Runtime JavaScript
- Express (5.1.0) - Framework REST API
- Sequelize (6.37.7) - ORM base de données
- SQLite3 (5.1.7) - Base de données
- JWT (9.0.2) - Authentification
- Bcrypt (6.0.0) - Sécurité mots de passe

**Frontend:**
- Flutter - Framework mobile multiplateforme
- Dart (^3.8.1) - Langage de programmation
- http (^1.5.0) - Client HTTP
- shared_preferences (^2.5.3) - Stockage local

---

## 2. Backend - Structure et Implémentation

### 2.1 Architecture des Dossiers
```
backend/
├── src/
│   ├── controllers/    # Logique des routes HTTP
│   ├── models/         # Modèles Sequelize (base de données)
│   ├── routes/         # Définition des endpoints API
│   ├── services/       # Logique métier réutilisable
│   ├── middlewares/    # Authentification, validation
│   └── config/         # Configuration DB et Express
├── database/           # Fichier SQLite
└── server.js          # Point d'entrée
```

### 2.2 Modèles de Données Principaux

**Utilisateur:**
```javascript
{
    prenom, nom, email, mot_de_passe,
    numero_de_telephone, date_inscription,
    reputation, role (utilisateur/admin),
    etat (Actif/Suspendu)
}
```

**Annonce:**
```javascript
{
    titre, description, prix,
    date_publication, statut_annonce,
    id_utilisateur (vendeur), id_adresse
}
```

**Produit/Service:** Héritent d'une annonce avec détails spécifiques (état, type, disponibilité).

### 2.3 API REST - Endpoints Principaux

| Endpoint | Méthode | Description | Auth |
|----------|---------|-------------|------|
| `/api/auth/inscription` | POST | Créer compte | Non |
| `/api/auth/connexion` | POST | Se connecter | Non |
| `/api/produits` | GET | Liste produits | Non |
| `/api/produits` | POST | Créer produit | Oui |
| `/api/annonces/:id` | PUT | Modifier annonce | Oui |
| `/api/panier` | GET | Voir panier | Oui |
| `/api/admin/utilisateurs` | GET | Gérer users | Admin |

### 2.4 Authentification et Sécurité

**Processus JWT:**
1. Utilisateur s'inscrit/connecte
2. Serveur vérifie identifiants et génère token JWT
3. Client stocke le token localement
4. Client envoie token dans header `Authorization: Bearer <token>`
5. Middleware vérifie token à chaque requête protégée

**Sécurité:**
- Mots de passe hachés avec bcrypt (10 cycles)
- JWT avec expiration 1 jour
- Validation des données entrantes
- CORS configuré
- Upload fichiers limité (5MB, images uniquement)

---

## 3. Frontend - Application Flutter

### 3.1 Structure de l'Application
```
lib/
├── ecrans/              # Pages de l'app
│   ├── Accueil.dart
│   ├── authentification/
│   ├── annonces/
│   └── administration/
├── services/            # Communication API
│   ├── authService.dart
│   ├── produitService.dart
│   └── panierService.dart
├── models/              # Classes de données
└── composants/          # Widgets réutilisables
```

### 3.2 Services API

**AuthService - Exemple:**
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
      return AuthResponse(utilisateur: data['utilisateur']);
    }
    return AuthResponse(error: 'Connexion échouée');
  }
}
```

### 3.3 Gestion de l'État
- Token JWT stocké avec `shared_preferences`
- Services centralisés pour appels API
- Navigation avec routes nommées Flutter

---

## 4. Fonctionnalités Implémentées

### 4.1 Authentification
- **Inscription:** Validation email unique, hachage mot de passe, création compte
- **Connexion:** Vérification identifiants, génération JWT
- **Déconnexion:** Suppression token local

### 4.2 Gestion des Annonces
- **Création:** Upload photos (Multer), validation données, enregistrement DB
- **Modification:** Vérification propriété, mise à jour
- **Suppression:** Cascade (photos, produit/service associé)
- **Recherche:** Filtres par catégorie, type, prix, localisation

### 4.3 Système de Panier
- Ajout produits/services
- Modification quantités
- Calcul total automatique
- Persistance en base de données

### 4.4 Messagerie
- Messages entre utilisateurs (acheteur-vendeur)
- Stockage en base avec statut lu/non lu
- Historique des conversations

### 4.5 Administration
- Gestion utilisateurs (suspension, suppression)
- Modération annonces (validation, retrait)
- Accès restreint par middleware `verifierAdmin`

---

## 5. Déploiement et Tests

### 5.1 Configuration Production

**Backend (.env):**
```env
NODE_ENV=production
PORT=3000
JWT_SECRET=secret_complexe_unique
DB_STORAGE=./database/busykin_db.sqlite
```

**Démarrage:**
```bash
# Backend
npm install --production
npm run prod

# Frontend
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### 5.2 Tests

**Backend (Jest):**
```bash
npm test  # Tests unitaires controllers/services
```

**Frontend (Flutter Test):**
```bash
flutter test  # Tests widgets et services
```

### 5.3 Points Forts et Améliorations

**Points Forts:**
✅ Architecture moderne et modulaire
✅ Sécurité robuste (JWT, bcrypt)
✅ API REST complète et documentée
✅ Application multiplateforme (Android/iOS)
✅ Code organisé et maintenable

**Améliorations Possibles:**
🔄 Migration vers PostgreSQL pour scalabilité
🔄 WebSockets pour messagerie temps réel
🔄 Système de cache (Redis)
🔄 CI/CD automatisé
🔄 Tests d'intégration plus complets

---

## Conclusion

Le projet BusyKin démontre une maîtrise complète du développement full-stack moderne avec:
- Une API REST robuste et sécurisée
- Une application mobile performante et intuitive
- Une architecture scalable et maintenable
- Des fonctionnalités complètes de marketplace

**Technologies Acquises:** Node.js, Express, Sequelize, Flutter, JWT, Architecture REST, Sécurité Web

---

**Document rédigé le:** 14 Novembre 2024  
**Version:** Résumé (5 pages)  
**Projet:** BusyKin - Plateforme de Marketplace
