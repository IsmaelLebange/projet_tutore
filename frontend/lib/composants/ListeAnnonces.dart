import 'package:flutter/material.dart';
import 'CarteProduit.dart';
import 'CarteService.dart';
import '../models/Produit.dart';

class ListeAnnonces extends StatelessWidget {
  final List<Map<String, dynamic>> annonces;

  ListeAnnonces({required this.annonces});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: annonces.map((annonce) {
        if (annonce['type'] == 'produit') {
          final produit = Produit(
            id: annonce['id'],
            titre: annonce['titre'],
            description: annonce['description'],
            prix: annonce['prix'],
            image: annonce['image'],
          );
          return CarteProduit(produit: produit);
        } else {
          return CarteService(
            titre: annonce['titre'],
            description: annonce['description'],
            prix: annonce['prix'].toDouble(),
            onTap: () {
              print("Service cliqué: ${annonce['titre']}");
            },
          );
        }
      }).toList(),
    );
  }
}
