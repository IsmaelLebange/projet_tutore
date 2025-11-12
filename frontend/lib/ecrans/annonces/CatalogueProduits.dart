// ...existing code...
import 'package:flutter/material.dart';
import '../../services/produitService.dart';
import '../../models/Produit.dart';
import '../PageCatalogue.dart';
import 'DetailsProduit.dart';

class CatalogueProduits extends StatefulWidget {
  @override
  _CatalogueProduitsState createState() => _CatalogueProduitsState();
}

class _CatalogueProduitsState extends State<CatalogueProduits> {
  final ProduitService _produitService = ProduitService();
  late Future<List<Produit>> _produitsFuture;

  @override
  void initState() {
    super.initState();
    _produitsFuture = _produitService.obtenirProduits();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Produit>>(
      future: _produitsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text("Catalogue Produits")),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Catalogue Produits")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Erreur : ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _produitsFuture = _produitService.obtenirProduits();
                      });
                    },
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Catalogue Produits")),
            body: const Center(child: Text("Aucun produit trouvé")),
          );
        }

        final annonces = snapshot.data!
            .map((p) => {
                  "type": "Produit",
                  "id": p.id,
                  "titre": p.titre,
                  "description": p.description,
                  "typeProduit": p.typeProduit,
                  "categorieProduit": p.categorieProduit,
                  "prix": p.prix,
                  "image": p.image,
                  "etat": p.etat,
                  // ✅ singular
                })
            .toList();

        return PageCatalogue(
          titrePage: "Catalogue Produits",
          annonces: annonces,
          onTap: (annonce) {
            final id = annonce['id'] as int?;
            if (id == null) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailsProduit(produitId: id),
              ),
            );
          },
        );
      },
    );
  }
}
// ...existing code...