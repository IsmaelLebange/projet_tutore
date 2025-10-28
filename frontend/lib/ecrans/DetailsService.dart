import 'package:flutter/material.dart';
import '../models/Service.dart';
import '../composants/BarrePrincipale.dart';

class DetailsService extends StatelessWidget {
  final Service service;

  const DetailsService({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          service.titre,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du service
            Image.network(
              service.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            // Titre et prix
            Text(
              service.titre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${service.prix} €',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Disponibilité
            Row(
              children: [
                Icon(
                  (service.disponibilite ?? false)
                    ? Icons.check_circle 
                    : Icons.cancel,
                  color: (service.disponibilite ?? false)
                    ? Colors.green 
                    : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  (service.disponibilite ?? false)
                    ? 'Disponible' 
                    : 'Non disponible',
                  style: TextStyle(
                    color: (service.disponibilite ?? false)
                      ? Colors.green 
                      : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Description
            const Text(
              'Description du service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(service.description),
          ],
        ),
      ),
    );
  }
}