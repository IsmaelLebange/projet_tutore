import 'package:flutter/material.dart';
import '../models/Annonce.dart';
import '../models/Produit.dart';
import '../models/Service.dart';
import '../services/annonceService.dart';
import '../composants/BarrePrincipale.dart';

class AjoutAnnonce extends StatefulWidget {
  @override
  _AjoutAnnonceState createState() => _AjoutAnnonceState();
}

class _AjoutAnnonceState extends State<AjoutAnnonce> {
  final _formKey = GlobalKey<FormState>();
  
  // Champs du formulaire
  String _titre = "";
  String _description = "";
  double _prix = 0;
  String _type = "produit";
  String _categorie = "";
  String _typeSpecifique = "";

  // Données pour les dropdowns dépendants
  final Map<String, Map<String, List<String>>> _donneesDependantes = {
    "produit": {
      "Électronique": ["Smartphone", "Ordinateur", "Tablette"],
      "Vêtements": ["Homme", "Femme", "Enfant"],
    },
    "service": {
      "Réparation": ["Électronique", "Véhicule", "Maison"],
      "Cours": ["Scolaire", "Musique", "Sport"],
    },
  };

  @override
  void initState() {
    super.initState();
    // Initialiser les valeurs par défaut
    _categorie = _donneesDependantes[_type]!.keys.first;
    _typeSpecifique = _donneesDependantes[_type]![_categorie]!.first;
  }

  void _soumettreAnnonce() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      Annonce annonce;
      
      if (_type == "produit") {
        annonce = Produit(
          id: null,
          titre: _titre,
          description: _description,
          prix: _prix,
          image: "https://via.placeholder.com/150",
          typeProduit: _categorie,
          categorieProduit: _typeSpecifique,
          dimension: null,
        );
      } else {
        annonce = Service(
          id: null,
          titre: _titre,
          description: _description,
          prix: _prix,
          image: "https://via.placeholder.com/150",
          typeService: _categorie,
          categorieService: _typeSpecifique,
          disponibilite: true,
        );
      }
      
      // Ajouter l'annonce via le service
      AnnonceService().ajouterAnnonce(annonce);

      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Annonce ajoutée avec succès")),
      );
      
      // Retour à l'écran précédent
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarrePrincipale(titre: "Ajouter une annonce"),
      body: Center( // 🚨 Centre le contenu
        child: ConstrainedBox( // 🚨 Ajoute une contrainte de largeur maximale
          constraints: const BoxConstraints(maxWidth: 600), // Max 600px de large
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Champ titre
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Titre de l'annonce",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un titre';
                      }
                      return null;
                    },
                    onSaved: (value) => _titre = value!,
                  ),
                  const SizedBox(height: 16),
                  
                  // Champ description
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une description';
                      }
                      return null;
                    },
                    onSaved: (value) => _description = value!,
                  ),
                  const SizedBox(height: 16),
                  
                  // Champ prix
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Prix (€)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un prix';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Veuillez entrer un prix valide';
                      }
                      return null;
                    },
                    onSaved: (value) => _prix = double.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown type (produit/service)
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: "Type d'annonce",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "produit", child: Text("Produit")),
                      DropdownMenuItem(value: "service", child: Text("Service")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                        _categorie = _donneesDependantes[_type]!.keys.first;
                        _typeSpecifique = _donneesDependantes[_type]![_categorie]!.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown catégorie
                  DropdownButtonFormField<String>(
                    value: _categorie,
                    decoration: const InputDecoration(
                      labelText: "Catégorie",
                      border: OutlineInputBorder(),
                    ),
                    items: _donneesDependantes[_type]!.keys.map((categorie) {
                      return DropdownMenuItem(
                        value: categorie,
                        child: Text(categorie),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categorie = value!;
                        _typeSpecifique = _donneesDependantes[_type]![_categorie]!.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Dropdown type spécifique
                  DropdownButtonFormField<String>(
                    value: _typeSpecifique,
                    decoration: const InputDecoration(
                      labelText: "Type spécifique",
                      border: OutlineInputBorder(),
                    ),
                    items: _donneesDependantes[_type]![_categorie]!.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _typeSpecifique = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Bouton de soumission
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Ajouter l'annonce"),
                    onPressed: _soumettreAnnonce,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}