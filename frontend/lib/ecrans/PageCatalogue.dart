// DANS PageCatalogue.dart

import 'package:flutter/material.dart';
import 'package:frontend/composants/BarrePrincipale.dart'; 
import '../composants/FiltreRecherche.dart';
import '../composants/ListeAnnonces.dart';
// Note : MenuPrincipal est dans BarrePrincipale.dart

class PageCatalogue extends StatelessWidget {
  final String titrePage;
  final List<Map<String, dynamic>> annonces;

  const PageCatalogue({super.key, required this.titrePage, required this.annonces});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🚨 UTILISATION DE TA BARRE PRINCIPALE pour la cohérence
      appBar: BarrePrincipale(titre: titrePage),
      
      // 🚨 UTILISATION DE TON MENU PRINCIPAL
      drawer: MenuPrincipal(), 
      
      body: Column(
        children: [
          FiltreRecherche(),
          Expanded(
            child: SingleChildScrollView(
              child: ListeAnnonces(annonces: annonces),
            ),
          ),
        ],
      ),
    );
  }
}