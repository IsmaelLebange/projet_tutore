import 'package:flutter/material.dart';
import '../models/Produit.dart';
import '../ecrans/annonces/DetailsProduit.dart';

class CarteProduit extends StatelessWidget {
  final Produit produit;

  const CarteProduit({required this.produit, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsProduit(produit: produit),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 3,
        child: ListTile(
          leading: Image.network(
            produit.image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          title: Text(produit.titre, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${produit.prix} FCFA"),
        ),
      ),
    );
  }
}
