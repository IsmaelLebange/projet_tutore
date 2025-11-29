import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/Annonce.dart';
import 'package:frontend/models/Produit.dart';
import 'package:frontend/models/Service.dart';
import 'package:frontend/services/authService.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class AccueilService {
  final String baseUrl = kIsWeb
      ? 'http://localhost:3000/api/accueil'
      : 'http://10.0.2.2:3000/api/accueil';

  final AuthService _authService = AuthService();

  Future<List<Annonce>?>  obtenirDonnees({
    int page = 1,
    int limite = 20,
    String? categorie,
    String? type,
    double? prix,
    String? recherche,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limite': limite.toString(),
        if (categorie != null) 'categorie': categorie,
        if (type != null) 'type': type,
        if (prix != null) 'prix': type.toString(),
        if (recherche != null) 'recherche': recherche.toString(),
      };
      final uri = Uri.parse(
        '$baseUrl/obtenirDonnees',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
      
          final annonceJson = data['annonce'] as List;
          return annonceJson.map((json) => Annonce.fromJson(json)).toList();
       
       
      }
    } catch (e) {}
  }
}
