import 'package:flutter/material.dart';

class Panierfavoriscontext extends ChangeNotifier {
  List<Map<String,dynamic>> _panier=[];
  List<Map<String,dynamic>> _favoris=[];

  List<Map<String,dynamic>> get panier => _panier;
  List<Map<String,dynamic>> get favoris => _favoris;

  void ajouterAuPanier(Map<String,dynamic>produit){
    _panier.add(produit);
    notifyListeners();
  }

  void retirerDuPanier(Map<String,dynamic>produit){
    _panier.removeWhere((p)=>p['id']==produit['id']);
    notifyListeners();
  }

  void ajouterAuxFavoris(Map<String,dynamic>produit){
    _favoris.add(produit);
    notifyListeners();
  }

  void retirerDesFavoris(Map<String,dynamic>produit){
    _favoris.removeWhere((p)=>p['id']==produit['id']);
    notifyListeners();
  }
}