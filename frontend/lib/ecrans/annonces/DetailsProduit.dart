import 'package:flutter/material.dart';
import '../../models/Produit.dart';
import '../../services/produitService.dart';

class DetailsProduit extends StatefulWidget {
  final int produitId;

  const DetailsProduit({super.key, required this.produitId});

  @override
  State<DetailsProduit> createState() => _DetailsProduitState();
}

class _DetailsProduitState extends State<DetailsProduit> {
  final ProduitService _service = ProduitService();
  late Future<Produit> _produitFuture;

  @override
  void initState() {
    super.initState();
    _produitFuture = _service.obtenirProduitParId(widget.produitId);
  }

  // ✅ Construire l'URL de l'image (backend ou externe)
  String _buildImageUrl(String url) {
    if (url.startsWith('http')) return url;
    return 'http://localhost:3000${url.startsWith('/') ? '' : '/'}$url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Détails du produit',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Produit>(
        future: _produitFuture,
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
                    onPressed: () {
                      setState(() {
                        _produitFuture = _service.obtenirProduitParId(widget.produitId);
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Produit introuvable'));
          }

          final produit = snapshot.data!;
          final imageUrl = _buildImageUrl(produit.image);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Image principale
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.white,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 64, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Image non disponible', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ✅ Informations principales
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        produit.titre,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Prix
                      Text(
                        '${produit.prix.toStringAsFixed(0)} FC',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Catégorie et Type
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.category,
                            label: produit.categorieProduit,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: Icons.label,
                            label: produit.typeProduit,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // État
                      if (produit.etat != null)
                        _buildInfoChip(
                          icon: Icons.info_outline,
                          label: 'État: ${produit.etat}',
                          color: produit.etat == 'Neuf' ? Colors.green : Colors.orange,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ✅ Description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        produit.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ✅ Dimensions (si présentes)
                if (produit.dimension != null && produit.dimension!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dimensions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.straighten, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              produit.dimension!,
                              style: const TextStyle(fontSize: 15, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 80), // Espace pour le bouton fixe
              ],
            ),
          );
        },
      ),
      // ✅ Bouton flottant "Contacter le vendeur"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigation vers messagerie ou appel
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fonctionnalité à venir : Contacter le vendeur')),
          );
        },
        icon: const Icon(Icons.message),
        label: const Text('Contacter'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ✅ Widget helper pour les chips d'info
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}