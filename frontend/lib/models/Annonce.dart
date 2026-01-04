import 'package:frontend/models/Adresse.dart';
import 'package:frontend/models/Produit.dart';
import 'package:frontend/models/Service.dart';

class Annonce {
  final int? id;
  final String titre;
  final String description;
  final double prix;
  final String type;
  final Adresse? adresse;
  final String? statut;
  final String? etat;

  final String image;
  final int? utilisateurId;

  Annonce({
    this.id,
    required this.titre,
    required this.description,
    required this.prix,
    required this.type,
    required this.image,
    this.adresse,
    this.utilisateurId,
    this.statut,
    this.etat,
  });

  // ✅ conversion objet → JSON (pour l'API backend)
  Map<String, dynamic> toJson() => {
    "id": id,
    "titre": titre,
    "description": description,
    "prix": prix,
    "type": type,
    "image": image,
    "utilisateurId": utilisateurId,
    "statut": statut,
    "etat": etat,
  };

  // ✅ conversion JSON → objet (quand on reçoit depuis l'API backend)
  factory Annonce.fromJson(Map<String, dynamic> json) {
    final type = json['type'];

    if (type == 'Produit') {
      return Produit.fromJson(json);
    } else if (type == 'Service') {
      return Service.fromJson(json);
    } else {
      throw Exception("Type Annonce inconnu");
    }
  }
}
