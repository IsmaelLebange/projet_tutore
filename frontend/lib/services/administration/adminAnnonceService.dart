import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../authService.dart';
import '../../models/Annonce.dart';
import '../../models/Produit.dart';
import '../../models/Service.dart';

class AdminAnnonceService {
  final String baseUrl;
  AdminAnnonceService({
    this.baseUrl = kIsWeb
        ? 'http://localhost:3000/api/admin'
        : 'http://10.0.2.2:3000/api/admin',
  });

  Future<String?> _getToken() async {
    final authService = AuthService();
    final token = await authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Utilisateur non authentifié');
    }
    return token;
  }

  List<Annonce> _mapperListe(dynamic annoncesJson) {
    return (annoncesJson as List).map((json) {
      if (json['type'] == 'produit') {
        return Produit(
          id: json['id'],
          titre: json['titre'] ?? '',
          description: json['description'] ?? '',
          prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
          image: json['image'] ?? '',
          categorieProduit: json['categorie'] ?? '',
          typeProduit: json['typeSpecifique'] ?? '',
        );
      } else if (json['type'] == 'service') {
        return Service(
          id: json['id'],
          titre: json['titre'] ?? '',
          description: json['description'] ?? '',
          prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
          image: json['image'] ?? '',
          categorieService: json['categorie'] ?? '',
          typeService: json['typeSpecifique'] ?? '',
        );
      } else {
        return Annonce(
          id: json['id'],
          titre: json['titre'] ?? '',
          description: json['description'] ?? '',
          prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
          type: json['type'] ?? 'inconnu',
          image: json['image'] ?? '',
        );
      }
    }).toList();
  }

  Future<List<Annonce>> obtenirAnnoncesAdmin() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/annonces'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return _mapperListe(data['annonces']);
    } else {
      throw Exception('Erreur admin: ${res.statusCode}');
    }
  }

  Future<bool> changerStatutAnnonce(int id, String statut) async {
    final token = await _getToken();
    final res = await http.patch(
      Uri.parse('$baseUrl/$id/statut'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'statut': statut}),
    );
    return res.statusCode == 200;
  }
  // ...existing code...

  /// 🗑️ Suppression admin (vérifie rôle avant)
  Future<bool> supprimerAnnonceAdmin(int id) async {
    // Vérification rôle admin
    final authService = AuthService();
    final isAdmin = await authService.isAdmin();
    
    if (!isAdmin) {
      throw Exception('Action réservée aux administrateurs');
    }

    final token = await _getToken();
    
    // Utilise l'endpoint de suppression existant
    final res = await http.delete(
      Uri.parse('http://localhost:3000/api/annonces/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('🗑️ Suppression admin annonce $id: ${res.statusCode}');
    
    if (res.statusCode == 200) {
      return true;
    } else {
      final error = json.decode(res.body);
      throw Exception(error['message'] ?? 'Erreur suppression');
    }
  }

}