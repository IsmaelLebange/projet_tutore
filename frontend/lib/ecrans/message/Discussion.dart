import 'package:flutter/material.dart';
import '../../models/Message.dart';
import '../../models/Utilisateur.dart';
import '../../composants/ListeMessages.dart';
import '../../utils/constantes.dart';

class Discussion extends StatefulWidget {
  final Utilisateur utilisateurActuel;
  final Utilisateur autreUtilisateur;

  const Discussion({
    super.key,
    required this.utilisateurActuel,
    required this.autreUtilisateur,
  });

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();

    // 🧠 Exemple de messages mock
    _messages.addAll([
      Message(
        contenu: "Yo frérot 👊",
        dateEnvoi: DateTime.now().subtract(const Duration(minutes: 5)),
        expediteur: widget.autreUtilisateur,
        recepteur: widget.utilisateurActuel,
      ),
      Message(
        contenu: "Tranquille et toi ?",
        dateEnvoi: DateTime.now().subtract(const Duration(minutes: 3)),
        expediteur: widget.utilisateurActuel,
        recepteur: widget.autreUtilisateur,
      ),
    ]);
  }

  void _envoyerMessage() {
    if (_controller.text.trim().isEmpty) return;

    final nouveauMessage = Message(
      contenu: _controller.text.trim(),
      dateEnvoi: DateTime.now(),
      expediteur: widget.utilisateurActuel,
      recepteur: widget.autreUtilisateur,
    );

    setState(() {
      _messages.insert(0, nouveauMessage);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.autreUtilisateur.nom),
        backgroundColor: couleurPrincipale,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListeMessages(
              messages: _messages,
              idUtilisateurActuel: widget.utilisateurActuel.id,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Écrire un message...",
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _envoyerMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
