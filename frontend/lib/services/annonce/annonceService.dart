import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:http_parser/http_parser.dart'; 
import 'package:http/http.dart' as http;
import '../../models/Annonce.dart';
import '../../models/Produit.dart';
import '../../models/Service.dart';
import '../authService.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class AnnonceService {
  final String baseUrl =kIsWeb
      ? 'http://localhost:3000/api'
      : 'http://10.0.2.2:3000/api'; // ou ton URL serveur
  final AuthService _authService = AuthService();

  /// 🔑 Récupère automatiquement le token JWT depuis AuthService
  Future<String?> _getToken() async {
    final token = await _authService.getToken();
    
    if (token == null || token.isEmpty) {
      throw Exception("Utilisateur non authentifié2.");
    }
    return token;
  }

  /// ✅ Ajout d'une annonce (Produit ou Service)
  Future<Map<String, dynamic>> ajouterAnnonce({
    required Annonce annonce,
    required List<PlatformFile> images, // 🔥 Changé de File à PlatformFile
  }) async {
    final token = await _getToken();
    print('Token récupéré: $token');

    final uri = Uri.parse('$baseUrl/annonces/ajout');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    print('📤 Envoi vers: $uri');
    print('🔑 Header Authorization: Bearer ${token!.substring(0, 20)}...');
    final Map<String, String> champs = {
      'titre': annonce.titre,

      'description': annonce.description,
      'prix': annonce.prix.toString(),
      'type': annonce.type.toLowerCase(),
    };

    if (annonce is Produit) {
      champs['categorie'] = annonce.categorieProduit;
      champs['typeSpecifique'] = annonce.typeProduit;
    } else if (annonce is Service) {
      champs['categorie'] = annonce.categorieService;
      champs['typeSpecifique'] = annonce.typeService;
    }

    // Ajout des champs dans le multipart
    request.fields.addAll(champs);

    // 🔥 Ajout des images (Web + Mobile compatible)
        // 🔥 Ajout des images (Web + Mobile compatible)
    print('📷 Ajout de ${images.length} image(s)...');
    
    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      
      // Déterminer le MIME type selon l'extension
      String ext = image.name.split('.').last.toLowerCase();
      String mimeType;
      
      switch (ext) {
        case 'png':
          mimeType = 'image/png';
          break;
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        case 'bmp':
          mimeType = 'image/bmp';
          break;
        default:
          print('⚠️ Extension inconnue: $ext, utilisation de image/jpeg');
          mimeType = 'image/jpeg';
      }

      print('  📎 Image ${i + 1}: ${image.name} - MIME: $mimeType');
      
      if (kIsWeb) {
        // Sur Web : utilise bytes
        if (image.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'images',
            image.bytes!,
            filename: image.name,
            contentType: MediaType.parse(mimeType), // 🔧 AJOUT
          ));
          print('  ✅ Image ${i + 1} ajoutée (Web)');
        }
      } else {
        // Sur Mobile : utilise path
        if (image.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              image.path!,
              contentType: MediaType.parse(mimeType), // 🔧 AJOUT
            ),
          );
          print('  ✅ Image ${i + 1} ajoutée (Mobile)');
        }
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final err = json.decode(response.body);
      throw Exception(err['message'] ?? 'Erreur: ${response.statusCode}');
    }
  }

  /// 📥 Récupération de toutes les annonces
  Future<List<Annonce>> obtenirAnnonces() async {
    final response = await http.get(Uri.parse('$baseUrl/annonces'));
    if (response.statusCode != 200) {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }

    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Annonce.fromJson(json)).toList();
  }

  /// 🔍 Récupérer une annonce spécifique
  Future<Annonce> obtenirAnnonceParId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/annonces/$id'));
    if (response.statusCode != 200) {
      throw Exception('Annonce introuvable.');
    }
    return Annonce.fromJson(json.decode(response.body));
  }

  /// 🗑️ Suppression d'une annonce (admin ou proprio)
  Future<bool> supprimerAnnonce(int id) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/annonces/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) return true;

    final err = json.decode(response.body);
    throw Exception(err['message'] ?? 'Erreur suppression.');
  }

  Future<Map<String, Map<String, List<String>>>> obtenirCategoriesEtTypes() async {
  try {
    print('🟡 Début récupération catégories...');
    
    final produitRes = await http.get(Uri.parse('$baseUrl/categories/produits'));
    final serviceRes = await http.get(Uri.parse('$baseUrl/categories/services'));

    

    final produitData = json.decode(produitRes.body) as List;
    final serviceData = json.decode(serviceRes.body) as List;

    // 🔥 AFFICHE LA STRUCTURE DES DONNÉES
    print('🟡 Structure premier produit: ${produitData.isNotEmpty ? produitData.first : "VIDE"}');
    print('🟡 Structure premier service: ${serviceData.isNotEmpty ? serviceData.first : "VIDE"}');

    Map<String, Map<String, List<String>>> result = {
      "produit": {},
      "service": {},
    };

    for (var cat in produitData) {
      print('🟡 Catégorie produit: $cat');
      final nomCat = cat['nom_categorie'];
      final types = (cat['types'] as List).map((t) => t['nom_type'] as String).toList();
      print('🟡 Nom catégorie: $nomCat, Types: $types');
      result["produit"]![nomCat] = types;
    }

    for (var cat in serviceData) {
      print('🟡 Catégorie service: $cat');
      final nomCat = cat['nom_categorie'];
      final types = (cat['types'] as List).map((t) => t['nom_type'] as String).toList();
      print('🟡 Nom catégorie: $nomCat, Types: $types');
      result["service"]![nomCat] = types;
    }

    print('🟡 Résultat final: $result');
    return result;

  } catch (e) {
    print('🔴 Erreur complète: $e');
    
    throw Exception("Erreur récupération des catégories: $e");
  }
}

  /// 🔥 Changé pour retourner PlatformFile au lieu de File
  Future<List<PlatformFile>> choisirImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: kIsWeb, // 🔥 Important pour avoir les bytes sur Web
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files;
      }
      return [];
    } catch (e) {
      throw Exception('Erreur sélection images: $e');
    }
  }

  
  Future<List<Annonce>> obtenirMesAnnonces() async {
    try {
      print('📋 Récupération de mes annonces...');
      
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/annonces/mesAnnonces'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Status: ${response.statusCode}');
      print('📄 Réponse: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['annonces'] != null) {
          final List<dynamic> annoncesJson = data['annonces'];
          print('✅ ${annoncesJson.length} annonce(s) récupérée(s)');
          
          return annoncesJson.map((json) {
            // ⚠️ Créer le bon type selon le champ 'type'
            if (json['type'] == 'produit') {
              return Produit(
                id: json['id'],
                titre: json['titre'],
                description: json['description'],
                prix: (json['prix'] as num).toDouble(),
                image: json['image'] ?? '', // ⚠️ image du backend
                categorieProduit: json['categorie'] ?? '',
                typeProduit: json['typeSpecifique'] ?? '',
              );
            } else if (json['type'] == 'service') {
              return Service(
                id: json['id'],
                titre: json['titre'],
                description: json['description'],
                prix: (json['prix'] as num).toDouble(),
                image: json['image'] ?? '', // ⚠️ image du backend
                categorieService: json['categorie'] ?? '',
                typeService: json['typeSpecifique'] ?? '',
              );
            } else {
              return Annonce(
                id: json['id'],
                titre: json['titre'],
                description: json['description'],
                prix: (json['prix'] as num).toDouble(),
                type: json['type'],
                image: json['image'] ?? '',
              );
            }
          }).toList();
        }
        return [];
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }

    } catch (e) {
      print('❌ Exception obtenirMesAnnonces: $e');
      rethrow;
    }
  }

}


