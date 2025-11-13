import 'package:flutter/material.dart';
import 'package:frontend/composants/BarrePrincipale.dart'; 
import '../composants/ChampRecherche.dart';
import '../composants/BarreCategories.dart';
import '../composants/SectionTendance.dart';
import '../composants/ListeAnnonces.dart';
import '../composants/TitreSection.dart';

class Accueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ Données mock pour tester (gardées pour contexte)
    final categories = ["Électronique", "Mode", "Maison", "Services"];
    final List<Map<String, dynamic>> annonces = [
      // ... Tes annonces ici
    ];

    return Scaffold(
      // 🚨 UTILISATION DE TA BARRE PRINCIPALE
      appBar: const BarrePrincipale(titre: "Accueil"), 
      
      drawer: MenuPrincipal(),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChampRecherche(), // 🔎 recherche
            const SizedBox(height: 16),

            // ✅ On passe les catégories
            BarreCategories(categories: categories),
            const SizedBox(height: 24),

            const TitreSection(titre: "Tendance 🔥"),
            SectionTendance(), // ⭐ produits populaires
            const SizedBox(height: 24),

            const TitreSection(titre: "Dernières annonces 🛒"),
            // ✅ On passe la liste des annonces
            ListeAnnonces(annonces: annonces),
          ],
        ),
      ),
    );
  }
}