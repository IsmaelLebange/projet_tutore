import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/transactionService.dart';
import '../../models/Transaction.dart';
import '../../composants/BarrePrincipale.dart';
import '../../composants/UserGate.dart';

class ListeTransactions extends StatefulWidget {
  const ListeTransactions({super.key});

  @override
  State<ListeTransactions> createState() => _ListeTransactionsState();
}

class _ListeTransactionsState extends State<ListeTransactions> {
  final TransactionService _service = TransactionService();
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _rafraichir();
  }

  void _rafraichir() {
    setState(() {
      _transactionsFuture = _service.obtenirMesTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return UserGate(
      child: Scaffold(
        appBar: const BarrePrincipale(titre: 'Mes Factures'),
        drawer: MenuPrincipal(),
        body: RefreshIndicator(
          onRefresh: () async => _rafraichir(),
          child: FutureBuilder<List<TransactionModel>>(
            future: _transactionsFuture,
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
                        onPressed: _rafraichir,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
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
                        'Aucune transaction',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vos achats et ventes apparaîtront ici',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionCard(transaction);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isAcheteur = transaction.role == 'acheteur';
    final autrePartie = isAcheteur ? transaction.vendeur : transaction.acheteur;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detailTransaction',
            arguments: transaction.id,
          ).then((_) => _rafraichir());
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image ou icône
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: transaction.premiereImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'http://localhost:3000${transaction.premiereImage}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                          ),
                        ),
                      )
                    : Icon(
                        Icons.receipt_long,
                        size: 40,
                        color: Colors.grey[400],
                      ),
              ),
              const SizedBox(width: 12),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isAcheteur ? Colors.blue[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isAcheteur ? 'ACHAT' : 'VENTE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isAcheteur ? Colors.blue[700] : Colors.green[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          transaction.code,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Text(
                      isAcheteur
                          ? 'Vendeur: ${autrePartie.nom}'
                          : 'Acheteur: ${autrePartie.nom}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(Icons.shopping_bag, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${transaction.nbArticles} article(s)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(transaction.dateTransaction),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${transaction.montant.toStringAsFixed(2)} FC',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        _buildStatutBadge(transaction.statut),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatutBadge(String statut) {
    Color couleur;
    IconData icone;

    switch (statut) {
      case 'En_attente':
        couleur = Colors.orange;
        icone = Icons.hourglass_empty;
        break;
      case 'En_attente_confirmation':
        couleur = Colors.blue;
        icone = Icons.check_circle_outline;
        break;
      case 'Confirmée':
        couleur = Colors.green;
        icone = Icons.check_circle;
        break;
      case 'Validée':
        couleur = Colors.teal;
        icone = Icons.verified;
        break;
      case 'Rejetée':
        couleur = Colors.red;
        icone = Icons.cancel;
        break;
      default:
        couleur = Colors.grey;
        icone = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: couleur.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: couleur),
          const SizedBox(width: 4),
          Text(
            statut.replaceAll('_', ' '),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }
}