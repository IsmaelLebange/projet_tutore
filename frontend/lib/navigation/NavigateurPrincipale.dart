import 'package:flutter/material.dart';
import 'package:frontend/ecrans/annonces/AjoutAnnonce.dart';
import 'package:frontend/ecrans/authentification/Connexion.dart';
import 'package:frontend/ecrans/message/Discussion.dart';
import 'package:frontend/ecrans/administration/GestionAnnoncesAdmin.dart';
import 'package:frontend/ecrans/administration/GestionUtilisateursAdmin.dart';
import 'package:frontend/ecrans/authentification/Inscription.dart';
import 'package:frontend/ecrans/annonces/MesAnnonces.dart';
import 'package:frontend/ecrans/administration/ModerationLitigesAdmin.dart';
import 'package:frontend/ecrans/administration/StatistiquesAdmin.dart';
import 'package:frontend/models/Annonce.dart';
import '../ecrans/Accueil.dart';
import '../ecrans/annonces/CatalogueProduits.dart';
import '../ecrans/annonces/CatalogueServices.dart';
import '../ecrans/ProfilUtilisateur.dart';
import '../ecrans/Parametres.dart';
import '../ecrans/message/Messagerie.dart';
import '../ecrans/Favoris.dart';
import '../ecrans/Panier.dart';
import '../ecrans/administration/Administration.dart';


class NavigateurPrincipal extends StatefulWidget {
  @override
  _NavigateurPrincipalState createState() => _NavigateurPrincipalState();
}

class _NavigateurPrincipalState extends State<NavigateurPrincipal> {
  Widget _pageActuelle = Accueil();

  void _changerPage(Widget nouvellePage) {
    setState(() {
      _pageActuelle = nouvellePage;
    });
    Navigator.of(context).pop(); // ferme le drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageActuelle,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu Principal", style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Accueil"),
              onTap: () => _changerPage(Accueil()),
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text("Produits"),
              onTap: () => _changerPage(CatalogueProduits()),
            ),
            ListTile(
              leading: Icon(Icons.build),
              title: Text("Services"),
              onTap: () => _changerPage(CatalogueServices()),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profil"),
              onTap: () => _changerPage(ProfilUtilisateur()),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Connexion"),
              onTap: () => _changerPage(Connexion()),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text("Inscription"),
              onTap: () => _changerPage(Inscription()),
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Favoris"),
              onTap: () => _changerPage(AjoutAnnonce()),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text("Panier"),
              onTap: () => _changerPage(Panier()),
            ),

            ListTile(
              leading: Icon(Icons.message),
              title: Text("Messagerie"),
              onTap: () => _changerPage(Messagerie()),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Mes annonces"),
              onTap: () => _changerPage(MesAnnonces()),
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text("Administration"),
              onTap: ()=>_changerPage(Administration())
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Gestion Annonces"),
              onTap: () => _changerPage(GestionAnnoncesAdmin()),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Gestion Utilisateurs"),
              onTap: () => _changerPage(GestionUtilisateursAdmin()),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Statistiques Admin"),
              onTap: () => _changerPage(StatistiquesAdmin()),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Modération Litiges"),
              onTap: () => _changerPage(ModerationLitigesAdmin()),
            ),
            
          ],
        ),
      ),
    );
  }
}
