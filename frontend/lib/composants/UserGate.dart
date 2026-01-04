// lib/composants/UserGate.dart
import 'package:flutter/material.dart';
import '../services/utilisateurService.dart';
import '../services/authService.dart';
import '../models/Utilisateur.dart';

class UserGate extends StatelessWidget {
  final Widget child;
  final UtilisateurService? utilisateurService;

  const UserGate({super.key, required this.child, this.utilisateurService});

  @override
  Widget build(BuildContext context) {
    final svc = utilisateurService ?? UtilisateurService();

    return FutureBuilder<Utilisateur?>(
      future: svc.getProfil(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        

        if (!snapshot.hasData || snapshot.data == null) {
          return _AccesRefuse(
            message: "Tu dois être connecté pour accéder à cette page.",
            boutonTexte: "Aller à la connexion",
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/connexion'),
          );
        }

        final user = snapshot.data!;
        if (user.etat != "Actif") {
          return _AccesRefuse(
            message: "Ton compte est bloqué. Contacte l'administration.",
            boutonTexte: "Se déconnecter",
            onPressed: () async {
              final auth = AuthService();
              final prefs = await auth.logout(context); // à faire si tu veux un logout
              Navigator.pushReplacementNamed(context, '/connexion');
            },
          );
        }

        return child; // ✅ tout va bien, on affiche la page demandée
      },
    );
  }
}

// UI pour les refus d'accès
class _AccesRefuse extends StatelessWidget {
  final String message;
  final String boutonTexte;
  final VoidCallback onPressed;

  const _AccesRefuse({
    required this.message,
    required this.boutonTexte,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accès Refusé')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: Text(boutonTexte),
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
