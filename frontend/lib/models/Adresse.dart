class Adresse {
  final String? rue;
  final String? quartier;
  final String? commune;
  final double? latitude;
  final double? longitude;

  Adresse({
    this.rue, 
     this.quartier, 
    required this.commune,
    this.latitude, 
    this.longitude,
  });

  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      rue: json['rue'] ?? '',
      quartier: json['quartier'] ?? '',
      commune: json['ville'] ?? json['commune'] ?? '', // Assure la compatibilité avec 'ville' si ton backend l'utilise
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rue': rue,
      'quartier': quartier,
      'commune': commune,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
