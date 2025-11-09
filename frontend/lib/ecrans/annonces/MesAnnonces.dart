import 'package:flutter/material.dart';
import '../../models/Annonce.dart';
import '../../models/Produit.dart';
import '../../models/Service.dart';
import '../../services/annonceService.dart';
import '../../composants/BarrePrincipale.dart';
import '../../composants/BoutonPrincipal.dart';
import '../../composants/UserGate.dart';

class MesAnnonces extends StatefulWidget {
  const MesAnnonces({super.key});

  @override
  State<MesAnnonces> createState() => _MesAnnoncesState();
}

class _MesAnnoncesState extends State<MesAnnonces> {
  final _annonceService = AnnonceService();
  List<Annonce> _mesAnnonces = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _chargerMesAnnonces();
  }

  Future<void> _chargerMesAnnonces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final annonces = await _annonceService.obtenirMesAnnonces();
      setState(() {
        _mesAnnonces = annonces;
        _isLoading = false;
      });
      print('✅ ${annonces.length} annonce(s) chargée(s) dans l\'UI');
    } catch (e) {
      print('❌ Erreur chargement: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _supprimerAnnonce(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette annonce ?'),
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

    if (confirm == true) {
      try {
        await _annonceService.supprimerAnnonce(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Annonce supprimée avec succès")),
        );
        _chargerMesAnnonces();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e")),
        );
      }
    }
  }

  void _modifierAnnonce(Annonce annonce) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fonctionnalité à venir")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return UserGate( 
      child: Scaffold(
      appBar: const BarrePrincipale(titre: "Mes Annonces"),
      drawer: MenuPrincipal(),
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('Erreur: $_errorMessage'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _chargerMesAnnonces,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _mesAnnonces.isEmpty
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
                                  const SizedBox(height: 100),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _chargerMesAnnonces,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                                itemCount: _mesAnnonces.length,
                                itemBuilder: (context, index) {
                                  final annonce = _mesAnnonces[index];
                                  
                                  // ⚠️ CORRIGÉ : Utiliser annonce.image directement (String)
                                  final imageUrl = annonce.image.isNotEmpty
                                      ? 'http://localhost:3000${annonce.image}'
                                      : null;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(8),
                                      leading: imageUrl != null
                                          ? Image.network(
                                              imageUrl,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 60),
                                            )
                                          : const Icon(Icons.image, size: 60),
                                      title: Text(
                                        annonce.titre,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            "${annonce.prix.toStringAsFixed(0)} FC",
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            annonce is Produit
                                                ? "Produit: ${annonce.categorieProduit}"
                                                : annonce is Service
                                                    ? "Service: ${annonce.categorieService}"
                                                    : "Type inconnu",
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
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 800,
              padding: const EdgeInsets.all(16),
              color: Colors.white.withOpacity(0.95),
              child: BoutonPrincipal(
                texte: "Ajouter une nouvelle annonce",
                onPressed: () {
                  Navigator.pushNamed(context, '/annonces').then((_) {
                    _chargerMesAnnonces();
                  });
                },
                couleur: primaryColor,
                icone: Icons.add_circle,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}