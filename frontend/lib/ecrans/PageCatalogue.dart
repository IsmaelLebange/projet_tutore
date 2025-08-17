import 'package:flutter/material.dart';
import '../composants/BarrePrincipale.dart';
import '../composants/FiltreRecherche.dart';
import '../composants/ListeAnnonces.dart';

class PageCatalogue extends StatelessWidget {
  final String titrePage;
  final List<Map<String, dynamic>> annonces;

  PageCatalogue({required this.titrePage, required this.annonces});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titrePage),
        centerTitle: true,
      ),
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
