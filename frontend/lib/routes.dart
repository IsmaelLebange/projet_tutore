import 'package:flutter/material.dart';
import 'package:frontend/ecrans/annonces/AjoutAnnonce.dart';
import 'package:frontend/ecrans/administration/CreationAdmin.dart';
import 'package:frontend/ecrans/administration/GestionAnnoncesAdmin.dart';
import 'package:frontend/ecrans/administration/GestionAnnoncesAdmin.dart';
import 'package:frontend/ecrans/administration/GestionUtilisateursAdmin.dart';
import 'package:frontend/ecrans/authentification/Inscription.dart';
import 'package:frontend/ecrans/annonces/MesAnnonces.dart';
import 'package:frontend/ecrans/message/Messagerie.dart';
import 'package:frontend/ecrans/administration/ModerationLitigesAdmin.dart';
import 'package:frontend/ecrans/administration/StatistiquesAdmin.dart';
import '../ecrans/Accueil.dart';
import 'ecrans/annonces/CatalogueProduits.dart';
import '../ecrans/ProfilUtilisateur.dart';
import '../tests/TestCatalogue';
import 'package:frontend/navigation/NavigateurPrincipale.dart';
import 'ecrans/annonces/CatalogueServices.dart';
import 'ecrans/authentification/Connexion.dart';
import '../ecrans/Panier.dart';
import 'ecrans/administration/Administration.dart';


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
