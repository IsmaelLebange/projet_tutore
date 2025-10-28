import 'package:flutter/material.dart';
import 'package:frontend/ecrans/AjoutAnnonce.dart';
import 'package:frontend/ecrans/CreationAdmin.dart';
import 'package:frontend/ecrans/GestionAnnoncesAdmin.dart';
import 'package:frontend/ecrans/GestionAnnoncesAdmin.dart';
import 'package:frontend/ecrans/GestionUtilisateursAdmin.dart';
import 'package:frontend/ecrans/Inscription.dart';
import 'package:frontend/ecrans/MesAnnonces.dart';
import 'package:frontend/ecrans/Messagerie.dart';
import 'package:frontend/ecrans/ModerationLitigesAdmin.dart';
import 'package:frontend/ecrans/StatistiquesAdmin.dart';
import '../ecrans/Accueil.dart';
import '../ecrans/CatalogueProduits.dart';
import '../ecrans/ProfilUtilisateur.dart';
import '../tests/TestCatalogue';
import 'package:frontend/navigation/NavigateurPrincipale.dart';
import '../ecrans/CatalogueServices.dart';
import '../ecrans/Connexion.dart';
import '../ecrans/Panier.dart';
import '../ecrans/Administration.dart';


Map<String, WidgetBuilder> getRoutes() {
  return {
    
    '/accueil': (context) => Accueil(),
    '/': (context) => NavigateurPrincipal(),
    '/catalogueProduits': (context) => CatalogueProduits(),
    '/profil': (context) => ProfilUtilisateur(),
    '/catalogueServices': (context)=> CatalogueServices(),
    '/connexion': (context) => Connexion(),
    '/inscription': (context) => Inscription(),
    '/annonces': (context) => AjoutAnnonce(), 
    '/panier': (context) => Panier(),
    '/messages': (context) => Messagerie(),
    '/mesannonces': (context) => MesAnnonces(),
    '/administration': (context) =>  Administration(),
    '/admin/annonces': (context) =>  GestionAnnoncesAdmin(),
    '/admin/utilisateurs': (context) => GestionUtilisateursAdmin(),
    '/admin/stats': (context) =>  StatistiquesAdmin(),
    '/admin/litiges': (context) => ModerationLitigesAdmin(),
    '/admin/create':(context) => CreationAdminForm(),
    // ...
  };
}
