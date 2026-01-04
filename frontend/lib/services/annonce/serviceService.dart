import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../models/Service.dart';
import '../authService.dart';

class ServiceService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000/api/services'
      : 'http://10.0.2.2:3000/api/services';
  
  final AuthService _authService = AuthService();

  // ✅ Méthode centralisée pour construire URL image
  static String buildImageUrl(String url) {
    if (url.isEmpty) return '';
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
  

  Future<List<Service>> obtenirServices({
    int page = 1,
    int limit = 20,
    String? categorie,
    String? type,
    double? prixMin,
    double? prixMax,
    String? recherche,
    bool? disponibilite,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (categorie != null) 'categorie': categorie,
        if (type != null) 'type': type,
        if (prixMin != null) 'prixMin': prixMin.toString(),
        if (prixMax != null) 'prixMax': prixMax.toString(),
        if (recherche != null) 'recherche': recherche,
        if (disponibilite != null) 'disponibilite': disponibilite.toString(),
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      print('🔍 GET $uri');

      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final servicesJson = data['services'] as List;
        
        return servicesJson.map((json) => Service.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur obtenirServices: $e');
      rethrow;
    }
  }

  Future<Service> obtenirServiceParId(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/$id');
      print('🔍 GET $uri');

      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Service.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Service introuvable');
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur obtenirServiceParId: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> obtenirCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/categories');
      print('🔍 GET $uri');

      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur obtenirCategories: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> obtenirTypesParCategorie(int categorieId) async {
    try {
      final uri = Uri.parse('$baseUrl/categories/$categorieId/types');
      print('🔍 GET $uri');

      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur obtenirTypesParCategorie: $e');
      rethrow;
    }
  }
}