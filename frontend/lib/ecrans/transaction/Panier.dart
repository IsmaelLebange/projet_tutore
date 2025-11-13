import 'package:flutter/material.dart';
import '../../models/LignePanier.dart';
import '../../services/panierService.dart';
import '../../composants/BarrePrincipale.dart';
import '../../composants/UserGate.dart';
import './ConfirmationCommande.dart';


class Panier extends StatefulWidget {
  const Panier({Key? key}) : super(key: key);

  @override
  _PanierState createState() => _PanierState();
}

class _PanierState extends State<Panier> {
  final PanierService _panierService = PanierService();
  late Future<Map<String, dynamic>> _panierFuture;

  @override
  void initState() {
    super.initState();
    _panierFuture = _panierService.obtenirPanier();
  }

  void _rafraichir() {
    setState(() {
      _panierFuture = _panierService.obtenirPanier();
    });
  }

  Future<void> _modifierQuantite(int ligneId, int nouvelleQuantite) async {
    try {
      await _panierService.modifierQuantite(ligneId, nouvelleQuantite);
      _rafraichir();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantité mise à jour')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _supprimerLigne(int ligneId) async {
    try {
      await _panierService.supprimerLigne(ligneId);
      _rafraichir();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article retiré')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _viderPanier() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le panier'),
        content: const Text('Êtes-vous sûr de vouloir vider votre panier ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Vider', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _panierService.viderPanier();
        _rafraichir();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Panier vidé')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _validerPanier() async {
    // Passer à l'écran de confirmation au lieu de valider directement
    final data = await _panierFuture;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationCommande(panierData: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return UserGate(
      child:
    Scaffold(
      appBar: BarrePrincipale(
        titre: "Mon Panier",
      ),
      drawer: MenuPrincipal(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _panierFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _rafraichir,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final lignes = data['lignes'] as List<LignePanier>;
          final total = data['total'] as num;

          if (lignes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "Ton panier est vide 🛒",
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/accueil'),
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Découvrir les annonces'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header avec bouton vider
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${lignes.length} article${lignes.length > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _viderPanier,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Vider', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),

              // Liste des articles
              Expanded(
                child: ListView.builder(
                  itemCount: lignes.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final ligne = lignes[index];
                    final imageUrl = PanierService.buildImageUrl(ligne.image);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl.isEmpty
                                  ? Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported),
                                    )
                                  : Image.network(
                                      imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),

                            // Infos
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ligne.titre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Vendeur: ${ligne.vendeur['nom']}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        '${ligne.prixUnitaire.toStringAsFixed(0)} FC',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Contrôles quantité
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, size: 18),
                                              onPressed: ligne.quantite > 1
                                                  ? () => _modifierQuantite(ligne.id, ligne.quantite - 1)
                                                  : null,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            ),
                                            Text(
                                              '${ligne.quantite}',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add, size: 18),
                                              onPressed: () => _modifierQuantite(ligne.id, ligne.quantite + 1),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sous-total: ${ligne.sousTotal.toStringAsFixed(0)} FC',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),

                            // Bouton supprimer
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _supprimerLigne(ligne.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Footer : Total + Validation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
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
                          "${total.toStringAsFixed(0)} FC",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _validerPanier,
                        icon: const Icon(Icons.payment),
                        label: const Text("Valider la commande"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    )) ;
  }
}