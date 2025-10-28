import 'package:flutter/material.dart';
import '../services/api.dart';
import '../models/Service.dart';
import 'PageCatalogue.dart';

class CatalogueServices extends StatefulWidget {
  @override
  _CatalogueServicesState createState() => _CatalogueServicesState();
}

class _CatalogueServicesState extends State<CatalogueServices> {
  late Future<List<Service>> services;

  @override
  void initState() {
    super.initState();
    services = Api().getServices();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Service>>(
      future: services,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text("Catalogue Services")),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("Catalogue Services")),
            body: Center(child: Text("Erreur : ${snapshot.error}")),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text("Catalogue Services")),
            body: Center(child: Text("Aucun service trouvé")),
          );
        }

        final annonces = snapshot.data!
            .map((s) => {
                  "type": s.type,
                  "titre": s.titre,
                  "description": s.description,
                  "typeService":s.typeService,
                  "categorieService":s.categorieService,
                  "prix": s.prix,
                  "image":s.image
                })
            .toList();

        return PageCatalogue(
          titrePage: "Catalogue Services",
          annonces: annonces,
        );
      },
    );
  }
}
