// ...existing code...
import 'package:flutter/material.dart';
import '../models/Produit.dart';
import '../ecrans/annonces/DetailsProduit.dart';

class CarteProduit extends StatelessWidget {
  final Produit produit;

  const CarteProduit({required this.produit, super.key});

  String _imageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return 'http://localhost:3000${url.startsWith('/') ? '' : '/'}$url';
  }

  @override
  Widget build(BuildContext context) {
    final img = _imageUrl(produit.image);
    return GestureDetector(
      onTap: () {
        if (produit.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsProduit(produitId: produit.id!),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.all(10),
        elevation: 3,
        child: ListTile(
          leading: img.isEmpty
              ? const Icon(Icons.image_not_supported)
              : Image.network(
                  img,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
          title: Text(
            produit.titre,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text("${produit.prix.toStringAsFixed(0)} FC"),
        ),
      ),
    );
  }
}
// ...existing code...