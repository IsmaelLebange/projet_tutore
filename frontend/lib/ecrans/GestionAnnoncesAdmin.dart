// DANS ecrans/GestionAnnoncesAdmin.dart

import 'package:flutter/material.dart';
import 'package:frontend/composants/AdminGate.dart';
import '../composants/BarrePrincipale.dart';
import '../models/Annonce.dart';
// Note: Tu devras ajuster les imports Produit et Service si nécessaire
// import '../models/Produit.dart'; 
// import '../models/Service.dart'; 

class GestionAnnoncesAdmin extends StatelessWidget {
  const GestionAnnoncesAdmin({super.key});

  // 🔥 MOCK: Simule les annonces à modérer (en attente ou actives)
  final List<Map<String, dynamic>> annoncesAModerer = const [
    {'id': 201, 'titre': 'Drone pro à vendre', 'utilisateur': 'Alice', 'statut': 'En attente'},
    {'id': 202, 'titre': 'Service de jardinage', 'utilisateur': 'Bob', 'statut': 'Actif'},
    {'id': 203, 'titre': 'PC Gamer d\'occasion', 'utilisateur': 'Charlie', 'statut': 'Bloqué'},
  ];

  @override
  Widget build(BuildContext context) {
    return AdminGate(child:  Scaffold(
      appBar: const BarrePrincipale(titre: "Gérer les Annonces"),
      drawer: MenuPrincipal(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  "Liste des annonces nécessitant une action :",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...annoncesAModerer.map((annonce) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        annonce['statut'] == 'En attente' ? Icons.access_time : (annonce['statut'] == 'Bloqué' ? Icons.block : Icons.check_circle),
                        color: annonce['statut'] == 'En attente' ? Colors.orange : (annonce['statut'] == 'Bloqué' ? Colors.red : Colors.green),
                      ),
                      title: Text(annonce['titre']),
                      subtitle: Text("Par ${annonce['utilisateur']} | Statut: ${annonce['statut']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () => print("Voir annonce ${annonce['id']}"),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => print("Supprimer annonce ${annonce['id']}"),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}