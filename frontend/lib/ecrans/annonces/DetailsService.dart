import 'package:flutter/material.dart';
import '../../models/Service.dart';
import '../../services/annonce/serviceService.dart';
import '../../services/panierService.dart';
import '../../composants/BarreRetour.dart';

class DetailsService extends StatefulWidget {
  final int serviceId;

  const DetailsService({super.key, required this.serviceId});

  @override
  State<DetailsService> createState() => _DetailsServiceState();
}

class _DetailsServiceState extends State<DetailsService> {
  final ServiceService _serviceService = ServiceService();
  final PanierService _panierService = PanierService();
  late Future<Service> _serviceFuture;
  bool _ajoutEnCours = false;

  @override
  void initState() {
    super.initState();
    _serviceFuture = _serviceService.obtenirServiceParId(widget.serviceId);
  }

  Future<void> _ajouterAuPanier(Service service) async {
    if (_ajoutEnCours) return;
    setState(() => _ajoutEnCours = true);

    try {
      await _panierService.ajouterAuPanier(
        type: 'Service',
        itemId: service.id!,
        quantite: 1,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${service.titre} ajouté au panier'),
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
      appBar: const BarreRetour(titre: "Détails du service"),
      body: FutureBuilder<Service>(
        future: _serviceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _errorView(snapshot.error.toString(), onRetry: () {
              setState(() {
                _serviceFuture = _serviceService.obtenirServiceParId(widget.serviceId);
              });
            });
          }
          if (!snapshot.hasData) {
            return _emptyView('Service introuvable');
          }

          final service = snapshot.data!;
          final imageUrl = ServiceService.buildImageUrl(service.image);

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _image(imageUrl, 'service_${widget.serviceId}'),
                    _infos(service),
                    _description(service.description),
                  ],
                ),
              ),
              Align(alignment: Alignment.bottomCenter, child: _actions(service)),
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

  Widget _infos(Service s) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.titre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${s.prix.toStringAsFixed(0)} FC',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.category, s.categorieService, Colors.blue),
              _chip(Icons.label, s.typeService, Colors.purple),
              if (s.disponibilite != null)
                _chip(
                  s.disponibilite == 'Disponible' ? Icons.check_circle : Icons.cancel,
                  s.disponibilite!,
                  s.disponibilite == 'Disponible' ? Colors.green : Colors.red,
                ),
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

  Widget _actions(Service s) {
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
                onPressed: _ajoutEnCours ? null : () => _ajouterAuPanier(s),
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