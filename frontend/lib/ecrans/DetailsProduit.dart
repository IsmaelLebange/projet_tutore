import 'package:flutter/material.dart';
import '../models/Produit.dart';

class DetailsProduit extends StatelessWidget {
  final Produit produit;

  const DetailsProduit({required this.produit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(produit.titre)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(produit.image, height: 200, width: double.infinity, fit: BoxFit.cover),
            SizedBox(height: 20),
            Text(produit.titre, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("${produit.prix} FCFA", style: TextStyle(fontSize: 20, color: Colors.green)),
            SizedBox(height: 20),
            Text(produit.description),
          ],
        ),
      ),
    );
  }
}
