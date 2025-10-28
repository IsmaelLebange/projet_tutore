// ...existing code...
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../authService.dart';
import '../../models/Utilisateur.dart'; // <-- utiliser le modèle

class AdminService {
  final String baseUrl;
  AdminService({this.baseUrl = 'http://localhost:3000/api'});

  Future<String?> _token() async {
    try {
      final authService = AuthService();
      final token = await authService.getToken();
      print('🔍 Token récupéré via AuthService: ${token != null ? "PRÉSENT" : "ABSENT"}');
      if (token != null) {
        print('🔍 Token length: ${token.length}');
        print('🔍 Token début: ${token.substring(0, min(20, token.length))}...');
      }
      return token;
    } catch (e) {
      print('❌ Erreur récupération token: $e');
      return null;
    }
  }

  Future<bool> isAdmin() async {
    final token = await _token();
    print('🔐 Token présent: ${token != null}');
    if (token == null) {
      print('❌ Aucun token trouvé');
      return false;
    }

    try {
      
      final res = await http.get(
        Uri.parse('$baseUrl/admin/check'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (res.statusCode == 200) {
        final j = json.decode(res.body);
        print('🔍 Données reçues: $j');
        return (j['isAdmin'] == true) || (j['role'] == 'admin');
        print('🎯 Est admin: $isAdmin');
      }
      return false;
    } catch (e) {
      print('Erreur vérification admin: $e');
      return false;
    }
  }

  // Nouvelle API : créer un admin à partir du modèle Utilisateur + mot de passe
  Future<void> createAdminFromModel({
    required Utilisateur utilisateur,
    required String password,
  }) async {
    final token = await _token();
    if (token == null) throw Exception('Non authentifié');

    // Utiliser toJson du modèle si disponible, sinon construire la Map au format attendu
    Map<String, dynamic> body;
    try {
      body = utilisateur.toJson();
    } catch (_) {
      // fallback minimal — adapte selon ton model
      body = {
        'nom': utilisateur.nom,
        'prenom': utilisateur.prenom,
        'email': utilisateur.email,
        'numero_de_telephone': utilisateur.telephone,
        'adresse_fixe': {
          'commune': utilisateur.adresse?.commune,
          'quartier': utilisateur.adresse?.quartier,
          'rue': utilisateur.adresse?.rue,
        },
      };
    }
    body['mot_de_passe'] = password; // ajouter le mot de passe

    final res = await http.post(
      Uri.parse('$baseUrl/admin/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      String message = 'Création admin impossible';
      try {
        final resp = json.decode(res.body);
        if (resp is Map && resp['message'] != null) message = resp['message'];
      } catch (_) {}
      throw Exception(message);
    }
  }
}
// ...existing code...