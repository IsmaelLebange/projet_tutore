import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../models/Produit.dart';
import '../PageCatalogue.dart'; 

class CatalogueProduits extends StatefulWidget {
  @override
  _CatalogueProduitsState createState() => _CatalogueProduitsState();
}

class _CatalogueProduitsState extends State<CatalogueProduits> {
  late Future<List<Produit>> produits;

  @override
  void initState() {
    super.initState();
    produits = Api().getProduits();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Produit>>(
      future: produits,
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text("Catalogue Produits")),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("Catalogue Produits")),
            body: Center(child: Text("Erreur : ${snapshot.error}")),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text("Catalogue Produits")),
            body: Center(child: Text("Aucun produit trouvé")),
          );
        }

        // ✅ On passe les produits au PageCatalogue
        final annonces = snapshot.data!
            .map((p) => {
                  "type": "Produit",
                  "id": p.id,
                  "titre": p.titre,
                  "description": p.description,
                  "typeProduit":p.typeProduit,
                  "categorieProduit":p.categorieProduit,
                  "prix": p.prix,
                  "image": p.image,
                })
            .toList();

        return PageCatalogue(
          titrePage: "Catalogue Produits",
          annonces: annonces,
        );
      },
    );
  }
}
