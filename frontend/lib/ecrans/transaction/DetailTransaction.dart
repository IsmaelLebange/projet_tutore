import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/transactionService.dart';
import '../../models/Transaction.dart';
import '../../composants/BarreRetour.dart';
import '../../composants/UserGate.dart';

class DetailTransactionPage extends StatefulWidget {
  final int transactionId;

  const DetailTransactionPage({super.key, required this.transactionId});

  @override
  State<DetailTransactionPage> createState() => _DetailTransactionPageState();
}

class _DetailTransactionPageState extends State<DetailTransactionPage> {
  final TransactionService _service = TransactionService();
  late Future<DetailTransaction> _detailFuture;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _charger() {
    setState(() {
      _detailFuture = _service.obtenirDetailTransaction(widget.transactionId);
    });
  }

  Future<void> _confirmerTransaction() async {
    try {
      await _service.confirmerTransaction(widget.transactionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Confirmation enregistrée')),
      );
      _charger(); // Recharger les données
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserGate(
      child: Scaffold(
        appBar: const BarreRetour(titre: 'Détail Facture'),
        body: FutureBuilder<DetailTransaction>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erreur: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _charger,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final detail = snapshot.data!;
            final isAcheteur = detail.role == 'acheteur';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEntete(detail, isAcheteur),
                  const SizedBox(height: 20),
                  _buildInfosGenerales(detail),
                  const SizedBox(height: 20),
                  _buildParties(detail, isAcheteur),
                  const SizedBox(height: 20),
                  _buildArticles(detail),
                  const SizedBox(height: 20),
                  _buildResume(detail, isAcheteur),
                  const SizedBox(height: 20),
                  if (detail.statut == 'Confirmée' || 
                      detail.statut == 'En_attente_confirmation')
                    _buildBoutonConfirmation(detail, isAcheteur),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEntete(DetailTransaction detail, bool isAcheteur) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.code,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMMM yyyy à HH:mm', )
                          .format(detail.dateTransaction),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isAcheteur ? Colors.blue[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAcheteur ? 'ACHAT' : 'VENTE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isAcheteur ? Colors.blue[700] : Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildStatutAvecConfirmations(detail),
          ],
        ),
      ),
    );
  }

  Widget _buildStatutAvecConfirmations(DetailTransaction detail) {
    return Column(
      children: [
        _buildStatutBadge(detail.statut),
        if (detail.statut == 'En_attente_confirmation' || 
            detail.statut == 'Confirmée')
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildConfirmationIndicateur(
                  'Acheteur',
                  detail.confirmationAcheteur,
                ),
                _buildConfirmationIndicateur(
                  'Vendeur',
                  detail.confirmationVendeur,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmationIndicateur(String label, bool confirme) {
    return Column(
      children: [
        Icon(
          confirme ? Icons.check_circle : Icons.circle_outlined,
          color: confirme ? Colors.green : Colors.grey,
          size: 30,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: confirme ? Colors.green : Colors.grey,
            fontWeight: confirme ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatutBadge(String statut) {
    Color couleur;
    IconData icone;
    String texte;

    switch (statut) {
      case 'En_attente':
        couleur = Colors.orange;
        icone = Icons.hourglass_empty;
        texte = 'En attente';
        break;
      case 'En_attente_confirmation':
        couleur = Colors.blue;
        icone = Icons.check_circle_outline;
        texte = 'En attente de confirmation';
        break;
      case 'Confirmée':
        couleur = Colors.lightGreen;
        icone = Icons.local_shipping;
        texte = 'Confirmée - En livraison';
        break;
      case 'Validée':
        couleur = Colors.green;
        icone = Icons.verified;
        texte = 'Validée';
        break;
      case 'Rejetée':
        couleur = Colors.red;
        icone = Icons.cancel;
        texte = 'Rejetée';
        break;
      default:
        couleur = Colors.grey;
        icone = Icons.help_outline;
        texte = statut;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: couleur),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: couleur),
          const SizedBox(width: 8),
          Text(
            texte,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfosGenerales(DetailTransaction detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations générales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Montant total', '${detail.montant.toStringAsFixed(2)} FC'),
            _buildInfoRow('Commission', '${detail.commission.toStringAsFixed(2)} FC'),
            _buildInfoRow(
              'Montant net',
              '${detail.montantNet.toStringAsFixed(2)} FC',
              bold: true,
            ),
            if (detail.comptePaiement != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Compte paiement',
                '${detail.comptePaiement!.entreprise} - ${detail.comptePaiement!.numeroCompte}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String valeur, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            valeur,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParties(DetailTransaction detail, bool isAcheteur) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parties impliquées',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildPartieCard('Acheteur', detail.acheteur),
            const SizedBox(height: 12),
            _buildPartieCard('Vendeur', detail.vendeur),
          ],
        ),
      ),
    );
  }

  Widget _buildPartieCard(String role, PartieDetail partie) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            partie.nom,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(partie.email, style: const TextStyle(fontSize: 13)),
            ],
          ),
          if (partie.telephone != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(partie.telephone!, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ],
          if (partie.adresse != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    partie.adresse!.complet,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '${partie.reputation.toStringAsFixed(1)}/5',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticles(DetailTransaction detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Articles (${detail.articles.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...detail.articles.map((article) => _buildArticleItem(article)),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(Article article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: article.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'http://localhost:3000${article.images.first}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        article.type == 'Produit' ? Icons.shopping_bag : Icons.build,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Icon(
                    article.type == 'Produit' ? Icons.shopping_bag : Icons.build,
                    color: Colors.grey[400],
                  ),
          ),
          const SizedBox(width: 12),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: article.type == 'Produit'
                            ? Colors.blue[100]
                            : Colors.green[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article.type,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: article.type == 'Produit'
                              ? Colors.blue[800]
                              : Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  article.titre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${article.prixUnitaire.toStringAsFixed(2)} FC × ${article.quantite}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sous-total: ${article.sousTotal.toStringAsFixed(2)} FC',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResume(DetailTransaction detail, bool isAcheteur) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Montant total:', style: TextStyle(fontSize: 16)),
                Text(
                  '${detail.montant.toStringAsFixed(2)} FC',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (!isAcheteur) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Commission (-5%):', style: TextStyle(fontSize: 14)),
                  Text(
                    '${detail.commission.toStringAsFixed(2)} FC',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vous recevrez:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${detail.montantNet.toStringAsFixed(2)} FC',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBoutonConfirmation(DetailTransaction detail, bool isAcheteur) {
    final dejaConfirme = isAcheteur
        ? detail.confirmationAcheteur
        : detail.confirmationVendeur;

    if (dejaConfirme) {
      return Card(
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isAcheteur
                      ? 'Vous avez confirmé la réception'
                      : 'Vous avez confirmé l\'envoi',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () async {
        final confirmer = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmer la transaction'),
            content: Text(
              isAcheteur
                  ? 'Confirmez-vous avoir reçu les articles en bon état ?'
                  : 'Confirmez-vous avoir envoyé/livré les articles ?',
            ),
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

        if (confirmer == true) {
          await _confirmerTransaction();
        }
      },
      icon: const Icon(Icons.check_circle),
      label: Text(
        isAcheteur ? 'Confirmer la réception' : 'Confirmer l\'envoi',
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }
}