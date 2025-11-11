// DANS PageCatalogue.dart

import 'package:flutter/material.dart';
import 'package:frontend/composants/BarrePrincipale.dart'; 
import '../composants/FiltreRecherche.dart';
import '../composants/ListeAnnonces.dart';
// Note : MenuPrincipal est dans BarrePrincipale.dart

// ...existing code...
class PageCatalogue extends StatelessWidget {
  final String titrePage;
  final List<Map<String, dynamic>> annonces;
  final void Function(Map<String, dynamic>)? onTap; // ✅ ajout

  const PageCatalogue({
    super.key,
    required this.titrePage,
    required this.annonces,
    this.onTap, // ✅ ajout
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
                onTap: onTap, // ✅ propage à la liste
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ...existing code...