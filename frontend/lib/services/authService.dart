import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // NÉCESSAIRE
import '../models/utilisateur.dart';
import 'package:flutter/foundation.dart';

// Classe de réponse encapsulant l'utilisateur, le token et les erreurs
class AuthResponse {
  final Utilisateur? utilisateur;
  final String? token;
  final String? error;

  AuthResponse({this.utilisateur, this.token, this.error});
}

class AuthService {
  // URL de base pour les endpoints d'authentification
  static final String _baseUrl = kIsWeb
      ? 'http://localhost:3000/api/auth'
      : 'http://10.0.2.2:3000/api/auth';

  // --- LOGIQUE DE GESTION DES TOKENS ET RÔLES (NOUVEAU) ---

  // Sauvegarde le token et le rôle après une connexion/inscription réussie
  // Dans AuthService.dart - CORRIGE cette fonction
  Future<void> _saveAuthData(String token, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      await prefs.setString('user_role', role);
      print('💾 Token sauvegardé: ${token.substring(0, 20)}...');
      print('💾 Rôle sauvegardé: $role');
    } catch (e) {
      print('❌ Erreur sauvegarde token: $e');
    }
  }

  // Récupère le rôle de l'utilisateur stocké localement
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // Vérifie si l'utilisateur stocké est un administrateur
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    // Le rôle doit être 'admin' pour accéder aux pages sensibles
    return role == 'admin';
  }

  // --- LOGIQUE DE REQUÊTE API ---

  // Fonction interne pour gérer les requêtes POST d'authentification
  Future<AuthResponse> _handleAuthRequest(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);

        final user = Utilisateur.fromJson(data['utilisateur'] ?? data);
        final token = data['token'];

        if (token != null && user.role != null) {
          await _saveAuthData(token, user.role!);
        }

        return AuthResponse(utilisateur: user, token: token);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ??
            errorBody['error'] ??
            'Erreur de connexion. Code: ${response.statusCode}';
        return AuthResponse(error: errorMessage);
      }
    } catch (e) {
      print('Erreur réseau/parsing: $e');
      return AuthResponse(
        error: 'Impossible de contacter le serveur. Le réseau a échoué.',
      );
    }
  }

  // Fonction de CONNEXION (Authentification)
  Future<AuthResponse> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/connexion');
    return _handleAuthRequest(url, {'email': email, 'mot_de_passe': password});
  }

  // Fonction d'INSCRIPTION (Utilise nom et prenom séparés)
  Future<AuthResponse> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String email,
    required String password,
    required String commune,
    String? quartier,
    String? rue,
  }) async {
    final url = Uri.parse('$_baseUrl/inscription');

    final body = {
      'nom': nom,
      'prenom': prenom,
      'numero_de_telephone': telephone.isEmpty ? null : telephone,
      'email': email,
      'mot_de_passe': password,
      'adresse_fixe': {'commune': commune, 'quartier': quartier, 'rue': rue},
    };

    return _handleAuthRequest(url, body);
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token'); // adapte la clé si besoin
    } catch (_) {
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      await prefs.remove('user_role');
      print('🔒 Déconnexion : token & role supprimés');
      return true;
    } catch (e) {
      print('❌ Erreur logout: $e');
      return false;
    }
  }
}
