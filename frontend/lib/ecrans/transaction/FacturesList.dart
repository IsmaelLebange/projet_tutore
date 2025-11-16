import 'package:flutter/material.dart';
import '../../services/transactionService.dart';
import '../../composants/BarrePrincipale.dart';
import '../../composants/UserGate.dart';

class FacturesList extends StatefulWidget {
  const FacturesList({super.key});

  @override
  State<FacturesList> createState() => _FacturesListState();
}

class _FacturesListState extends State<FacturesList> {
  final TransactionService _service = TransactionService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _rafraichir();
  }

  void _rafraichir() {
    setState(() {
      _future = _service.obtenirTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return UserGate(
      child: Scaffold(
        appBar: const BarrePrincipale(titre: 'Mes Factures'),
        drawer: MenuPrincipal(),
        body: FutureBuilder<List<Map<String, dynamic>>>(
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
                      onPressed: _rafraichir,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final transactions = snapshot.data ?? [];

            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune facture',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _rafraichir(),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final codeTransaction = 'CMD-${transaction['id'].toString().padLeft(6, '0')}';
                  final statut = transaction['statut_transaction'] ?? '';
                  final montant = transaction['montant'] ?? 0.0;
                  final date = transaction['date_transaction'] != null
                      ? DateTime.parse(transaction['date_transaction'])
                      : DateTime.now();

                  return Card(
                    elevation: 2,
                    child: ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/facture',
                          arguments: transaction['id'],
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: _getColorForStatut(statut),
                        child: const Icon(Icons.receipt, color: Colors.white),
                      ),
                      title: Text(
                        codeTransaction,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Montant: ${montant.toStringAsFixed(2)} FC'),
                          Text('Statut: $statut'),
                          Text(
                            _formatDate(date),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}
