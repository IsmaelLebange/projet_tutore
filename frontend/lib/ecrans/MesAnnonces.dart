import 'package:flutter/material.dart';
import '../models/Annonce.dart';
import '../models/Produit.dart';
import '../models/Service.dart';
import '../composants/BarrePrincipale.dart';
import '../composants/BoutonPrincipal.dart'; // 🚨 Import du BoutonPrincipal

class MesAnnonces extends StatefulWidget {
  const MesAnnonces({super.key});

  @override
  State<MesAnnonces> createState() => _MesAnnoncesState();
}

class _MesAnnoncesState extends State<MesAnnonces> {
  // 🔥 MOCK: Simule les annonces de l'utilisateur connecté (inchangé)
  List<Annonce> _mesAnnonces = [
    Produit(id: 101, titre: "Vélo de course Vintage", description: "Cadre en acier, parfait état.", prix: 250.0, categorieProduit: "Sports et Loisirs", typeProduit: "Vélo", image: "https://via.placeholder.com/150/FFA500"),
    Service(id: 102, titre: "Cours de guitare à domicile", description: "Tous niveaux, 20€/heure.", prix: 20.0, categorieService: "Cours", typeService: "Musique", image: "https://via.placeholder.com/150/0000FF"),
    Produit(id: 103, titre: "Fauteuil scandinave", description: "Cuir marron, très confortable.", prix: 400.0, categorieProduit: "Maison", typeProduit: "Meuble", image: "https://via.placeholder.com/150/008000"),
  ];

  void _supprimerAnnonce(int id) {
    setState(() {
      _mesAnnonces.removeWhere((annonce) => annonce.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Annonce supprimée avec succès")),
    );
  }

  void _modifierAnnonce(Annonce annonce) {
    print("Modifier l'annonce : ${annonce.titre}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Fonctionnalité de modification pour ${annonce.titre}")),
    );
  }

  void _naviguerVersAjoutAnnonce() {
    Navigator.pushNamed(context, '/ajoutAnnonce');
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: const BarrePrincipale(titre: "Mes Annonces"),
      drawer: MenuPrincipal(),
      body: Stack( // Utilisation d'un Stack pour superposer le contenu et le bouton
        children: [
          // 1. Contenu principal (Liste d'annonces ou Message vide)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _mesAnnonces.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey),
                          const SizedBox(height: 20),
                          const Text(
                            "Tu n'as encore posté aucune annonce.",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 100), // Espace pour ne pas cacher le bouton
                        ],
                      ),
                    )
                  : ListView.builder(
                      // Ajoute une marge en bas pour que le dernier item ne soit pas caché par le bouton
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), 
                      itemCount: _mesAnnonces.length,
                      itemBuilder: (context, index) {
                        final annonce = _mesAnnonces[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: Image.network(annonce.image, width: 60, height: 60, fit: BoxFit.cover),
                            title: Text(annonce.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  "${annonce.prix.toStringAsFixed(2)} €",
                                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  annonce is Produit ? "Catégorie: ${annonce.categorieProduit}" : "Service: ${annonce is Service ? annonce.categorieService : 'N/A'}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _modifierAnnonce(annonce),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _supprimerAnnonce(annonce.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 800, 
              padding: const EdgeInsets.all(16),
              color: Colors.white.withOpacity(0.95), 
              child: BoutonPrincipal(
                texte: "Ajouter une nouvelle annonce",
                onPressed: (){Navigator.pushNamed(context, '/annonces');},
                couleur: primaryColor,
                icone: Icons.add_circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}