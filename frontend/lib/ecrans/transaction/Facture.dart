import 'package:flutter/material.dart';
import '../../services/transactionService.dart';
import '../../composants/BarrePrincipale.dart';
import '../../composants/UserGate.dart';

class Facture extends StatefulWidget {
  const Facture({super.key});

  @override
  State<Facture> createState() => _FactureState();
}

class _FactureState extends State<Facture> {
  final TransactionService _service = TransactionService();
  late Future<Map<String, dynamic>> _future;
  int? _transactionId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_transactionId == null) {
      _transactionId = ModalRoute.of(context)!.settings.arguments as int;
      _chargerFacture();
    }
  }

  void _chargerFacture() {
    setState(() {
      _future = _service.obtenirFacture(_transactionId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return UserGate(
      child: Scaffold(
        appBar: const BarrePrincipale(titre: 'Détail Facture'),
        drawer: MenuPrincipal(),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _future,
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
                      onPressed: _chargerFacture,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final facture = snapshot.data!;
            final lignes = facture['lignes'] as List<dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête facture
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                facture['codeTransaction'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  facture['statut_transaction'] ?? '',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: _getColorForStatut(
                                  facture['statut_transaction'] ?? '',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Date: ${_formatDate(facture['date_transaction'])}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informations acheteur
                  _buildInfoCard(
                    'Acheteur',
                    Icons.person,
                    facture['acheteur'],
                  ),
                  const SizedBox(height: 12),

                  // Informations vendeur
                  _buildInfoCard(
                    'Vendeur',
                    Icons.store,
                    facture['vendeur'],
                  ),
                  const SizedBox(height: 16),

                  // Lignes de commande
                  const Text(
                    'Articles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...lignes.map((ligne) => _buildLigneCard(ligne)).toList(),
                  const SizedBox(height: 16),

                  // Totaux
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTotalRow(
                            'Sous-total',
                            facture['total'] ?? 0.0,
                          ),
                          const Divider(),
                          _buildTotalRow(
                            'Commission',
                            facture['commission'] ?? 0.0,
                          ),
                          const Divider(thickness: 2),
                          _buildTotalRow(
                            'TOTAL',
                            facture['montant'] ?? 0.0,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton export PDF (placeholder)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Export PDF non implémenté pour le moment'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Exporter en PDF (Bientôt disponible)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, Map<String, dynamic> info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Nom: ${info['nom'] ?? ''}'),
            Text('Email: ${info['email'] ?? ''}'),
            if (info['telephone'] != null && info['telephone'].toString().isNotEmpty)
              Text('Téléphone: ${info['telephone']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLigneCard(Map<String, dynamic> ligne) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ligne['titre'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ligne['description'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type: ${ligne['type']} | Qté: ${ligne['quantite']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${ligne['prixUnitaire'].toStringAsFixed(2)} FC',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ligne['sousTotal'].toStringAsFixed(2)} FC',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double montant, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '${montant.toStringAsFixed(2)} FC',
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Theme.of(context).primaryColor : null,
          ),
        ),
      ],
    );
  }

  Color _getColorForStatut(String statut) {
    switch (statut) {
      case 'Validée':
        return Colors.green;
      case 'En_attente_confirmation':
        return Colors.orange;
      case 'Confirmée':
        return Colors.blue;
      case 'Rejetée':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
