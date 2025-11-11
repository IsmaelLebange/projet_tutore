import 'package:frontend/models/Adresse.dart';

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

  Annonce( {
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
    return Annonce(
      id: json["id"],
      titre: json["titre"],
      description: json["description"],
      prix: (json["prix"] as num).toDouble(),
      type: json["type"],
      image: json["image"],
      utilisateurId: json["utilisateurId"], adresse: null,
      statut: json['statut'],
      etat: json['etat'],
    );
  }
}