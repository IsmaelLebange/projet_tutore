// DANS ProfilUtilisateur.dart

import 'package:flutter/material.dart';
import '../composants/BarrePrincipale.dart'; // 🚨 Ton composant
import '../contexte/AuthContext.dart';
import '../models/Utilisateur.dart';

class ProfilUtilisateur extends StatelessWidget {
  const ProfilUtilisateur({super.key});

  @override
  Widget build(BuildContext context) {
    AuthContext? auth;
    Utilisateur? utilisateur;

    try {
      auth = AuthContext.of(context);
      utilisateur = auth.utilisateur;
    } catch (e) {
      utilisateur = null;
    }
    
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // 🚨 Utilisation de BarrePrincipale pour la cohérence
      appBar: const BarrePrincipale(titre: 'Mon Profil'),
      drawer: MenuPrincipal(), 
      body: SingleChildScrollView( // Ajout de SingleChildScrollView pour prévenir les overflows
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 60, // Augmenté pour l'impact visuel
              backgroundColor: primaryColor.withOpacity(0.1),
              child: utilisateur?.photoProfil != null
                ? null // Utiliser un BackgroundImage si tu as des URL réelles
                : Icon(Icons.person, size: 60, color: primaryColor), // Icône par défaut
            ),
            const SizedBox(height: 20),

            // Nom
            Text(
              utilisateur?.nom != null && utilisateur?.prenom != null
                  ? "${utilisateur!.prenom} ${utilisateur!.nom}"
                  : "Aucun utilisateur connecté",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              utilisateur?.email ?? "Connectez-vous pour voir vos informations",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // ------------------------------------
            // INFORMATIONS ADDITIONNELLES
            // ------------------------------------
            const Divider(),
            _buildInfoTile(context, Icons.phone, "Téléphone", utilisateur?.telephone ?? "Non renseigné"),
            _buildInfoTile(context, Icons.location_on, "Ville", utilisateur?.adresse?.commune ?? "Non renseigné"),
            const Divider(),
            const SizedBox(height: 30),


            // Boutons d'action
            if (utilisateur != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/modifierProfil');
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier le profil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // Utilise la couleur principale pour l'action positive
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    auth!.deconnexion();
                    Navigator.pushReplacementNamed(context, '/connexion');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Se déconnecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400, // Une couleur d'alerte cohérente
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              Text(
                "Connectez-vous pour accéder à votre profil complet.",
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/connexion'),
                child: Text('Aller à la page de connexion', style: TextStyle(color: primaryColor)),
              )
            ],
          ],
        ),
      ),
    );
  }
  
  // Helper pour afficher les infos
  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Text(value, style: const TextStyle(color: Colors.black87)),
    );
  }
}