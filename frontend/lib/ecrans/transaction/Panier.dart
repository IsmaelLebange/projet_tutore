import 'package:flutter/material.dart';
import '../../models/LignePanier.dart';
import '../../services/panierService.dart';
import '../../composants/BarrePrincipale.dart';
import '../../composants/UserGate.dart';
import './ConfirmationCommande.dart';

class Panier extends StatefulWidget {
  const Panier({super.key});

  @override
  State<Panier> createState() => _PanierState();
}

class _PanierState extends State<Panier> {
  final PanierService _panierService = PanierService();
  late Future<Map<String, dynamic>> _panierFuture;

  @override
  void initState() {
    super.initState();
    _rafraichir();
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
        const SnackBar(content: Text('Article supprimé du panier')),
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
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
    try {
      final data = await _panierFuture;
      final lignes = data['lignes'] as List;

      if (lignes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre panier est vide')),
        );
        return;
      }

      // ✅ Convertir les LignePanier en Map pour ConfirmationCommande
      final dataFormatted = {
        'transaction': data['transaction'],
        'lignes': lignes.map((ligne) {
          if (ligne is LignePanier) {
            return ligne.toJson();
          }
          return ligne;
        }).toList(),
        'total': data['total'],
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmationCommande(panierData: dataFormatted),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Widget _buildLignePanier(LignePanier ligne) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ligne.image != null && ligne.image!.isNotEmpty
                  ? Image.network(
                      ligne.image!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            const SizedBox(width: 12),

            // Informations
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
                    'Prix: ${ligne.prixUnitaire.toStringAsFixed(0)} FC',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vendeur: ${ligne.vendeur['nom']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Contrôles quantité
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: ligne.quantite > 1
                          ? () => _modifierQuantite(ligne.id, ligne.quantite - 1)
                          : null,
                      icon: const Icon(Icons.remove),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${ligne.quantite}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _modifierQuantite(ligne.id, ligne.quantite + 1),
                      icon: const Icon(Icons.add),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${ligne.sousTotal.toStringAsFixed(0)} FC',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            // Bouton supprimer
            IconButton(
              onPressed: () => _supprimerLigne(ligne.id),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UserGate(
      child: Scaffold(
        appBar: BarrePrincipale(titre: 'Mon Panier'),
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
            final lignes = (data['lignes'] as List).cast<LignePanier>();
            final total = data['total'] as num;

            if (lignes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Votre panier est vide',
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/catalogueProduits'),
                      child: const Text('Découvrir nos produits'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Liste des articles
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _rafraichir(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: lignes.length,
                      itemBuilder: (context, index) {
                        return _buildLignePanier(lignes[index]);
                      },
                    ),
                  ),
                ),

                // Résumé et actions
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
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Total: ',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${total.toStringAsFixed(0)} FC',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _viderPanier,
                            icon: const Icon(Icons.clear_all, color: Colors.red),
                            label: const Text('Vider',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _validerPanier,
                          icon: const Icon(Icons.payment),
                          label: const Text('Valider la commande'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
      ),
    );
  }
}