class LignePanier {
  final int id;
  final int quantite;
  final String type; // 'Produit' ou 'Service'
  final int itemId;
  final int annonceId;
  final String titre;
  final String description;
  final double prixUnitaire;
  final double sousTotal;
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
      prixUnitaire: (json['prixUnitaire'] as num).toDouble(),
      sousTotal: (json['sousTotal'] as num).toDouble(),
      image: json['image'],
      vendeur: json['vendeur'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
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