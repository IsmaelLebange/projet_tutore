import 'package:flutter/material.dart';

class BoutonPrincipal extends StatelessWidget {
  final String texte;
  final VoidCallback onPressed;
  final Color couleur;
  final IconData? icone;

  const BoutonPrincipal({
    super.key,
    required this.texte,
    required this.onPressed,
    this.couleur = Colors.blue,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: couleur,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      icon: icone != null ? Icon(icone, color: Colors.white) : const SizedBox.shrink(),
      label: Text(
        texte,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}