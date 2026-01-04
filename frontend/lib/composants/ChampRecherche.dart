import 'package:flutter/material.dart';

class ChampRecherche extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? recherche;

  const ChampRecherche({super.key, this.controller, this.recherche});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (_) {
              if (recherche != null) recherche!();
            },
            decoration: InputDecoration(
              hintText: 'Rechercher un produit ou service',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(onPressed: recherche, child: Icon(Icons.search)),
      ],
    );
  }
}
