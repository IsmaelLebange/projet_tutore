import 'package:flutter/material.dart';

class Authcontext extends ChangeNotifier{
  bool _estConnecte=false;
  Map<String, dynamic>? _utilisateur;

  bool get estConnecte=> _estConnecte;
  Map<String, dynamic>? get utilisateur => _utilisateur;

  void connecter(Map<String, dynamic>userData){
    _estConnecte;
    _utilisateur=userData;
    notifyListeners();
  }

  void deconnecter(){
    _estConnecte=false;
    _utilisateur=null;
    notifyListeners();
  }
}