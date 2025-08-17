import 'package:flutter/material.dart';

class TitreSection extends StatelessWidget {
  final String titre;

  const TitreSection({super.key, required this.titre});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        titre,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

