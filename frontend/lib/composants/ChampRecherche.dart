import 'package:flutter/material.dart';

class ChampRecherche extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Rechercher un produit ou service',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            print('Recherche : ${controller.text}');
          },
          child: Icon(Icons.search),
        ),
      ],
    );
  }
}
