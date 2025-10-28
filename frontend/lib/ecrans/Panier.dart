// DANS Panier.dart

import 'package:flutter/material.dart';
import '../models/Annonce.dart';
import '../models/Produit.dart';
import '../models/Service.dart';
import '../composants/BarrePrincipale.dart'; // 🚨 Import du composant

class Panier extends StatefulWidget {
  const Panier({Key? key}) : super(key: key);

  @override
  _PanierState createState() => _PanierState();
}

class _PanierState extends State<Panier> {
  // 🔥 MOCK DATA
  List<Annonce> panier = [
    Produit(
      id: 1,
      titre: "iPhone 14",
      description: "Presque neuf, 128 Go",
      prix: 800.0,
      categorieProduit: "Électronique",
      typeProduit: "Smartphone",
      image: "https://via.placeholder.com/150",
    ),
    Service(
      id: 2,
      titre: "Cours particuliers",
      description: "Maths et physique",
      prix: 15.0,
      categorieService: "Services",
      typeService: "hvhgvhhv",
      image: "https://via.placeholder.com/150",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double total = panier.fold(0, (sum, item) => sum + item.prix);
    
    // Pour un design cohérent, on récupère la couleur primaire du thème (l'orange leboncoin si tu l'as défini)
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // 🚨 Utilisation de BarrePrincipale pour la cohérence
      appBar: const BarrePrincipale(titre: "Mon Panier"),
      drawer: MenuPrincipal(), // Ajout du MenuPrincipal pour la cohérence
      body: panier.isEmpty
          ? Center(
              child: Text(
                "Ton panier est vide 🛒",
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: panier.length,
                    itemBuilder: (context, index) {
                      final annonce = panier[index];
                      return ListTile(
                        leading: Image.network(
                          annonce.image,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(annonce.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${annonce.prix} €", style: TextStyle(color: primaryColor)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              panier.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                // Séparateur entre la liste et le total
                const Divider(height: 1),

                // 💰 Section Total et Bouton de validation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total à payer :",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                          ),
                          Text(
                            "${total.toStringAsFixed(2)} €",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Logique de paiement
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text("Valider la commande"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}