import 'package:flutter/material.dart';

class ProfilUtilisateur extends StatelessWidget {
  const ProfilUtilisateur({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profil")),
      body: Center(
        child: Text("Espace utilisateur"),
      ),
    );    
    }      
}