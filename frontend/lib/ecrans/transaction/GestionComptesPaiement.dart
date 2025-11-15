import 'package:flutter/material.dart';
import '../../models/ComptePaiement.dart';
import '../../services/comptePaiementService.dart';
import '../../composants/BarreRetour.dart';
import '../../composants/UserGate.dart';

class GestionComptesPaiement extends StatefulWidget {
  const GestionComptesPaiement({super.key});

  @override
  State<GestionComptesPaiement> createState() => _GestionComptesPaiementState();
}

// ...existing code...

class _GestionComptesPaiementState extends State<GestionComptesPaiement> {
  final ComptePaiementService _service = ComptePaiementService();
  late Future<List<ComptePaiement>> _comptesFuture;

  @override
  void initState() {
    super.initState();
    _rafraichir();
  }

  void _rafraichir() {
    setState(() {
      _comptesFuture = _service.obtenirComptes();
    });
  }

  Future<void> _ajouterCompte() async {
    await showDialog(
      context: context,
      builder: (context) => AjoutCompteDialog(
        onCompteAjoute: () {
          _rafraichir();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compte ajouté avec succès')),
          );
          // ✅ AJOUT : Retourner true pour indiquer qu'un compte a été ajouté
          Navigator.pop(context, true);
        },
      ),
    );
  }

  Future<void> _supprimerCompte(ComptePaiement compte) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: Text('Êtes-vous sûr de vouloir supprimer le compte ${compte.entreprise} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.supprimerCompte(compte.id);
        _rafraichir();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte supprimé')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _definirPrincipal(ComptePaiement compte) async {
    try {
      await _service.definirPrincipal(compte.id);
      _rafraichir();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte principal défini')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Widget _buildCompteCard(ComptePaiement compte) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: compte.estPrincipal ? Colors.orange : Colors.grey,
          child: Icon(
            compte.estPrincipal ? Icons.star : Icons.account_balance_wallet,
            color: Colors.white,
          ),
        ),
        title: Text(
          compte.entreprise,
          style: TextStyle(
            fontWeight: compte.estPrincipal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(compte.numeroCompte),
            if (compte.estPrincipal)
              const Text(
                'Compte principal',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'principal':
                if (!compte.estPrincipal) _definirPrincipal(compte);
                break;
              case 'supprimer':
                _supprimerCompte(compte);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!compte.estPrincipal)
              const PopupMenuItem(
                value: 'principal',
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Définir comme principal'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'supprimer',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ],
              ),
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
        appBar: const BarreRetour(titre: 'Comptes de paiement'),
        body: FutureBuilder<List<ComptePaiement>>(
          future: _comptesFuture,
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
                    ElevatedButton(onPressed: _rafraichir, child: const Text('Réessayer')),
                  ],
                ),
              );
            }

            final comptes = snapshot.data ?? [];

            return Column(
              children: [
                // Liste des comptes
                Expanded(
                  child: comptes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, 
                                   size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('Aucun compte de paiement', 
                                   style: TextStyle(color: Colors.grey[600])),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _ajouterCompte,
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter votre premier compte'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => _rafraichir(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: comptes.length,
                            itemBuilder: (context, index) {
                              return _buildCompteCard(comptes[index]);
                            },
                          ),
                        ),
                ),

                // Bouton d'ajout
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
                      onPressed: _ajouterCompte,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un compte'),
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

// Dialog pour ajouter un compte
class AjoutCompteDialog extends StatefulWidget {
  final VoidCallback onCompteAjoute;

  const AjoutCompteDialog({super.key, required this.onCompteAjoute});

  @override
  State<AjoutCompteDialog> createState() => _AjoutCompteDialogState();
}

class _AjoutCompteDialogState extends State<AjoutCompteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _entrepriseController = TextEditingController();
  final ComptePaiementService _service = ComptePaiementService();
  
  bool _estPrincipal = false;
  bool _chargement = false;

  // Liste des entreprises de paiement populaires en RDC
  final List<String> _entreprises = [
    'Orange Money',
    'Vodacom M-Pesa',
    'Airtel Money',
    'Tigo Cash',
    'Equity Bank',
    'Trust Merchant Bank',
    'Banque Commerciale du Congo (BCDC)',
    'Rawbank',
    'Ecobank',
    'UBA Congo',
    'Autre',
  ];

  String? _entrepriseSelectionnee;

  @override
  void dispose() {
    _numeroController.dispose();
    _entrepriseController.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _chargement = true);

    try {
      final entreprise = _entrepriseSelectionnee == 'Autre'
          ? _entrepriseController.text.trim()
          : _entrepriseSelectionnee!;

      await _service.ajouterCompte(
        numeroCompte: _numeroController.text.trim(),
        entreprise: entreprise,
        estPrincipal: _estPrincipal,
      );

      Navigator.pop(context);
      widget.onCompteAjoute();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un compte'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sélection entreprise
              DropdownButtonFormField<String>(
                value: _entrepriseSelectionnee,
                decoration: const InputDecoration(
                  labelText: 'Service de paiement',
                  border: OutlineInputBorder(),
                ),
                items: _entreprises.map((entreprise) {
                  return DropdownMenuItem(
                    value: entreprise,
                    child: Text(entreprise),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _entrepriseSelectionnee = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sélectionnez un service';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),

              // Champ entreprise personnalisé
              if (_entrepriseSelectionnee == 'Autre')
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _entrepriseController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du service',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_entrepriseSelectionnee == 'Autre' && 
                          (value == null || value.trim().isEmpty)) {
                        return 'Entrez le nom du service';
                      }
                      return null;
                    },
                  ),
                ),

              // Numéro de compte
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de compte/téléphone',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: +243123456789',
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Entrez votre numéro';
                  }
                  if (value.trim().length < 5) {
                    return 'Numéro trop court';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),

              // Case compte principal
              CheckboxListTile(
                value: _estPrincipal,
                onChanged: (value) {
                  setState(() {
                    _estPrincipal = value ?? false;
                  });
                },
                title: const Text('Définir comme compte principal'),
                subtitle: const Text('Ce compte sera sélectionné par défaut'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _chargement ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _chargement ? null : _sauvegarder,
          child: _chargement
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Ajouter'),
        ),
      ],
    );
  }
}