class ComptePaiement {
  final int id;
  final String numeroCompte;
  final String entreprise;
  final bool estPrincipal;
  final int idUtilisateur;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComptePaiement({
    required this.id,
    required this.numeroCompte,
    required this.entreprise,
    required this.estPrincipal,
    required this.idUtilisateur,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComptePaiement.fromJson(Map<String, dynamic> json) {
    return ComptePaiement(
      id: json['id'] as int,
      numeroCompte: json['numero_compte'] as String,
      entreprise: json['entreprise'] as String,
      estPrincipal: json['est_principal'] as bool,
      idUtilisateur: json['id_utilisateur'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_compte': numeroCompte,
      'entreprise': entreprise,
      'est_principal': estPrincipal,
      'id_utilisateur': idUtilisateur,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}