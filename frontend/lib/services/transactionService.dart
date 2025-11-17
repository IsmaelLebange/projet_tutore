import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/Transaction.dart';
import 'authService.dart';

class TransactionService {
  static final String baseUrl = kIsWeb
      ? 'http://localhost:3000/api/transactions'
      : 'http://10.0.2.2:3000/api/transactions';

  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Obtenir la liste des transactions
  Future<List<TransactionModel>> obtenirMesTransactions() async {
    try {
      final uri = Uri.parse(baseUrl);
      print('📤 GET $uri');

      final response = await http.get(uri, headers: await _getHeaders());

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur obtenirMesTransactions: $e');
      rethrow;
    }
  }

  /// Obtenir le détail d'une transaction
  Future<DetailTransaction> obtenirDetailTransaction(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/$id');
      print('📤 GET $uri');

      final response = await http.get(uri, headers: await _getHeaders());

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DetailTransaction.fromJson(data);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur obtenirDetailTransaction: $e');
      rethrow;
    }
  }

  /// Confirmer une transaction
  Future<void> confirmerTransaction(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/$id/confirmer');
      print('📤 POST $uri');

      final response = await http.post(
        uri,
        headers: await _getHeaders(),
      );

      print('📥 Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur confirmerTransaction: $e');
      rethrow;
    }
  }
}