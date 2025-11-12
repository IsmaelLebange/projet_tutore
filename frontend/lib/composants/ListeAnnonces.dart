import 'package:flutter/material.dart';
import '../models/Produit.dart';
import '../models/Service.dart';
import 'CarteProduit.dart';
import 'CarteService.dart';

class ListeAnnonces extends StatelessWidget {
  final List<Map<String, dynamic>> annonces;
  final void Function(Map<String, dynamic>)? onTap; // ✅ AJOUT

  const ListeAnnonces({
    required this.annonces,
    this.onTap, // ✅ AJOUT
    super.key,
  });

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
          return GestureDetector(
            onTap: onTap != null ? () => onTap!(annonce) : null, // ✅ AJOUT
            child: CarteService(service: service),
          );
        } else {
          final produit = Produit(
            id: annonce['id'],
            titre: annonce['titre'],
            description: annonce['description'],
            typeProduit: annonce['typeProduit'],
            categorieProduit: annonce['categorieProduit'],
            etat: annonce['etat'], // ✅ AJOUT (si présent)
            prix: annonce['prix'],
            image: annonce['image'],
          );
          return GestureDetector(
            onTap: onTap != null ? () => onTap!(annonce) : null, // ✅ AJOUT
            child: CarteProduit(produit: produit),
          );
        }
      }).toList(),
    );
  }
}