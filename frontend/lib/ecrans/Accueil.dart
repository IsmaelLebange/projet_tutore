import 'package:flutter/material.dart';
import 'package:frontend/composants/BarrePrincipale.dart';
import 'package:frontend/ecrans/annonces/DetailsProduit.dart';
import 'package:frontend/ecrans/annonces/DetailsService.dart';
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
  final TextEditingController _textEditingController = TextEditingController();
  late Future<(List<Annonce>, List<Annonce>, List<String>)?> _annoncesFuture;

  bool _estEnRecherche = false;

  @override
  void initState() {
    super.initState();
    _annoncesFuture = _accueilService.obtenirDonnees();
  }

  void lancerRecherche() {
    print("Bouton cliqué");
    setState(() {
      // On trim pour éviter les recherches vides
      String query = _textEditingController.text.trim();
      _estEnRecherche = query.isNotEmpty;

      _annoncesFuture = _accueilService.obtenirDonnees(recherche: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarrePrincipale(titre: "Accueil"),
      drawer: MenuPrincipal(), // Ajoute const si possible
      body: FutureBuilder<(List<Annonce>, List<Annonce>, List<String>)?>(
        future: _annoncesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final (annonces, tendances, categories) = snapshot.data!;

            // Conversion en Map pour tes composants existants
            final tendanceMaps = tendances.map((e) => e.toJson()).toList();
            final annoncesMaps = annonces.map((e) => e.toJson()).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChampRecherche(
                    controller: _textEditingController,
                    recherche: lancerRecherche,
                  ),
                  const SizedBox(height: 16),

                  // On cache les catégories et tendances si on fait une recherche pour gagner de la place
                  if (!_estEnRecherche) ...[
                    BarreCategories(categories: categories),
                    const SizedBox(height: 24),
                    const TitreSection(titre: "Tendance 🔥"),
                    ListeAnnonces(
                      annonces: tendanceMaps,
                      onTap: _gererNavigation,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Titre dynamique
                  TitreSection(
                    titre: _estEnRecherche
                        ? "Résultats pour \"${_textEditingController.text}\" 🔍"
                        : "Dernières annonces 🛒",
                  ),

                  if (annoncesMaps.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Aucun résultat trouvé."),
                    )
                  else
                    ListeAnnonces(
                      annonces: annoncesMaps,
                      onTap: _gererNavigation,
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Aucune donnée trouvée.'));
          }
        },
      ),
    );
  }

 void _gererNavigation(Map<String, dynamic> annonce) {
    final id = annonce['id'] as int?;
    final type = annonce['type']; // "Produit" ou "Service"

    if (id == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => type == "Produit"
            ? DetailsProduit(produitId: id)
            : DetailsService(serviceId: id),
      ),
    );
  }
}
