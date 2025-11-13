import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/Notification.dart';
import 'authService.dart';

class NotificationService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000/api/notifications'
      : 'http://10.0.2.2:3000/api/notifications';

  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<NotificationModel>> obtenirNotifications() async {
    try {
      final uri = Uri.parse(baseUrl);
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur obtenirNotifications: $e');
      rethrow;
    }
  }

  Future<void> confirmerTransaction(int transactionId) async {
    try {
      final uri = Uri.parse('$baseUrl/transaction/$transactionId/confirmer');
      final response = await http.post(uri, headers: await _getHeaders());

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur confirmerTransaction: $e');
      rethrow;
    }
  }

  Future<void> marquerLu(int notificationId) async {
    try {
      final uri = Uri.parse('$baseUrl/$notificationId/lu');
      final response = await http.put(uri, headers: await _getHeaders());

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur marquerLu: $e');
      rethrow;
    }
  }
}