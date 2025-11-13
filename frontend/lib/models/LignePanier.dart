class LignePanier {
  final int id;
  final int quantite;
  final String type;
  final int itemId;
  final int annonceId;
  final String titre;
  final String description;
  final num prixUnitaire;
  final num sousTotal;
  final String? image;
  final Map<String, dynamic> vendeur;

  LignePanier({
    required this.id,
    required this.quantite,
    required this.type,
    required this.itemId,
    required this.annonceId,
    required this.titre,
    required this.description,
    required this.prixUnitaire,
    required this.sousTotal,
    this.image,
    required this.vendeur,
  });

  factory LignePanier.fromJson(Map<String, dynamic> json) {
    return LignePanier(
      id: json['id'],
      quantite: json['quantite'],
      type: json['type'],
      itemId: json['itemId'],
      annonceId: json['annonceId'],
      titre: json['titre'],
      description: json['description'],
      prixUnitaire: json['prixUnitaire'],
      sousTotal: json['sousTotal'],
      image: json['image'],
      vendeur: json['vendeur'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantite': quantite,
      'type': type,
      'itemId': itemId,
      'annonceId': annonceId,
      'titre': titre,
      'description': description,
      'prixUnitaire': prixUnitaire,
      'sousTotal': sousTotal,
      'image': image,
      'vendeur': vendeur,
    };
  }
}