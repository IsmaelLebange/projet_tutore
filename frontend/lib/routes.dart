import 'package:flutter/material.dart';
import '../ecrans/Accueil.dart';
import '../ecrans/CatalogueProduits.dart';
import '../ecrans/ProfilUtilisateur.dart';
import '../tests/TestCatalogue';
import 'package:frontend/navigation/NavigateurPrincipale.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    '/': (context) => NavigateurPrincipal(),
    '/catalogue': (context) => CatalogueProduits(),
    '/profil': (context) => ProfilUtilisateur(),
    '/accueil': (context) => Accueil(),
    '/TestCatalogue': (context)=> TestCatalogue()
  };
}
