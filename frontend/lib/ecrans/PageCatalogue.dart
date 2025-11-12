import 'package:flutter/material.dart';
import 'package:frontend/composants/BarrePrincipale.dart';
import '../composants/FiltreRecherche.dart';
import '../composants/ListeAnnonces.dart';

// ...existing code...
class PageCatalogue extends StatelessWidget {
  final String titrePage;
  final List<Map<String, dynamic>> annonces;
  final void Function(Map<String, dynamic>)? onTap; // ✅ existant
  final void Function(Map<String, dynamic>)? onAddToCart; // ✅ ajout
  final bool showAddToCart; // ✅ ajout

  const PageCatalogue({
    super.key,
    required this.titrePage,
    required this.annonces,
    this.onTap,
    this.onAddToCart, // ✅ ajout
    this.showAddToCart = true, // ✅ ajout
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarrePrincipale(titre: titrePage),
      drawer: MenuPrincipal(),
      body: Column(
        children: [
          FiltreRecherche(),
          Expanded(
            child: SingleChildScrollView(
              child: ListeAnnonces(
                annonces: annonces,
                onTap: onTap,
                onAddToCart: onAddToCart, // ✅ propage
                showAddToCart: showAddToCart, // ✅ propage
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ...existing code...