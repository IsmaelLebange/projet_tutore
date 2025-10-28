import 'package:flutter/material.dart';

class ChampTexte extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool estMotDePasse;
  final TextInputType typeClavier;

  const ChampTexte({
    super.key,
    required this.label,
    required this.controller,
    this.estMotDePasse = false,
    this.typeClavier = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: estMotDePasse,
      keyboardType: typeClavier,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
