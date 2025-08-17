import 'package:flutter/material.dart';

class CarteService extends StatelessWidget {
  final String titre;
  final String description;
  final double prix;
  final VoidCallback onTap;

  const CarteService({
    super.key,
    required this.titre,
    required this.description,
    required this.prix,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text(
                "$prix \$",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
