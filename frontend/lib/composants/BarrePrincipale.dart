import 'package:flutter/material.dart';
import '../services/notificationService.dart';
import '../models/Notification.dart';
import 'BadgeNotification.dart';

class BarrePrincipale extends StatelessWidget implements PreferredSizeWidget {
  final String titre;

  const BarrePrincipale({super.key, required this.titre});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 4,
      title: Text(
        titre,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: [
        // Badge notifications
        FutureBuilder<List<NotificationModel>>(
          future: NotificationService().obtenirNotifications(),
          builder: (context, snapshot) {
            final count = snapshot.hasData
                ? snapshot.data!.where((n) => !n.estLu).length
                : 0;
            return BadgeNotification(
              count: count,
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/panier');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MenuPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'BusyKin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Bienvenue!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildListTile(context, 'Accueil', Icons.home, '/accueil'),
                _buildListTile(context, 'Produits', Icons.store, '/catalogueProduits'),
                _buildListTile(context, 'Services', Icons.handshake, '/catalogueServices'),
                _buildListTile(context, 'Mes annonces', Icons.list_sharp, '/mesannonces'),
                _buildListTile(context, 'Panier', Icons.shopping_cart, '/panier'),
                _buildListTile(context, 'Messages', Icons.message, '/messages'),
                _buildListTile(context, 'Mes factures', Icons.receipt_long, '/transactions'),

                const Divider(height: 1, thickness: 1),

                _buildListTile(context, 'Profil', Icons.account_circle, '/profil'),
                _buildListTile(context, 'Se connecter', Icons.login, '/connexion'),
                _buildListTile(context, 'Inscription', Icons.app_registration, '/inscription'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}