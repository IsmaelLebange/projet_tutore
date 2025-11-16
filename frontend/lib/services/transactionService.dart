import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'authService.dart';

class TransactionService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000/api/transactions'
      : 'http://10.0.2.2:3000/api/transactions';

  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> obtenirTransactions() async {
    try {
      final uri = Uri.parse(baseUrl);
      print('🔍 GET $uri');

      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur obtenirTransactions: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> obtenirFacture(int transactionId) async {
    try {
      final uri = Uri.parse('$baseUrl/$transactionId/facture');
      print('🔍 GET $uri');

      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 403) {
        throw Exception('Accès non autorisé à cette facture');
      } else if (response.statusCode == 404) {
        throw Exception('Facture introuvable');
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur obtenirFacture: $e');
      rethrow;
    }
  }
}
