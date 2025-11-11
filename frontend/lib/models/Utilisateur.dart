import 'package:frontend/models/Adresse.dart';

class Utilisateur {
  final int? id;
  final String nom; 
  final String prenom; 
  final String email;
  final String? telephone; 
  final String? photoProfil; // URL de la photo principale (computed)
  final List<String>? photos; // ✅ AJOUT : liste des URLs
  final String? motDePasse; 
  final String? typeConnexion;
  final DateTime? dateCreation;
  final String etat;
  final Adresse? adresse;  
  final String? role; 

  Utilisateur({
    this.id,
    required this.nom, 
    required this.prenom, 
    required this.email,
    this.telephone,
    this.photoProfil,
    this.photos, // ✅ AJOUT
    this.motDePasse,
    this.typeConnexion,
    this.dateCreation,
    required this.etat,
    this.adresse, 
    this.role,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    final nom = (json['nom'] ?? '') as String;
    final prenom = (json['prenom'] ?? '') as String;

    // ✅ Parse adresse (cherche 'adresseFixe' d'abord, puis 'adresse_fixe')
    final adresseJson = json['adresseFixe'] as Map<String, dynamic>? 
        ?? json['adresse_fixe'] as Map<String, dynamic>?;
    
    final idValue = json['id'] ?? json['_id'];
    final id = (idValue is num) 
        ? idValue.toInt() 
        : int.tryParse(idValue?.toString() ?? '0') ?? 0;

    // ✅ Parse photos (cherche 'photos' du backend)
    List<String>? photosList;
    if (json['photos'] != null && json['photos'] is List) {
      photosList = (json['photos'] as List)
          .map((p) => (p['url'] ?? '').toString())
          .where((url) => url.isNotEmpty)
          .toList();
    }

    // ✅ Photo principale = première photo OU photo_profil legacy
    String? photoPrincipale;
    if (photosList != null && photosList.isNotEmpty) {
      photoPrincipale = photosList.first;
    } else if (json['photo_profil'] != null) {
      photoPrincipale = json['photo_profil'].toString();
    }
    
    return Utilisateur(
      id: id, 
      nom: nom,
      prenom: prenom,
      email: json['email'] ?? '',
      telephone: json['numero_de_telephone'] ?? json['telephone'],
      photoProfil: photoPrincipale,
      photos: photosList, // ✅ AJOUT
      motDePasse: json['mot_de_passe'] ?? json['motDePasse'], 
      typeConnexion: json['type_connexion'] ?? json['typeConnexion'] ?? 'classique',
      dateCreation: DateTime.tryParse(json['date_inscription'] ?? json['dateCreation'] ?? '') ?? DateTime.now(),
      etat: json['etat'] ?? "Actif",
      adresse: adresseJson != null ? Adresse.fromJson(adresseJson) : null,
      role: json['role'] ?? 'utilisateur',
    );
  }

  String get nomComplet => '$prenom $nom'; 

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom, 
      'prenom': prenom, 
      'email': email,
      'telephone': telephone,
      'photoProfil': photoProfil,
      'photos': photos, // ✅ AJOUT
      'motDePasse': motDePasse,
      'typeConnexion': typeConnexion,
      'dateCreation': dateCreation?.toIso8601String(),
      'etat': etat,
      'adresse_fixe': adresse?.toJson(),
      'role': role,
    };
  }

  factory Utilisateur.fromGoogle(Map<String, dynamic> googleUser) {
    final nomComplet = googleUser['nomComplet'] ?? googleUser['displayName'] ?? '';
    final parts = nomComplet.split(' ');
    final id = int.tryParse(googleUser['id']?.toString() ?? '0') ?? 0;

    return Utilisateur(
      id: id,
      prenom: parts.isNotEmpty ? parts.first : '',
      nom: parts.length > 1 ? parts.sublist(1).join(' ') : '',
      email: googleUser['email'] ?? '',
      telephone: googleUser['telephone'],
      photoProfil: googleUser['photoProfil'],
      photos: null,
      motDePasse: null, 
      typeConnexion: 'google',
      dateCreation: DateTime.now(),
      etat: "Actif",
      adresse: null, 
    );
  }

  factory Utilisateur.fromFacebook(Map<String, dynamic> fbUser) {
    final nomComplet = fbUser['nomComplet'] ?? fbUser['name'] ?? '';
    final parts = nomComplet.split(' ');
    final id = int.tryParse(fbUser['id']?.toString() ?? '0') ?? 0;

    return Utilisateur(
      id: id,
      prenom: parts.isNotEmpty ? parts.first : '',
      nom: parts.length > 1 ? parts.sublist(1).join(' ') : '',
      telephone: fbUser['telephone'],
      email: fbUser['email'] ?? '',
      photoProfil: fbUser['photoProfil'],
      photos: null,
      motDePasse: null,
      typeConnexion: 'facebook',
      dateCreation: DateTime.now(),
      etat: "Actif",
      adresse: null,
    );
  }
}