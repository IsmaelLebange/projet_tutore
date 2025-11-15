import 'package:flutter/material.dart';
import '../../models/LignePanier.dart';
import '../../models/ComptePaiement.dart';
import '../../services/comptePaiementService.dart';
import '../../services/panierService.dart';
import '../../composants/BarreRetour.dart';
import '../../composants/UserGate.dart';

class ConfirmationCommande extends StatefulWidget {
  final Map<String, dynamic>? panierData;

  const ConfirmationCommande({super.key, this.panierData});

  @override
  State<ConfirmationCommande> createState() => _ConfirmationCommandeState();
}

class _ConfirmationCommandeState extends State<ConfirmationCommande> {
  final ComptePaiementService _comptesService = ComptePaiementService();
  final PanierService _panierService = PanierService();
  
  late Future<List<ComptePaiement>> _comptesFuture;
  late Future<Map<String, dynamic>> _panierFuture;
  ComptePaiement? _compteSelectionne;
  bool _validationEnCours = false;

  @override
  void initState() {
    super.initState();
    _comptesFuture = _comptesService.obtenirComptes();
    
    // Si pas de données passées, les récupérer
    if (widget.panierData != null) {
      _panierFuture = Future.value(widget.panierData!);
    } else {
      _panierFuture = _panierService.obtenirPanier();
    }
  }

  Future<void> _validerCommande(Map<String, dynamic> panierData) async {
    if (_compteSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un compte de paiement')),
      );
      return;
    }

    setState(() => _validationEnCours = true);

    try {
      final result = await _panierService.validerPanier(_compteSelectionne!.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/notifications', 
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _validationEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserGate(
      child: Scaffold(
        appBar: const BarreRetour(titre: 'Confirmation de commande'),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _panierFuture,
          builder: (context, panierSnapshot) {
            if (panierSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (panierSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erreur: ${panierSnapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              );
            }

            final panierData = panierSnapshot.data!;
            final lignesRaw = panierData['lignes'] as List;
            final total = panierData['total'] as num;

            // ✅ Gérer les données en Map (depuis panier formaté)
            final lignes = lignesRaw.map((item) {
              if (item is Map<String, dynamic>) {
                return item;
              } else if (item is LignePanier) {
                return item.toJson();
              }
              return item as Map<String, dynamic>;
            }).toList();

            if (lignes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Panier vide'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/panier', (route) => false),
                      child: const Text('Retour au panier'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Résumé commande
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Résumé
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Résumé de la commande', 
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                ...lignes.map((ligne) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      // Image miniature
                                      if (ligne['image'] != null && ligne['image'].toString().isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: Image.network(
                                              ligne['image'],
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 40,
                                                height: 40,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.broken_image, size: 20),
                                              ),
                                            ),
                                          ),
                                        ),
                                      // Détails
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${ligne['titre']} (x${ligne['quantite']})',
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              '${ligne['prixUnitaire'].toStringAsFixed(0)} FC/unité',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Prix total ligne
                                      Text(
                                        '${ligne['sousTotal'].toStringAsFixed(0)} FC',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                                const Divider(),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text('Total', 
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                    Text('${total.toStringAsFixed(0)} FC',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          fontSize: 16,
                                          color: Colors.green,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Sélection compte paiement
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Compte de paiement', 
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () {
                                        // ✅ Navigation vers gestion comptes
                                        Navigator.pushNamed(context, '/comptes-paiement').then((_) {
                                          setState(() {
                                            _comptesFuture = _comptesService.obtenirComptes();
                                          });
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Ajouter'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                FutureBuilder<List<ComptePaiement>>(
                                  future: _comptesFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }

                                    if (snapshot.hasError) {
                                      return Text('Erreur: ${snapshot.error}');
                                    }

                                    final comptes = snapshot.data ?? [];

                                    if (comptes.isEmpty) {
                                      return Column(
                                        children: [
                                          const Text('Aucun compte de paiement configuré'),
                                          const SizedBox(height: 8),
                                          ElevatedButton.icon(
                                            onPressed: () => Navigator.pushNamed(context, '/comptes-paiement'),
                                            icon: const Icon(Icons.add),
                                            label: const Text('Ajouter un compte'),
                                          ),
                                        ],
                                      );
                                    }

                                    return Column(
                                      children: comptes.map((compte) {
                                        return RadioListTile<ComptePaiement>(
                                          value: compte,
                                          groupValue: _compteSelectionne,
                                          onChanged: (value) {
                                            setState(() => _compteSelectionne = value);
                                          },
                                          title: Text(compte.entreprise),
                                          subtitle: Text(compte.numeroCompte),
                                          secondary: compte.estPrincipal
                                              ? const Icon(Icons.star, color: Colors.orange)
                                              : null,
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bouton validation
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _validationEnCours ? null : () => _validerCommande(panierData),
                      icon: _validationEnCours
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.payment),
                      label: Text(_validationEnCours ? 'Validation...' : 'Confirmer la commande'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
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