import 'package:flutter/material.dart';
import '../../models/Notification.dart';
import '../../services/notificationService.dart';
import '../../composants/BarrePrincipale.dart';
import '../../composants/UserGate.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final NotificationService _service = NotificationService();
  late Future<List<NotificationModel>> _future;

  @override
  void initState() {
    super.initState();
    _rafraichir();
  }

  void _rafraichir() {
    setState(() {
      _future = _service.obtenirNotifications();
    });
  }

  Future<void> _confirmerTransaction(int transactionId) async {
    try {
      await _service.confirmerTransaction(transactionId);
      _rafraichir();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction confirmée')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _marquerLu(int notificationId) async {
    try {
      await _service.marquerLu(notificationId);
      _rafraichir();
    } catch (e) {
      print('Erreur marquer lu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserGate(
      child: Scaffold(
        appBar: const BarrePrincipale(titre: 'Notifications'),
        drawer: MenuPrincipal(),
        body: FutureBuilder<List<NotificationModel>>(
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
                    ElevatedButton(onPressed: _rafraichir, child: const Text('Réessayer')),
                  ],
                ),
              );
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Aucune notification', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _rafraichir(),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final isTransaction = notif.typeNotification == 'commande_recue';

                  return Card(
                    child: ListTile(
                      onTap: notif.estLu ? null : () => _marquerLu(notif.id),
                      leading: CircleAvatar(
                        backgroundColor: _getColorForType(notif.typeNotification),
                        child: Icon(_getIconForType(notif.typeNotification), color: Colors.white),
                      ),
                      title: Text(
                        notif.titre,
                        style: TextStyle(
                          fontWeight: notif.estLu ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notif.message),
                          const SizedBox(height: 8),
                          if (isTransaction && notif.idTransaction != null)
                            ElevatedButton.icon(
                              onPressed: () => _confirmerTransaction(notif.idTransaction!),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Confirmer', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 32),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          Text(
                            _formatDate(notif.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: notif.estLu ? null : Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
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

  Color _getColorForType(String type) {
    switch (type) {
      case 'commande_recue': return Colors.blue;
      case 'commande_confirmee': return Colors.orange;
      case 'transaction_validee': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'commande_recue': return Icons.shopping_bag;
      case 'commande_confirmee': return Icons.check_circle;
      case 'transaction_validee': return Icons.payment;
      default: return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }
}