import 'package:frontend/models/Annonce.dart';

class Service extends Annonce{
  final String typeService;
  final String categorieService;
  final bool? disponibilite;
 

  Service({
    required int? id,
    required String titre,
    required String description,
    required double prix,

    required String image,
    
    required this.typeService,
    required this.categorieService,
    this.disponibilite
  }) :super(
    id: id,
     titre: titre,
     description: description,
     prix: prix,
     image: image,
     type: 'Service'
  );

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      prix: (json['prix'] as num).toDouble(), 
      image: json['image'] as String,
      typeService: json['typeService'] as String,
      categorieService: json['categorieService'],
      disponibilite: json['disponibilite'] as bool?,
    );
  }
}