import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  // ⚠️ CLÉS UNIFIÉES
  static const String _tokenKey = 'token';
  static const String _roleKey = 'user_role';

  // --- LOGIQUE DE GESTION DES TOKENS ET RÔLES ---

  // Sauvegarde le token et le rôle après une connexion/inscription réussie
  Future<void> _saveAuthData(String token, String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_roleKey, role);
      print('💾 Token sauvegardé: ${token.substring(0, 20)}...');
      print('💾 Rôle sauvegardé: $role');
    } catch (e) {
      print('❌ Erreur sauvegarde token: $e');
      rethrow;
    }
  }

  // Récupère le token stocké
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        print('🔑 Token récupéré: ${token.substring(0, 20)}...');
      } else {
        print('⚠️ Aucun token trouvé en mémoire');
      }
      return token;
    } catch (e) {
      print('❌ Erreur récupération token: $e');
      return null;
    }
  }

  // Récupère le rôle de l'utilisateur stocké localement
  Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString(_roleKey);
      print('👤 Rôle récupéré: ${role ?? "non défini"}');
      return role;
    } catch (e) {
      print('❌ Erreur récupération rôle: $e');
      return null;
    }
  }

  // Vérifie si l'utilisateur stocké est un administrateur
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  // --- LOGIQUE DE REQUÊTE API ---

  // Fonction interne pour gérer les requêtes POST d'authentification
  Future<AuthResponse> _handleAuthRequest(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    try {
      print('📤 Envoi requête vers: $url');
      print('📋 Body: ${json.encode(body)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      print('📥 Status: ${response.statusCode}');
      print('📄 Réponse: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);

        final user = Utilisateur.fromJson(data['utilisateur'] ?? data);
        final token = data['token'];

        print('✅ Utilisateur: ${user.email}, Rôle: ${user.role}');
        print('✅ Token reçu: ${token != null ? "OUI" : "NON"}');

        if (token != null && user.role != null) {
          await _saveAuthData(token, user.role!);
        } else {
          print('⚠️ Token ou rôle manquant dans la réponse');
        }

        return AuthResponse(utilisateur: user, token: token);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ??
            errorBody['error'] ??
            'Erreur de connexion. Code: ${response.statusCode}';
        print('❌ Erreur serveur: $errorMessage');
        return AuthResponse(error: errorMessage);
      }
    } catch (e) {
      print('❌ Erreur réseau/parsing: $e');
      return AuthResponse(
        error: 'Impossible de contacter le serveur. Le réseau a échoué.',
      );
    }
  }

  // Fonction de CONNEXION (Authentification)
  Future<AuthResponse> login(String email, String password) async {
    print('🔐 Tentative de connexion pour: $email');
    final url = Uri.parse('$_baseUrl/connexion');
    return _handleAuthRequest(url, {'email': email, 'mot_de_passe': password});
  }

  // Fonction d'INSCRIPTION
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
    print('📝 Tentative d\'inscription pour: $email');
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

  // Déconnexion
  Future<bool> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey); // ⚠️ CORRECTION: bonne clé
      await prefs.remove(_roleKey);
      Navigator.pushReplacementNamed(context, '/connexion');
      return true;
    } catch (e) {
      
      return false;
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}