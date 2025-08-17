class Produit {
  final int id;
  final String titre;
  final String description;
  final int prix;
  final String image;

  Produit({
    required this.id,
    required this.titre,
    required this.description,
    required this.prix,
    required this.image,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      prix: json['prix'],
      image: json['image'],
    );
  }
}