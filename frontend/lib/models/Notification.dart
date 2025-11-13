class NotificationModel {
  final int id;
  final String titre;
  final String message;
  final String typeNotification;
  final bool estLu;
  final int idUtilisateur;
  final int? idTransaction;
  final DateTime createdAt;
  final Map<String, dynamic>? transaction;

  NotificationModel({
    required this.id,
    required this.titre,
    required this.message,
    required this.typeNotification,
    required this.estLu,
    required this.idUtilisateur,
    this.idTransaction,
    required this.createdAt,
    this.transaction,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      titre: json['titre'],
      message: json['message'],
      typeNotification: json['type_notification'],
      estLu: json['est_lu'],
      idUtilisateur: json['id_utilisateur'],
      idTransaction: json['id_transaction'],
      createdAt: DateTime.parse(json['createdAt']),
      transaction: json['transaction'],
    );
  }
}