import 'package:flutter/material.dart';
import 'package:frontend/composants/BarrePrincipale.dart';
import 'package:frontend/models/Annonce.dart';
import '../composants/ChampRecherche.dart';
import '../composants/BarreCategories.dart';
import '../composants/SectionTendance.dart';
import '../composants/ListeAnnonces.dart';
import '../composants/TitreSection.dart';
import '../services/accueilService.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  final AccueilService _accueilService = AccueilService();
  late final Future<List<Annonce>?> _annoncesFuture;
  @override
  void initState() {
    super.initState();
    _annoncesFuture = _accueilService.obtenirDonnees();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Données mock pour tester (gardées pour contexte)
    final categories = ["Électronique", "Mode", "Maison", "Services"];

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
            FutureBuilder<List<Annonce>?>(
              future: _annoncesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data != null) {
                  final List<Map<String, dynamic>> annoncesMaps = snapshot.data!
                      .map((annonce) => annonce.toJson())
                      .toList();

                  return ListeAnnonces(annonces: annoncesMaps);
                } else {
                  return const Center(child: Text('Aucune annonce trouvée.'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
