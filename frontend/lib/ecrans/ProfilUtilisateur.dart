import 'package:flutter/material.dart';
import 'package:frontend/composants/BoutonPrincipal.dart';
import 'package:frontend/services/authService.dart';
import '../composants/BarrePrincipale.dart';
import '../contexte/AuthContext.dart';
import '../models/Utilisateur.dart';
import '../services/utilisateurService.dart';

class ProfilUtilisateur extends StatefulWidget {
  const ProfilUtilisateur({super.key});

  @override
  State<ProfilUtilisateur> createState() => ProfilUtilisateurState();
}

class ProfilUtilisateurState extends State<ProfilUtilisateur> {
  final UtilisateurService _utilisateurService = UtilisateurService();
  final AuthService _authService = AuthService();

  Utilisateur? utilisateur;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerProfil();
  }

  Future<void> _chargerProfil() async {
    try {
      final result = await _utilisateurService.getProfil();
      setState(() {
        utilisateur = result;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement profil: $e');
      setState(() {
        utilisateur = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    // 🔄 Chargement
    if (_isLoading) {
      return Scaffold(
        appBar: const BarrePrincipale(titre: 'Mon Profil'),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement de votre profil...'),
            ],
          ),
        ),
      );
    }

    // ❌ Pas connecté / erreur
    if (utilisateur == null) {
      return Scaffold(
        appBar: const BarrePrincipale(titre: 'Mon Profil'),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Impossible de charger votre profil',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous pour voir vos informations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _chargerProfil,
                  child: const Text('Réessayer'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/connexion'),
                  child: const Text('Aller à la page de connexion'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 🔐 Contexte auth (optionnel)
    try {
      AuthContext.of(context);
    } catch (e) {
      print('⚠️ Contexte Auth non disponible: $e');
    }

    // ✅ ÉCRAN PRINCIPAL
    return Scaffold(
      appBar: const BarrePrincipale(titre: 'Mon Profil'),
      drawer: MenuPrincipal(),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700, // 👈 largeur max PC / Web
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 👤 Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: utilisateur!.photoProfil != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              utilisateur!.photoProfil!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Icon(
                                  Icons.person,
                                  size: 60,
                                  color: primaryColor,
                                );
                              },
                            ),
                          )
                        : Icon(Icons.person,
                            size: 60, color: primaryColor),
                  ),

                  const SizedBox(height: 20),

                  // 👤 Nom
                  Text(
                    "${utilisateur!.prenom} ${utilisateur!.nom}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 📧 Email
                  Text(
                    utilisateur!.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Divider(),

                  _buildInfoTile(
                    context,
                    Icons.phone,
                    "Téléphone",
                    utilisateur!.telephone ?? "Non renseigné",
                  ),
                  _buildInfoTile(
                    context,
                    Icons.location_on,
                    "Ville",
                    utilisateur!.adresse?.commune ?? "Non renseigné",
                  ),

                  const Divider(),
                  const SizedBox(height: 30),

                  // ✏️ Modifier
                  BoutonPrincipal(
                    texte: "Modifier le profil",
                    icone: Icons.edit,
                    couleur: primaryColor,
                    onPressed: () {
                      Navigator.pushNamed(context, '/modifierProfil');
                    },
                  ),

                  const SizedBox(height: 10),

                  // 🚪 Déconnexion
                  BoutonPrincipal(
                    texte: "Se déconnecter",
                    icone: Icons.logout,
                    onPressed: () {
                      _authService.logout(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🧩 Tuile info
  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Text(
        value,
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }
}
