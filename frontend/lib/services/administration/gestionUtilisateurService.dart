// lib/services/administration/gestionUtilisateurService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../authService.dart';
import '../../models/Utilisateur.dart';

class GestionUtilisateurService {
  final String baseUrl;
  GestionUtilisateurService({this.baseUrl = 'http://localhost:3000/api'});

  Future<String?> _getToken() async {
    final authService = AuthService();
    return await authService.getToken();
  }

  // Récupérer tous les utilisateurs
  Future<List<Utilisateur>> getUtilisateurs() async {
    final token = await _getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$baseUrl/admin/utilisateurs'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((userJson) => Utilisateur.fromJson(userJson)).toList();
    } else {
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
}