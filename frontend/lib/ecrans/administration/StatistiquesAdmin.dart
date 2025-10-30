// DANS ecrans/StatistiquesAdmin.dart

import 'package:flutter/material.dart';
import 'package:frontend/composants/AdminGate.dart';
import '../../composants/BarrePrincipale.dart';

class StatistiquesAdmin extends StatelessWidget {
  const StatistiquesAdmin({super.key});

  final Map<String, dynamic> stats = const {
    'Total Annonces': 1250,
    'Nouveaux Utilisateurs (30j)': 85,
    'Annonces En Attente': 12,
    'Revenus Estimés (30j)': 5400,
  };

  Widget _buildStatCard(String title, dynamic value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              value.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminGate(child:  Scaffold(
      appBar: const BarrePrincipale(titre: "Statistiques et Rapports"),
      drawer: MenuPrincipal(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2, // 2 cartes par ligne
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              children: [
                _buildStatCard("Total Annonces", stats['Total Annonces'], Icons.receipt_long, Colors.blue),
                _buildStatCard("Nouveaux Utilisateurs (30j)", stats['Nouveaux Utilisateurs (30j)'], Icons.person_add, Colors.green),
                _buildStatCard("Annonces En Attente", stats['Annonces En Attente'], Icons.pending_actions, Colors.orange),
                _buildStatCard("Revenus Estimés (30j)", "${stats['Revenus Estimés (30j)']} €", Icons.monetization_on, Colors.purple),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}