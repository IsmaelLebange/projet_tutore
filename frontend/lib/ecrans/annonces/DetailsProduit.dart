import 'package:flutter/material.dart';
import '../../models/Produit.dart';
import '../../services/produitService.dart';
import '../../services/panierService.dart';
import '../../composants/BarreRetour.dart';
import '../../composants/ComposantsUI.dart';

class DetailsProduit extends StatefulWidget {
  final int produitId;

  const DetailsProduit({super.key, required this.produitId});

  @override
  State<DetailsProduit> createState() => _DetailsProduitState();
}

class _DetailsProduitState extends State<DetailsProduit> {
  final ProduitService _produitService = ProduitService();
  final PanierService _panierService = PanierService();
  late Future<Produit> _produitFuture;
  bool _ajoutEnCours = false;

  @override
  void initState() {
    super.initState();
    _produitFuture = _produitService.obtenirProduitParId(widget.produitId);
  }

  Future<void> _ajouterAuPanier(Produit produit) async {
    if (_ajoutEnCours) return;
    setState(() => _ajoutEnCours = true);

    try {
      await _panierService.ajouterAuPanier(
        type: 'Produit',
        itemId: produit.id!,
        quantite: 1,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${produit.titre} ajouté au panier'),
          action: SnackBarAction(
            label: 'Voir',
            onPressed: () => Navigator.pushNamed(context, '/panier'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
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
        if (goLogin == true && mounted) {
          Navigator.pushNamed(context, '/connexion');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _ajoutEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: BarreNavigationPrincipale(),
        ),
      ),
      body: FutureBuilder<Produit>(
        future: _produitFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _errorView(snapshot.error.toString(), onRetry: () {
              setState(() {
                _produitFuture = _produitService.obtenirProduitParId(widget.produitId);
              });
            });
          }
          if (!snapshot.hasData) {
            return _emptyView('Produit introuvable');
          }

          final produit = snapshot.data!;
          final imageUrl = ProduitService.buildImageUrl(produit.image);

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _image(imageUrl, 'produit_${widget.produitId}'),
                    _infos(produit),
                    _description(produit.description),
                  ],
                ),
              ),
              Align(alignment: Alignment.bottomCenter, child: _actions(produit)),
            ],
          );
        },
      ),
    );
  }

  Widget _image(String url, String heroTag) {
    return Hero(
      tag: heroTag,
      child: Container(
        height: 300,
        color: Colors.white,
        width: double.infinity,
        child: url.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('Aucune image disponible', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.grey[500]),
                      const SizedBox(height: 8),
                      const Text('Image non disponible'),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _infos(Produit p) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.titre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${p.prix.toStringAsFixed(0)} FC',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.category, p.categorieProduit, Colors.blue),
              _chip(Icons.label, p.typeProduit, Colors.purple),
              if (p.etat != null) _chip(Icons.info_outline, 'État: ${p.etat}', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _description(String text) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.description, color: Colors.grey[700]), const SizedBox(width: 8), const Text('Description', style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          Text(text.isEmpty ? 'Aucune description disponible.' : text, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }

  Widget _actions(Produit p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8, offset: const Offset(0, -3)),
      ]),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _ajoutEnCours ? null : () => _ajouterAuPanier(p),
                icon: _ajoutEnCours
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add_shopping_cart),
                label: Text(_ajoutEnCours ? 'Ajout...' : 'Ajouter au panier'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Messagerie à venir')));
                },
                icon: const Icon(Icons.message),
                label: const Text('Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color.shade800, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _errorView(String msg, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 12),
          Text('Erreur: $msg', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          if (onRetry != null) ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Réessayer')),
        ]),
      ),
    );
  }

  Widget _emptyView(String msg) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text(msg, style: TextStyle(color: Colors.grey[600])),
      ]),
    );
  }
}