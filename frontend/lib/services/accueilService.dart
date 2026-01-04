import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/models/Annonce.dart';
import 'package:frontend/services/rechercheService.dart';
import 'package:http/http.dart' as http;

class AccueilService {
  final String baseUrl = kIsWeb
      ? 'http://localhost:3000/api/accueil'
      : 'http://10.0.2.2:3000/api/accueil';
  final RechercheService _rechercheService = RechercheService();

  Future<(List<Annonce>, List<Annonce>, List<String>)?> obtenirDonnees({
    int page = 1,
    int limite = 20,
    String? categorie,
    String? type,
    double? prix,
    String? recherche,
  }) async {
    try {
      // ✅ INITIALISATION DIRECTE
      List<Annonce> annonces = [];
      List<Annonce> tendances = [];
      List<String> categories = [];

      if (recherche != null && recherche.trim().isNotEmpty) {
        final resultats = await _rechercheService.rechercherAnnonces(
          q: recherche,
        );

        if (resultats != null) {
          annonces = resultats;
        }
      } else {
        final queryParams = <String, dynamic>{
          'page': page.toString(),
          'limite': limite.toString(),
          if (categorie != null) 'categorie': categorie,
          if (type != null) 'type': type,
          if (prix != null) 'prix': prix,
        };

        final uri = Uri.parse(
          '$baseUrl/obtenirDonnees',
        ).replace(queryParameters: queryParams);

        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          categories = (data['categories'] as List)
              .map((item) => item['nom_categorie'].toString())
              .toList();

          annonces = (data['recentes'] as List)
              .map((json) => Annonce.fromJson(json))
              .toList();

          tendances = (data['tendance'] as List)
              .map((json) => Annonce.fromJson(json))
              .toList();
        }
      }
      
      print(categories);
      return (annonces, tendances, categories);
    } catch (e) {
      print("❌ Erreur dans obtenirDonnees: $e");
      return null;
    }
  }
}
