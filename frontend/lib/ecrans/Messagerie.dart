import 'package:flutter/material.dart';
import 'package:frontend/composants/BarrePrincipale.dart';
import 'package:frontend/ecrans/Discussion.dart';
import 'package:frontend/models/Utilisateur.dart';

class Messagerie extends StatelessWidget {
  // Utilisateur connecté (à remplacer par ton vrai user plus tard)
  final Utilisateur utilisateurActuel = Utilisateur(
    id: 1,
    nom: "Dupont",
    prenom: "Jean",
    email: "jean.dupont@email.com",
    typeConnexion: "classique",
    dateCreation: DateTime.now(),
    actif: true,
  );

  // Liste des conversations
  final List<Utilisateur> conversations = [
    Utilisateur(
      id: 2,
      nom: "Martin",
      prenom: "Alice",
      email: "alice@email.com",
      typeConnexion: "classique",
      dateCreation: DateTime.now(),
      actif: true,
    ),
    Utilisateur(
      id: 3,
      nom: "Durand",
      prenom: "Pierre",
      email: "pierre@email.com", 
      typeConnexion: "classique",
      dateCreation: DateTime.now(),
      actif: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🚨 Utilisation de BarrePrincipale pour la cohérence
      appBar: const BarrePrincipale(titre: "Messagerie"),
      
      // Pour une page de niveau principal comme la messagerie, on garde le Drawer
      drawer: MenuPrincipal(), 
      
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final contact = conversations[index];
          return ListTile(
            // ... (Liste d'éléments de conversation inchangée) ...
            leading: CircleAvatar(
              child: Text("${contact.prenom[0]}${contact.nom[0]}"),
            ),
            title: Text("${contact.prenom} ${contact.nom}"),
            subtitle: const Text("Dernier message..."),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Discussion(
                    utilisateurActuel: utilisateurActuel,
                    autreUtilisateur: contact,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}