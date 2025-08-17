import 'package:flutter/material.dart';
import '../models/Produit.dart';

class CarteProduit extends StatelessWidget {
  final Produit produit;

  const CarteProduit({required this.produit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Image.network(produit.image, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(produit.titre, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${produit.prix} FCFA"),
      ),
    );
  }
}

