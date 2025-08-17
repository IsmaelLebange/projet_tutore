import 'package:flutter/material.dart';
import '../composants/ChampRecherche.dart';
import '../composants/BarreCategories.dart';
import '../composants/SectionTendance.dart';
import '../composants/ListeAnnonces.dart';
import '../composants/TitreSection.dart';

class Accueil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accueil"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChampRecherche(), // 🔎 recherche
            SizedBox(height: 16),

            BarreCategories(), // 📂 catégories
            SizedBox(height: 24),

            TitreSection(titre: "Tendance 🔥"),
            SectionTendance(), // ⭐ produits populaires
            SizedBox(height: 24),

            TitreSection(titre: "Dernières annonces 🛒"),
            ListeAnnonces(), // 📋 liste produits
          ],
        ),
      ),
    );
  }
}
