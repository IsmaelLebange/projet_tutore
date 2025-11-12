import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ✅ AJOUT
import '../models/Produit.dart';
import '../ecrans/annonces/DetailsProduit.dart';

class CarteProduit extends StatelessWidget {
  final Produit produit;

  const CarteProduit({required this.produit, super.key});

  // ✅ Fix URL image (kIsWeb pour Android)
  String _imageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
    return '$baseUrl${url.startsWith('/') ? '' : '/'}$url';
  }

  @override
  Widget build(BuildContext context) {
    final img = _imageUrl(produit.image);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: InkWell(
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
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: img.isEmpty
                    ? Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      )
                    : Image.network(
                        img,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // ✅ Infos produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produit.titre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${produit.prix.toStringAsFixed(0)} FC",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      produit.categorieProduit,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // ✅ Bouton Ajouter au panier
              IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.orange),
                onPressed: () {
                  // TODO: Logique ajout panier
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${produit.titre} ajouté au panier'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}