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
    this.dimension,}):super(
     id: id,
     titre: titre,
     description: description,
     prix: prix,
     image: image,
     type: 'Produit'
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
    );
  }
}