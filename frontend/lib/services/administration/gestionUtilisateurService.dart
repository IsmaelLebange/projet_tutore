// lib/services/administration/gestionUtilisateurService.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../authService.dart';
import '../../models/Utilisateur.dart';

class GestionUtilisateurService {
  final String baseUrl;
  GestionUtilisateurService({
    this.baseUrl = kIsWeb
        ? 'http://localhost:3000/api'
        : 'http://10.0.2.2:3000/api',
  });

  Future<String?> _getToken() async {
    final authService = AuthService();
    return await authService.getToken();
  }

  // Récupérer tous les utilisateurs
  // lib/services/administration/gestionUtilisateurService.dart
  Future<List<Utilisateur>> getUtilisateurs() async {
    final token = await _getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$baseUrl/admin/utilisateurs'),
      headers: {'Authorization': 'Bearer $token'},
    );

    

    if (response.statusCode == 200) {
      // 1. Décodage en type dynamique pour éviter le crash initial
      final decodedData = json.decode(response.body);

      List<dynamic> usersRawList = [];

      // 2. Vérification que la réponse est bien l'objet paginé attendu (Map)
      if (decodedData is Map<String, dynamic> &&
          decodedData.containsKey('utilisateurs')) {
        // Extraction sécurisée de la liste à partir de la clé 'utilisateurs'
        usersRawList = decodedData['utilisateurs'] as List<dynamic>;
      } else {
        // S'assurer qu'au moins nous loguons le problème si la structure change
        print(
          'Avertissement: Le format de réponse du backend admin est inattendu. Reçu: $decodedData',
        );
        return [];
      }

      // 3. Mapping de la liste brute vers les objets Utilisateur
      return usersRawList
          .map((userJson) => Utilisateur.fromJson(userJson))
          .toList();
    } else {
      print('❌ Erreur API: ${response.statusCode} - ${response.body}');
      print('📦 Response Body: ${response.body}');
      throw Exception('Erreur chargement utilisateurs: ${response.statusCode}');
    }
  }

  // Changer état (bloquer/débloquer)
  Future<void> changerEtatUtilisateur(int id, String etat) async {
    final token = await _getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await http.patch(
      Uri.parse('$baseUrl/admin/utilisateurs/$id/etat'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'etat': etat}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur changement état: ${response.statusCode}');
    }
  }

  // Changer rôle
  Future<void> changerRoleUtilisateur(int id, String role) async {
    final token = await _getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await http.patch(
      Uri.parse('$baseUrl/admin/utilisateurs/$id/role'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'role': role}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur changement rôle: ${response.statusCode}');
    }
  }

  // Ajouter cette méthode pour debugger
  Future<void> _debugApiResponse() async {
    final token = await _getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$baseUrl/admin/utilisateurs'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('🔍 Statut API: ${response.statusCode}');
    print('🔍 Body API: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('🔍 Structure données: ${data.runtimeType}');
      if (data is Map) {
        print('🔍 Clés disponibles: ${data.keys}');
      }
    }
  }
}
