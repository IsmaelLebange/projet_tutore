import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/ComptePaiement.dart';
import 'authService.dart';

class ComptePaiementService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000/api/comptes-paiement'
      : 'http://10.0.2.2:3000/api/comptes-paiement';

  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ComptePaiement>> obtenirComptes() async {
    try {
      final uri = Uri.parse(baseUrl);
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ComptePaiement.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur obtenirComptes: $e');
      rethrow;
    }
  }

  Future<ComptePaiement> ajouterCompte({
    required String numeroCompte,
    required String entreprise,
    bool estPrincipal = false,
  }) async {
    try {
      final uri = Uri.parse(baseUrl);
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: json.encode({
          'numero_compte': numeroCompte,
          'entreprise': entreprise,
          'est_principal': estPrincipal,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ComptePaiement.fromJson(data['compte']);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur ajouterCompte: $e');
      rethrow;
    }
  }

  Future<void> supprimerCompte(int compteId) async {
    try {
      final uri = Uri.parse('$baseUrl/$compteId');
      final response = await http.delete(uri, headers: await _getHeaders());

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur supprimerCompte: $e');
      rethrow;
    }
  }

  Future<ComptePaiement> definirPrincipal(int compteId) async {
    try {
      final uri = Uri.parse('$baseUrl/$compteId/principal');
      final response = await http.post(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ComptePaiement.fromJson(data['compte']);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur definirPrincipal: $e');
      rethrow;
    }
  }
}