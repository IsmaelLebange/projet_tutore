import 'dart:convert';
import 'package:frontend/models/Produit.dart';
import 'package:frontend/models/Service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/Annonce.dart';

class RechercheService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:3000/api/recherche'
      : 'http://10.0.2.2:3000/api/recherche';

  Future<List<Annonce>?> rechercherAnnonces({required String? q}) async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {'q': q ?? ''});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final annonces = data.map((item) {
          Map<String, dynamic> annonceData = Map<String, dynamic>.from(item['annonce'] ?? {});
          
          annonceData['id'] = item['id'];
          annonceData['etat'] = item['etat'];
          
          if (item.containsKey('id_type')) {
             annonceData['type'] = 'Produit';
             annonceData['typeProduit'] = item['type']?['nom_type'];
             annonceData['categorieProduit'] = item['type']?['categorie']?['nom_categorie'];
          } else {
             annonceData['type'] = 'Service';
             annonceData['typeService'] = item['type']?['nom_type'];
             annonceData['categorieService'] = item['type']?['categorie']?['nom_categorie'];
          }

          return Annonce.fromJson(annonceData);
        }).toList();

        print("✅ Annonces converties avec succès : ${annonces.length}");
        return annonces;
      }
    } catch (e) {
      print('❌ Erreur fatale dans RechercheService: $e');
    }
    return [];
  }
  Future<List<Produit>?> rechercherProduits({required String query}) async {
    try {
      final uri = Uri.parse('$baseUrl/produit');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final produits =
            (data['annonces'] as List?)
                ?.map((item) => Produit.fromJson(item))
                .toList() ??
            [];
        return produits;
      } else {
        print('❌ Erreur recherche: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur recherche: $e');
    }
  }

  Future<List<Service>?> rechercherServices({required String query}) async {
    try {
      final uri = Uri.parse('$baseUrl/service');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final services =
            (data['annonces'] as List?)
                ?.map((item) => Service.fromJson(item))
                .toList() ??
            [];
        return services;
      } else {
        print('❌ Erreur recherche: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur recherche: $e');
    }
  }
}
