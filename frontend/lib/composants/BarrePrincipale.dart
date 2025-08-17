import 'package:flutter/material.dart';

class BarrePrincipale extends StatelessWidget implements PreferredSizeWidget {
  final String titre;

  const BarrePrincipale({super.key, required this.titre});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titre),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer(); // ouvre le drawer
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class MenuPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text('Menu principal')),
          Container(
        alignment: Alignment.topRight,
        padding: EdgeInsets.all(16),
        child: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(); // ferme le Drawer
          },
        ),
      ),
          ListTile(
            title: Text('Accueil'),
            onTap: () => Navigator.pushNamed(context, '/accueil'),
          ),
          ListTile(
            title: Text('Catalogue'),
            onTap: () => Navigator.pushNamed(context, '/catalogue'),
          ),
          ListTile(
            title: Text('Profil'),
            onTap: () => Navigator.pushNamed(context, '/profil'),
          ),
        ],
      ),
    );
  }
}
