import 'package:flutter/material.dart';
import '../models/Produit.dart';
import '../models/Service.dart';
import 'CarteProduit.dart';
import 'CarteService.dart';

class ListeAnnonces extends StatelessWidget {
  final List<Map<String, dynamic>> annonces;

  const ListeAnnonces({required this.annonces, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: annonces.map((annonce) {
        if (annonce['type'] == 'Service') {
          final service = Service(
            id: annonce['id'],
            titre: annonce['titre'],
            description: annonce['description'],
            typeService: annonce['typeService'],
            categorieService: annonce['categorieService'],
            prix: annonce['prix'].toDouble(),
            image: annonce['image']
          );
          return CarteService(service: service);
        } else {
          final produit = Produit(
            id: annonce['id'],
            titre: annonce['titre'],
            description: annonce['description'],
            typeProduit: annonce['typeProduit'],
            categorieProduit: annonce['categorieProduit'],
            prix: annonce['prix'],
            image: annonce['image'],
          );
          return CarteProduit(produit: produit);
        }
      }).toList(),
    );
  }
}