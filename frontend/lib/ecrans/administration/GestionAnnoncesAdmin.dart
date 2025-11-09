import 'package:flutter/material.dart';
import 'package:frontend/composants/AdminGate.dart';
import '../../composants/BarreRetour.dart';
import '../../services/administration/adminAnnonceService.dart';
import '../../models/Annonce.dart';

class GestionAnnoncesAdmin extends StatefulWidget {
  const GestionAnnoncesAdmin({super.key});
  @override
  State<GestionAnnoncesAdmin> createState() => _GestionAnnoncesAdminState();
}

class _GestionAnnoncesAdminState extends State<GestionAnnoncesAdmin> {
  final AdminAnnonceService _service = AdminAnnonceService();
  List<Annonce> _annonces = [];
  bool _loading = true;
  String? _error;
  String _filtre = '';
  String _statutFiltre = 'Tous'; 

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.obtenirAnnoncesAdmin();
      setState(() {
        _annonces = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _changerStatut(Annonce a, String statut) async {
    try {
      await _service.changerStatutAnnonce(a.id!, statut);
      await _charger();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour: $statut'))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red)
        );
      }
    }
  }

  List<Annonce> _appliquerFiltres() {
    return _annonces.where((a) {
      final matchTexte = _filtre.isEmpty ||
          a.titre.toLowerCase().contains(_filtre.toLowerCase());
      
      if (_statutFiltre != 'Tous') {
        final statutAnnonce = a.statut ?? 'Active';
        return matchTexte && statutAnnonce == _statutFiltre;
      }
      
      return matchTexte;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtres = ['Tous','Active','En attente','Bloquée'];
    final annoncesFiltrees = _appliquerFiltres();

    return AdminGate(
      child: Scaffold(
        appBar: const BarreRetour(titre: 'Gérer les Annonces'),
        body: RefreshIndicator(
          onRefresh: _charger,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(child: Text('Erreur: $_error')),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton(
                            onPressed: _charger,
                            child: const Text('Réessayer'),
                          ),
                        )
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Recherche...',
                                  prefixIcon: Icon(Icons.search),
                                ),
                                onChanged: (v) => setState(() => _filtre = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            DropdownButton<String>(
                              value: _statutFiltre,
                              items: filtres.map((f) =>
                                DropdownMenuItem(value: f, child: Text(f))
                              ).toList(),
                              onChanged: (v) => setState(() => _statutFiltre = v!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (annoncesFiltrees.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: Text('Aucune annonce.'),
                            ),
                          ),
                        ...annoncesFiltrees.map((a) {
                          // ✅ Construction URL complète image
                          String? imageUrl;
                          if (a.image.isNotEmpty) {
                            if (a.image.startsWith('http')) {
                              imageUrl = a.image;
                            } else {
                              imageUrl = 'http://localhost:3000${a.image.startsWith('/') ? '' : '/'}${a.image}';
                            }
                          }
                          
                          // Badge couleur selon statut
                          Color badgeColor = Colors.green;
                          if (a.statut == 'En attente') badgeColor = Colors.orange;
                          if (a.statut == 'Bloquée') badgeColor = Colors.red;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              // ✅ Image avec chargement + erreur
                              leading: imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) return child;
                                          return SizedBox(
                                            width: 64,
                                            height: 64,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                value: progress.expectedTotalBytes != null
                                                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.image, color: Colors.grey),
                                    ),
                              title: Text(
                                a.titre,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('${a.type} • ${a.prix.toStringAsFixed(0)} FC'),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      a.statut ?? 'Active',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: badgeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (val) {
                                  switch (val) {
                                    case 'actif':
                                      _changerStatut(a,'Active');
                                      break;
                                    case 'bloquer':
                                      _changerStatut(a,'Bloquée');
                                      break;
                                    case 'attente':
                                      _changerStatut(a,'En attente');
                                      break;
                                    case 'supprimer':
                                      _confirmerSuppression(a);
                                      break;
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value:'actif',
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Activer'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value:'attente',
                                    child: Row(
                                      children: [
                                        Icon(Icons.pending, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('En attente'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value:'bloquer',
                                    child: Row(
                                      children: [
                                        Icon(Icons.block, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Bloquer'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value:'supprimer',
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
                        }).toList(),
                      ],
                    ),
        ),
      ),
    );
  }

  void _confirmerSuppression(Annonce a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ Supprimer cette annonce'),
        content: Text('Supprimer définitivement "${a.titre}" ?\n\nCette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (ok == true) {
      try {
        await _service.supprimerAnnonceAdmin(a.id!);
        await _charger();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Annonce supprimée'),
              backgroundColor: Colors.green,
            )
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: $e'),
              backgroundColor: Colors.red,
            )
          );
        }
      }
    }
  }
}