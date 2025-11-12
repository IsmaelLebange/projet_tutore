import 'package:flutter/material.dart';
import '../../services/serviceService.dart';
import '../../models/Service.dart';
import '../PageCatalogue.dart';
import 'DetailsService.dart';

class CatalogueServices extends StatefulWidget {
  @override
  _CatalogueServicesState createState() => _CatalogueServicesState();
}

class _CatalogueServicesState extends State<CatalogueServices> {
  final ServiceService _serviceService = ServiceService();
  late Future<List<Service>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _serviceService.obtenirServices();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Service>>(
      future: _servicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text("Catalogue Services")),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Catalogue Services")),
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
                        _servicesFuture = _serviceService.obtenirServices();
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
            appBar: AppBar(title: const Text("Catalogue Services")),
            body: const Center(child: Text("Aucun service trouvé")),
          );
        }

        final annonces = snapshot.data!
            .map((s) => {
                  "type": "Service",
                  "id": s.id,
                  "titre": s.titre,
                  "description": s.description,
                  "typeService": s.typeService,
                  "categorieService": s.categorieService,
                  "prix": s.prix,
                  "image": s.image,
                  "disponibilite": s.disponibilite,
                  "etat": s.etat,
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