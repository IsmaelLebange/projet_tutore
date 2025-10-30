import 'package:flutter/material.dart';
import 'package:frontend/composants/BarrePrincipale.dart';
import '../../composants/ChampTexte.dart';
import '../../composants/BoutonPrincipal.dart';
import '../../services/authService.dart'; 

class Inscription extends StatefulWidget {
  Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final TextEditingController nomCtrl = TextEditingController();
  final TextEditingController prenomCtrl = TextEditingController(); 
  final TextEditingController telCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController mdpCtrl = TextEditingController();
  final TextEditingController communeCtrl=TextEditingController();
  final TextEditingController quartierCtrl=TextEditingController();
  final TextEditingController rueCtrl=TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleRegistration() async {
    if (nomCtrl.text.isEmpty || prenomCtrl.text.isEmpty || emailCtrl.text.isEmpty || mdpCtrl.text.isEmpty || communeCtrl.text.isEmpty) {
      setState(() {
        _errorMessage = "Tous les champs marqués comme obligatoires (Nom, Prénom, Email, MDP, Commune) doivent être remplis.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _authService.register(
      nom: nomCtrl.text,
      prenom: prenomCtrl.text, 
      telephone: telCtrl.text,
      email: emailCtrl.text,
      password: mdpCtrl.text,
      commune: communeCtrl.text,
      quartier: quartierCtrl.text.isEmpty ? null : quartierCtrl.text,
      rue: rueCtrl.text.isEmpty ? null : rueCtrl.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (response.error != null) {
      setState(() {
        _errorMessage = response.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.error!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription réussie! Veuillez vous connecter.')),
      );
      // Redirection vers la page de connexion
      Navigator.pushReplacementNamed(context, '/connexion'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarrePrincipale(titre: "Inscription"),
      body: Center( 
        child: ConstrainedBox( 
          constraints: const BoxConstraints(maxWidth: 400), 
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ChampTexte(label: "Prénom (Obligatoire)", controller: prenomCtrl), 
                const SizedBox(height: 15),
                ChampTexte(label: "Nom (Obligatoire)", controller: nomCtrl), 
                const SizedBox(height: 15),
                ChampTexte(label: "Tel", controller: telCtrl, typeClavier: TextInputType.phone),
                const SizedBox(height: 15),
                ChampTexte(
                  label: "Email (Obligatoire)",
                  controller: emailCtrl,
                  typeClavier: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                ChampTexte(label: "Commune (Obligatoire)", controller: communeCtrl),
                const SizedBox(height: 15),
                ChampTexte(label: "Quartier", controller: quartierCtrl),
                const SizedBox(height: 15),
                ChampTexte(label: "Rue", controller: rueCtrl),
                const SizedBox(height: 15),
                ChampTexte(
                  label: "Mot de passe (Obligatoire)",
                  controller: mdpCtrl,
                  estMotDePasse: true,
                ),
                const SizedBox(height: 25),

                BoutonPrincipal(
                  texte: _isLoading ? "Inscription en cours..." : "S'inscrire",
                  // Correction : Utilisation de _handleRegistration au lieu de _handleLogin
                  onPressed: () {
                    if (_isLoading) return;
                    _handleRegistration();
                  },
                  couleur: Colors.green,
                  icone: Icons.person_add,
                ),
                
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/connexion');
                  },
                  child: const Text("Déjà un compte ? Connectez-vous"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
