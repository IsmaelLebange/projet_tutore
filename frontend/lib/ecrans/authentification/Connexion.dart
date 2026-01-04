import 'package:flutter/material.dart';
import 'package:frontend/composants/BarrePrincipale.dart';
import 'package:frontend/services/administration/adminService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../composants/ChampTexte.dart';
import '../../composants/BoutonPrincipal.dart';
import '../../services/authService.dart';

class Connexion extends StatefulWidget {
  Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController mdpCtrl = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (emailCtrl.text.isEmpty || mdpCtrl.text.isEmpty) {
      setState(() {
        _errorMessage = "L'email et le mot de passe sont obligatoires.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _authService.login(emailCtrl.text, mdpCtrl.text);

    setState(() {
      _isLoading = false;
    });

    if (response.error != null) {
      setState(() {
        _errorMessage = response.error;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.error!)));
    } else {
      // Connexion réussie, utilise Navigator pour aller à la page d'accueil ou au tableau de bord
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenue, ${response.utilisateur!.prenom} !')),
      );
      print('🎯 Connexion réussie - Rôle: ${response.utilisateur!.role}');
      final token = await _authService.getToken();

      if (response.utilisateur!.role == 'admin') {
        // Stocke le token manuellement
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', response.token!);

        Navigator.pushReplacementNamed(context, '/administration');
      } else {
        Navigator.pushReplacementNamed(context, '/accueil');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarrePrincipale(titre: "Connexion"),
      drawer: MenuPrincipal(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Authentification",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 30),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ChampTexte(
                  label: "Email",
                  controller: emailCtrl,
                  typeClavier: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                ChampTexte(
                  label: "Mot de passe",
                  controller: mdpCtrl,
                  estMotDePasse: true,
                ),
                const SizedBox(height: 25),

                BoutonPrincipal(
                  texte: _isLoading ? "Connexion en cours..." : "Se connecter",
                  onPressed: () {
                    if (_isLoading) return;
                    // Correction : la méthode de gestion de la connexion s'appelle _handleLogin()
                    // et non _handleRegistration(). On appelle donc _handleLogin() ici.
                    _handleLogin();
                  },
                  couleur: Colors.blue.shade700,
                  icone: Icons.login,
                ),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/inscription');
                  },
                  child: const Text("Pas encore de compte ? S'inscrire"),
                ),

                TextButton(
                  onPressed: () {
                  },
                  child: const Text("Mot de passe oublié ?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
