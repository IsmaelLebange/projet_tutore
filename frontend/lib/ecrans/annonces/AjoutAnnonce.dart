import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:io';
import '../../services/annonceService.dart';
import '../../models/Produit.dart';
import '../../models/Service.dart';
import '../../composants/BarrePrincipale.dart';
import '../../composants/UserGate.dart';

class AjoutAnnonce extends StatefulWidget {
  @override
  _AjoutAnnonceState createState() => _AjoutAnnonceState();
}

class _AjoutAnnonceState extends State<AjoutAnnonce> {
  final _formKey = GlobalKey<FormState>();
  final _annonceService = AnnonceService();

  String _titre = "";
  String _description = "";
  double _prix = 0;
  String _type = "produit";
  String _categorie = "";
  String _typeSpecifique = "";
  List<PlatformFile> _images = [];

  Map<String, Map<String, List<String>>> _donnees = {
    "produit": {},
    "service": {},
  };

  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _chargerCategoriesDepuisBackend();
  }

  Future<void> _chargerCategoriesDepuisBackend() async {
    try {
      print('🟡 Début chargement catégories...');
      final data = await _annonceService.obtenirCategoriesEtTypes();
      print('🟡 Données reçues: $data');

      setState(() {
        _donnees = data;
        _categorie = _donnees[_type]!.keys.first;
        _typeSpecifique = _donnees[_type]![_categorie]!.first;
        _chargement = false;
      });

      print('🟡 Chargement terminé avec succès');
    } catch (e, stackTrace) {

      setState(() {
        _chargement = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur détaillée: $e :$stackTrace")));
    }
  }

  Future<void> _choisirImages() async {
    final imgs = await _annonceService.choisirImages();
    setState(() => _images = imgs);
  }

  Future<void> _soumettreAnnonce() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      final annonce = (_type == "produit")
          ? Produit(
              id: null,
              titre: _titre,
              description: _description,
              prix: _prix,
              image: "",
              typeProduit: _typeSpecifique,
              categorieProduit: _categorie,
            )
          : Service(
              id: null,
              titre: _titre,
              description: _description,
              prix: _prix,
              image: "",
              typeService: _typeSpecifique,
              categorieService: _categorie,
            );

      await _annonceService.ajouterAnnonce(annonce: annonce, images: _images);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Annonce ajoutée avec succès ✅")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chargement || _donnees[_type]!.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return UserGate( 
      child: Scaffold(
      appBar: const BarrePrincipale(titre: "Ajouter une annonce"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Titre",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Titre requis" : null,
                onSaved: (v) => _titre = v!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? "Description requise" : null,
                onSaved: (v) => _description = v!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Prix",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || double.tryParse(v) == null
                    ? "Prix invalide"
                    : null,
                onSaved: (v) => _prix = double.parse(v!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: "produit", child: Text("Produit")),
                  DropdownMenuItem(value: "service", child: Text("Service")),
                ],
                onChanged: (v) {
                  setState(() {
                    _type = v!;
                    _categorie = _donnees[_type]!.keys.first;
                    _typeSpecifique = _donnees[_type]![_categorie]!.first;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Type",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _categorie,
                items: _donnees[_type]!.keys
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _categorie = v!;
                    _typeSpecifique = _donnees[_type]![_categorie]!.first;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Catégorie",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _typeSpecifique,
                items: _donnees[_type]![_categorie]!
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _typeSpecifique = v!),
                decoration: const InputDecoration(
                  labelText: "Type spécifique",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _choisirImages,
                icon: const Icon(Icons.image),
                label: Text(
                  _images.isEmpty
                      ? "Choisir des images"
                      : "${_images.length} image(s) sélectionnée(s)",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _soumettreAnnonce,
                icon: const Icon(Icons.add_circle),
                label: const Text("Publier l'annonce"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
