import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/LignePanier.dart';
import 'authService.dart';

class PanierService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000/api/panier'
      : 'http://10.0.2.2:3000/api/panier';

  final AuthService _authService = AuthService();

  // ✅ Centraliser URL image (même logique que produits/services)
  static String buildImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
    return '$baseUrl${url.startsWith('/') ? '' : '/'}$url';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> obtenirPanier() async {
    try {
      final uri = Uri.parse(baseUrl);
      print('🔍 GET $uri');

      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lignesJson = data['lignes'] as List;
        final lignes = lignesJson.map((json) => LignePanier.fromJson(json)).toList();

        return {
          'transaction': data['transaction'],
          'lignes': lignes,
          'total': data['total'],
        };
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur obtenirPanier: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> ajouterAuPanier({
    required String type,
    required int itemId,
    int quantite = 1,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/ajouter');
      print('📮 POST $uri');

      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: json.encode({
          'type': type,
          'itemId': itemId,
          'quantite': quantite,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur ajouterAuPanier: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> modifierQuantite(int ligneId, int quantite) async {
    try {
      final uri = Uri.parse('$baseUrl/ligne/$ligneId');
      print('🔄 PUT $uri');

      final response = await http.put(
        uri,
        headers: await _getHeaders(),
        body: json.encode({'quantite': quantite}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur modifierQuantite: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> supprimerLigne(int ligneId) async {
    try {
      final uri = Uri.parse('$baseUrl/ligne/$ligneId');
      print('🗑️ DELETE $uri');

      final response = await http.delete(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur supprimerLigne: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> viderPanier() async {
    try {
      final uri = Uri.parse('$baseUrl/vider');
      print('🗑️ DELETE $uri');

      final response = await http.delete(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur viderPanier: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validerPanier(int comptePaiementVendeurId) async {
    try {
      final uri = Uri.parse('$baseUrl/valider');
      print('✅ POST $uri');

      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: json.encode({'comptePaiementVendeurId': comptePaiementVendeurId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur validerPanier: $e');
      rethrow;
    }
  }
}