import 'package:flutter/material.dart';
import '../services/panierService.dart';
import '../services/annonce/produitService.dart';
import '../services/annonce/serviceService.dart';

class ListeAnnonces extends StatelessWidget {
  final List<Map<String, dynamic>> annonces;
  final void Function(Map<String, dynamic>)? onTap;
  final void Function(Map<String, dynamic>)? onAddToCart;
  final bool showAddToCart;

  const ListeAnnonces({
    super.key,
    required this.annonces,
    this.onTap,
    this.onAddToCart,
    this.showAddToCart = true,
  });

  String _buildImageUrl(Map<String, dynamic> a) {
    final type = (a['type'] ?? '').toString();
    final img = (a['image'] ?? '').toString();
    if (type == 'Produit') return ProduitService.buildImageUrl(img);
    if (type == 'Service') return ServiceService.buildImageUrl(img);
    return img; // fallback
  }

  Future<void> _defaultAddToCart(BuildContext context, Map<String, dynamic> a) async {
    final type = (a['type'] ?? '').toString();
    final id = a['id'] as int?;
    if (id == null || (type != 'Produit' && type != 'Service')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ajouter cet article')),
      );
      return;
    }

    try {
      await PanierService().ajouterAuPanier(type: type, itemId: id, quantite: 1);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${a['titre'] ?? 'Article'} ajouté au panier')),
      );
    } catch (e) {
      if (!context.mounted) return;
      final msg = e.toString();
      if (msg.contains('401') || msg.contains('Token') || msg.contains('auth')) {
        final goLogin = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Connexion requise'),
            content: const Text('Connecte-toi pour ajouter au panier.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Se connecter')),
            ],
          ),
        );
        if (goLogin == true && context.mounted) {
          Navigator.pushNamed(context, '/connexion');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (annonces.isEmpty) {
      return Center(
        child: Text('Aucune annonce', style: TextStyle(color: Colors.grey[600])),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: annonces.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemBuilder: (context, index) {
        final a = annonces[index];
        final imageUrl = _buildImageUrl(a);

        return Card(
          child: ListTile(
            onTap: onTap != null ? () => onTap!(a) : null,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isEmpty
                  ? Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    )
                  : Image.network(
                      imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
            ),
            title: Text(
              (a['titre'] ?? '').toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: a['prix'] != null
                ? Text('${(a['prix'] as num).toStringAsFixed(0)} FC')
                : null,
            trailing: showAddToCart
                ? IconButton(
                    tooltip: 'Ajouter au panier',
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.orange),
                    onPressed: () => onAddToCart != null
                        ? onAddToCart!(a)
                        : _defaultAddToCart(context, a),
                  )
                : null,
          ),
        );
      },
    );
  }
}