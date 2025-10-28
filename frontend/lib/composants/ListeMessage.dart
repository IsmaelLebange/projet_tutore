import 'package:flutter/material.dart';
import '../models/Message.dart';
import '../utils/constantes.dart';

class ListeMessages extends StatelessWidget {
  final List<Message> messages;
  final int idUtilisateurActuel;

  const ListeMessages({
    super.key,
    required this.messages,
    required this.idUtilisateurActuel,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      reverse: true, // 🔄 affiche les plus récents en bas
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMoi = msg.expediteur.id == idUtilisateurActuel;

        return Align(
          alignment: isMoi ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMoi ? couleurPrincipale.withOpacity(0.85) : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment:
                  isMoi ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  msg.contenu,
                  style: TextStyle(
                    color: isMoi ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${msg.dateEnvoi.hour.toString().padLeft(2, '0')}:${msg.dateEnvoi.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: 11,
                    color: isMoi ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
