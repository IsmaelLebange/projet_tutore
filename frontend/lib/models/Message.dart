import 'Utilisateur.dart';

class Message {
  final String contenu;
  final DateTime dateEnvoi;
  final Utilisateur expediteur;
  final Utilisateur recepteur;

  Message({
    required this.contenu,
    required this.dateEnvoi,
    required this.expediteur,
    required this.recepteur,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      contenu: json['contenu'],
      dateEnvoi: DateTime.parse(json['dateEnvoi']),
      expediteur: Utilisateur.fromJson(json['expediteur']),
      recepteur: Utilisateur.fromJson(json['recepteur']),
    );
  }

  Map<String, dynamic> toJson() => {
        'contenu': contenu,
        'dateEnvoi': dateEnvoi.toIso8601String(),
        'expediteur': expediteur.toJson(),
        'recepteur': recepteur.toJson(),
      };
}
