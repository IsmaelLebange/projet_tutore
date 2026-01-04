// lib/services/utilisateurService.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'authService.dart';
import '../../models/Utilisateur.dart';

class UtilisateurService {
  final String baseUrl;
  UtilisateurService({this.baseUrl = 'http://localhost:3000/api'});

  // 🔐 Récupération du token via AuthService
  Future<String?> _token() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();
      print('🔍 Token récupéré: ${token != null ? "OK" : "Aucun"}');
      if (token != null) {
        print('🔍 Token preview: ${token.substring(0, min(20, token.length))}...');
      }
      return token;
    } catch (e) {
      print('❌ Erreur récupération token: $e');
      return null;
    }
  }

  Future<Utilisateur?> getProfil() async {
    final token = await _token();
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        print('✅ Profil récupéré: $data');
        return Utilisateur.fromJson(data);
      } else {
        print('⚠️ Erreur profil: ${res.statusCode} - ${res.body}');
        return null;
      }
    } catch (e) {
      print('❌ Erreur getProfil: $e');
      return null;
    }
  }

  // ✏️ Mettre à jour le profil utilisateur
  Future<bool> mettreAJourProfil({
    String? nom,
    String? prenom,
    String? numeroDeTelephone,
    String? motDePasseNouveau,
  }) async {
    final token = await _token();
    if (token == null) return false;

    try {
      final body = json.encode({
        if (nom != null) 'nom': nom,
        if (prenom != null) 'prenom': prenom,
        if (numeroDeTelephone != null)
          'numero_de_telephone': numeroDeTelephone,
        if (motDePasseNouveau != null)
          'mot_de_passe_nouveau': motDePasseNouveau,
      });

      final res = await http.put(
        Uri.parse('$baseUrl/utilisateur/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (res.statusCode == 200) {
        print('✅ Profil mis à jour avec succès.');
        return true;
      } else {
        print('⚠️ Erreur mise à jour: ${res.body}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur miseAJourProfil: $e');
      return false;
    }
  }

  // 🧠 Vérifie si l’utilisateur est authentifié et actif
  Future<bool> isConnected() async {
    final token = await _token();
    return token != null;
  }
}
