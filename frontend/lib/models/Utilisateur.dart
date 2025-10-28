import 'package:frontend/models/Adresse.dart';

class Utilisateur {
  final int? id; // Changement: int au lieu de String
  final String nom; 
  final String prenom; 
  final String email;
  final String? telephone; 
  final String? photoProfil;
  final String? motDePasse; 
  final String? typeConnexion;
  final DateTime? dateCreation;
  final bool actif;
  final Adresse? adresse;  
  final String? role; 

  Utilisateur({
    this.id,
    required this.nom, 
    required this.prenom, 
    required this.email,
    this.telephone,
    this.photoProfil,
    this.motDePasse,
    this.typeConnexion,
    this.dateCreation,
    required this.actif,
    this.adresse, 
    this.role,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    // Tente d'extraire nom et prénom séparément, sinon utilise nomComplet
    final nom = json['nom'] ;
    final prenom = json['prenom'] ;

    final adresseJson = json['adresse_fixe'] as Map<String, dynamic>?;
    
    final idValue = json['id'] ?? json['_id'];
    final id = (idValue is num) 
        ? idValue.toInt() 
        : int.tryParse(idValue?.toString() ?? '0') ?? 0;
    
    return Utilisateur(
      id: id, 
      nom: nom,
      prenom: prenom,
      email: json['email'] ?? '',
      telephone: json['numero_de_telephone'] ?? json['telephone'],
      photoProfil: json['photo_profil'] ?? json['photoProfil'],
      motDePasse: json['mot_de_passe'] ?? json['motDePasse'], 
      typeConnexion: json['type_connexion'] ?? json['typeConnexion'] ?? 'classique',
      dateCreation:
          DateTime.tryParse(json['date_inscription'] ?? json['dateCreation'] ?? '') ?? DateTime.now(),
      actif: json['actif'] ?? true,
      adresse: adresseJson != null ? Adresse.fromJson(adresseJson) : null,
      role: json['role'] ?? 'utilisateur',
    );
  }

  // Helper pour retourner le nom complet si besoin
  String get nomComplet => '$prenom $nom'; 

  Map<String, dynamic> toJson() {
    return {
      'id': id, // id est de type int
      'nom': nom, 
      'prenom': prenom, 
      'email': email,
      'telephone': telephone,
      'photoProfil': photoProfil,
      'motDePasse': motDePasse,
      'typeConnexion': typeConnexion,
      'dateCreation': dateCreation?.toIso8601String(),
      'actif': actif,
      'adresse_fixe': adresse?.toJson(),
      'role':role,
    };
  }

  factory Utilisateur.fromGoogle(Map<String, dynamic> googleUser) {
    final nomComplet = googleUser['nomComplet'] ?? googleUser['displayName'] ?? '';
    final parts = nomComplet.split(' ');
    
    // L'ID de Google est souvent un String, on utilise 0 par défaut ou on tente la conversion
    final id = int.tryParse(googleUser['id']?.toString() ?? '0') ?? 0;

    return Utilisateur(
      id: id,
      prenom: parts.isNotEmpty ? parts.first : '',
      nom: parts.length > 1 ? parts.sublist(1).join(' ') : '',
      email: googleUser['email'] ?? '',
      telephone: googleUser['telephone'],
      photoProfil: googleUser['photoProfil'],
      motDePasse: null, 
      typeConnexion: 'google',
      dateCreation: DateTime.now(),
      actif: true,
      adresse: null, 
    );
  }

  factory Utilisateur.fromFacebook(Map<String, dynamic> fbUser) {
    final nomComplet = fbUser['nomComplet'] ?? fbUser['name'] ?? '';
    final parts = nomComplet.split(' ');
    
    // L'ID de Facebook est souvent un String, on utilise 0 par défaut ou on tente la conversion
    final id = int.tryParse(fbUser['id']?.toString() ?? '0') ?? 0;

    return Utilisateur(
      id: id,
      prenom: parts.isNotEmpty ? parts.first : '',
      nom: parts.length > 1 ? parts.sublist(1).join(' ') : '',
      telephone: fbUser['telephone'],
      email: fbUser['email'] ?? '',
      photoProfil: fbUser['photoProfil'],
      motDePasse: null,
      typeConnexion: 'facebook',
      dateCreation: DateTime.now(),
      actif: true,
      adresse: null,
    );
  }
}
