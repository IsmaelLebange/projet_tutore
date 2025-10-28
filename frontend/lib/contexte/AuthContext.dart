import 'package:flutter/material.dart';
import '../models/Utilisateur.dart';

class AuthContext extends InheritedWidget {
  final Utilisateur? utilisateur;
  final Function deconnexion;

  const AuthContext({
    super.key,
    required this.utilisateur,
    required this.deconnexion,
    required super.child,
  });

  static AuthContext of(BuildContext context) {
    final AuthContext? result =
        context.dependOnInheritedWidgetOfExactType<AuthContext>();
    assert(result != null, 'No AuthContext found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AuthContext oldWidget) =>
      utilisateur != oldWidget.utilisateur;
}
