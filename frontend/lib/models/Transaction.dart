class TransactionModel {
  final int id;
  final String code;
  final DateTime dateTransaction;
  final double montant;
  final double commission;
  final String statut;
  final String role; // 'acheteur' ou 'vendeur'
  final int nbArticles;
  final String? premiereImage;
  final Partie acheteur;
  final Partie vendeur;

  TransactionModel({
    required this.id,
    required this.code,
    required this.dateTransaction,
    required this.montant,
    required this.commission,
    required this.statut,
    required this.role,
    required this.nbArticles,
    this.premiereImage,
    required this.acheteur,
    required this.vendeur,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      code: json['code'],
      dateTransaction: DateTime.parse(json['dateTransaction']),
      montant: (json['montant'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      statut: json['statut'],
      role: json['role'],
      nbArticles: json['nbArticles'],
      premiereImage: json['premiereImage'],
      acheteur: Partie.fromJson(json['acheteur']),
      vendeur: Partie.fromJson(json['vendeur']),
    );
  }
}

class Partie {
  final int id;
  final String nom;
  final String email;
  final String? telephone;

  Partie({
    required this.id,
    required this.nom,
    required this.email,
    this.telephone,
  });

  factory Partie.fromJson(Map<String, dynamic> json) {
    return Partie(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
    );
  }
}

class DetailTransaction {
  final int id;
  final String code;
  final DateTime dateTransaction;
  final double montant;
  final double commission;
  final double montantNet;
  final String statut;
  final bool confirmationAcheteur;
  final bool confirmationVendeur;
  final String role;
  final PartieDetail acheteur;
  final PartieDetail vendeur;
  final ComptePaiement? comptePaiement;
  final List<Article> articles;

  DetailTransaction({
    required this.id,
    required this.code,
    required this.dateTransaction,
    required this.montant,
    required this.commission,
    required this.montantNet,
    required this.statut,
    required this.confirmationAcheteur,
    required this.confirmationVendeur,
    required this.role,
    required this.acheteur,
    required this.vendeur,
    this.comptePaiement,
    required this.articles,
  });

  factory DetailTransaction.fromJson(Map<String, dynamic> json) {
    return DetailTransaction(
      id: json['id'],
      code: json['code'],
      dateTransaction: DateTime.parse(json['dateTransaction']),
      montant: (json['montant'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      montantNet: (json['montantNet'] as num).toDouble(),
      statut: json['statut'],
      confirmationAcheteur: json['confirmationAcheteur'] ?? false,
      confirmationVendeur: json['confirmationVendeur'] ?? false,
      role: json['role'],
      acheteur: PartieDetail.fromJson(json['acheteur']),
      vendeur: PartieDetail.fromJson(json['vendeur']),
      comptePaiement: json['comptePaiement'] != null
          ? ComptePaiement.fromJson(json['comptePaiement'])
          : null,
      articles: (json['articles'] as List)
          .map((a) => Article.fromJson(a))
          .toList(),
    );
  }
}

class PartieDetail extends Partie {
  final double reputation;
  final AdresseModel? adresse;

  PartieDetail({
    required super.id,
    required super.nom,
    required super.email,
    super.telephone,
    required this.reputation,
    this.adresse,
  });

  factory PartieDetail.fromJson(Map<String, dynamic> json) {
    return PartieDetail(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      reputation: (json['reputation'] as num?)?.toDouble() ?? 0.0,
      adresse: json['adresse'] != null
          ? AdresseModel.fromJson(json['adresse'])
          : null,
    );
  }
}

class AdresseModel {
  final String commune;
  final String? quartier;
  final String? rue;

  AdresseModel({
    required this.commune,
    this.quartier,
    this.rue,
  });

  factory AdresseModel.fromJson(Map<String, dynamic> json) {
    return AdresseModel(
      commune: json['commune'],
      quartier: json['quartier'],
      rue: json['rue'],
    );
  }

  String get complet {
    final parts = <String>[commune];
    if (quartier != null && quartier!.isNotEmpty) parts.add(quartier!);
    if (rue != null && rue!.isNotEmpty) parts.add(rue!);
    return parts.join(', ');
  }
}

class ComptePaiement {
  final String entreprise;
  final String numeroCompte;

  ComptePaiement({
    required this.entreprise,
    required this.numeroCompte,
  });

  factory ComptePaiement.fromJson(Map<String, dynamic> json) {
    return ComptePaiement(
      entreprise: json['entreprise'],
      numeroCompte: json['numeroCompte'],
    );
  }
}

class Article {
  final int id;
  final String type;
  final String titre;
  final String description;
  final double prixUnitaire;
  final int quantite;
  final double sousTotal;
  final String etat;
  final List<String> images;
  final AdresseModel? adresse;

  Article({
    required this.id,
    required this.type,
    required this.titre,
    required this.description,
    required this.prixUnitaire,
    required this.quantite,
    required this.sousTotal,
    required this.etat,
    required this.images,
    this.adresse,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      type: json['type'],
      titre: json['titre'],
      description: json['description'],
      prixUnitaire: (json['prixUnitaire'] as num).toDouble(),
      quantite: json['quantite'],
      sousTotal: (json['sousTotal'] as num).toDouble(),
      etat: json['etat'],
      images: List<String>.from(json['images'] ?? []),
      adresse: json['adresse'] != null
          ? AdresseModel.fromJson(json['adresse'])
          : null,
    );
  }
}