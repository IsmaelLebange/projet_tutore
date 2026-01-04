import 'package:frontend/models/Annonce.dart';

class Produit extends Annonce {
  final String typeProduit;
  final String categorieProduit;

  Produit({
    int? id,
    required String titre,
    required String description,
    required double prix,
    image,
    required this.typeProduit,
    required this.categorieProduit,
    String? etat,
  }) : super(
          id: id,
          titre: titre,
          description: description,
          prix: prix,
          image: image,
          type: 'Produit',
          etat: etat,
        );

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] as int?,
      titre: json['titre'] ?? '', 
      description: json['description'] ?? '',
      typeProduit: json['typeProduit'] ?? 'Non défini', 
      categorieProduit: json['categorieProduit'] ?? 'Non définie', 
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      etat: json['etat'], 
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'typeProduit': typeProduit,
      'categorieProduit': categorieProduit,
    });
    return map;
  }
}