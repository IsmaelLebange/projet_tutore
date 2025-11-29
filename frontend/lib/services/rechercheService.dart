// Service de recherche centralisé et simplifié
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/Annonce.dart';

class RechercheService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000/api/accueil'
      : 'http://10.0.2.2:3000/api/accueil';

  /**
   * 🔍 Recherche globale simplifiée
   */
  Future<Map<String, dynamic>> rechercherAnnonces({
    required String query,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔍 Recherche: "$query", type: $type');

      final queryParams = {
        'query': query,
        if (type != null) 'type': type,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/recherche').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Convertir les annonces en objets Annonce
        final annonces = (data['annonces'] as List?)
            ?.map((item) => Annonce.fromJson(item))
            .toList() ?? [];

        return {
          'annonces': annonces,
          'total': data['total'] ?? 0,
          'page': data['page'] ?? 1,
          'totalPages': data['totalPages'] ?? 0,
        };
      } else {
        print('❌ Erreur recherche: ${response.statusCode}');
        return {
          'annonces': <Annonce>[],
          'total': 0,
          'page': 1,
          'totalPages': 0,
        };
      }
    } catch (e) {
      print('❌ Erreur recherche: $e');
      return {
        'annonces': <Annonce>[],
        'total': 0,
        'page': 1,
        'totalPages': 0,
      };
    }
  }

  /**
   * 🔍 Recherche de produits uniquement
   */
  Future<List<Annonce>> rechercherProduits({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final resultats = await rechercherAnnonces(
      query: query,
      type: 'vente',
      page: page,
      limit: limit,
    );
    return resultats['annonces'] as List<Annonce>;
  }

  /**
   * 🔍 Recherche de services uniquement
   */
  Future<List<Annonce>> rechercherServices({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final resultats = await rechercherAnnonces(
      query: query,
      type: 'service',
      page: page,
      limit: limit,
    );
    return resultats['annonces'] as List<Annonce>;
  }
}
