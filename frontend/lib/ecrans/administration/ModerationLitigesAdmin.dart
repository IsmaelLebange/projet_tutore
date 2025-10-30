
import 'package:flutter/material.dart';
import 'package:frontend/composants/AdminGate.dart';
import '../../composants/BarrePrincipale.dart';

class ModerationLitigesAdmin extends StatelessWidget {
  const ModerationLitigesAdmin({super.key});

  final List<Map<String, dynamic>> litiges = const [
    {'id': 401, 'sujet': 'Article non conforme (iPhone 14)', 'statut': 'Ouvert', 'urgence': 'Haute'},
    {'id': 402, 'sujet': 'Paiement non reçu (Cours de maths)', 'statut': 'En cours', 'urgence': 'Moyenne'},
    {'id': 403, 'sujet': 'Problème de communication', 'statut': 'Fermé', 'urgence': 'Basse'},
  ];

  @override
  Widget build(BuildContext context) {
    return AdminGate(child:  Scaffold(
      appBar: const BarrePrincipale(titre: "Modération des Litiges"),
      drawer: MenuPrincipal(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: litiges.map((litige) {
                Color color = litige['urgence'] == 'Haute' ? Colors.red : (litige['urgence'] == 'Moyenne' ? Colors.orange : Colors.green);
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.error, color: color),
                    title: Text(litige['sujet'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Statut: ${litige['statut']} | Urgence: ${litige['urgence']}"),
                    trailing: ElevatedButton(
                      onPressed: () => print("Traiter litige ${litige['id']}"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Traiter"),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    ));
  }
}