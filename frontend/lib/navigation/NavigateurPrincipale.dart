import 'package:flutter/material.dart';
import 'package:frontend/ecrans/CatalogueProduits.dart';
import '../ecrans/Accueil.dart';
import '../tests/TestCatalogue';
import '../ecrans/ProfilUtilisateur.dart';
import '../ecrans/CatalogueProduits.dart';

class NavigateurPrincipal extends StatefulWidget {
  const NavigateurPrincipal({super.key});

  @override
  State<NavigateurPrincipal> createState() => _NavigateurPrincipalState();
}

class _NavigateurPrincipalState extends State<NavigateurPrincipal> {
  int _indexActuel = 0;

  final List<Widget> _ecrans = [
    CatalogueProduits(),
    const Accueil(),
    const ProfilUtilisateur(),
  ];

  void _changerOnglet(int index) {
    setState(() {
      _indexActuel = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ecrans[_indexActuel],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexActuel,
        onTap: _changerOnglet,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Catalogue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
