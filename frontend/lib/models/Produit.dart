import 'package:frontend/models/Annonce.dart';

class Produit extends Annonce{
  
  final String typeProduit;
  final String categorieProduit;
   final String? dimension;
  
  Produit({
    required int? id,
    required String titre,
    required String description,
    required double prix,

    required String image,
    required this.typeProduit,
    required this.categorieProduit,
    this.dimension,
    String? etat,}):super(
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
      titre: json['titre'],
      description: json['description'],
      typeProduit: json['typeProduit'] as String,
      categorieProduit: json['categorieProduit'],
      dimension: json['dimension'] as String?,
      prix: (json['prix'] as num).toDouble(),
      image: json['image'] as String,
      etat: json['etat'],
    );
  }
@override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'typeProduit': typeProduit,
      'categorieProduit': categorieProduit,
      'dimension': dimension,
    });
    return map;
  }
}