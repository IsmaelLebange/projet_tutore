import 'package:frontend/models/Annonce.dart';

class Service extends Annonce {
  final String typeService;
  final String categorieService;
  final String? disponibilite; // ✅ String au lieu de bool (correspond au backend)

  Service({
    required int? id,
    required String titre,
    required String description,
    required double prix,
    required String image,
    required this.typeService,
    required this.categorieService,
    this.disponibilite,
    String? etat,
  }) : super(
          id: id,
          titre: titre,
          description: description,
          prix: prix,
          image: image,
          type: 'Service',
          etat: etat,
        );

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int?,
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      prix: (json['prix'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      typeService: json['typeService'] ?? json['typeServiceDetail'] ?? 'Non défini',
      categorieService: json['categorieService'] ?? 'Non définie',
      disponibilite: json['disponibilite']?.toString(),
      etat: json['etat'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      'typeService': typeService,
      'categorieService': categorieService,
      'disponibilite': disponibilite,
    });
    return map;
  }
}