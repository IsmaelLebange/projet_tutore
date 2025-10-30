// ...existing code...
import 'package:flutter/material.dart';
import '../../services/administration/adminService.dart';
import '../../composants/AdminGate.dart';
import '../../composants/BarrePrincipale.dart'; // barre commune
import '../../models/Utilisateur.dart'; // model
import '../../models/Adresse.dart';

class CreationAdminForm extends StatefulWidget {
  const CreationAdminForm({super.key});
  @override
  State<CreationAdminForm> createState() => _CreationAdminFormState();
}

class _CreationAdminFormState extends State<CreationAdminForm> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController mdpCtrl = TextEditingController();
  final TextEditingController nomCtrl = TextEditingController();
  final TextEditingController prenomCtrl = TextEditingController();
  final TextEditingController telCtrl = TextEditingController();
  final TextEditingController communeCtrl = TextEditingController();
  final TextEditingController quartierCtrl = TextEditingController();
  final TextEditingController rueCtrl = TextEditingController();

  final AdminService _svc = AdminService();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    emailCtrl.dispose();
    mdpCtrl.dispose();
    nomCtrl.dispose();
    prenomCtrl.dispose();
    telCtrl.dispose();
    communeCtrl.dispose();
    quartierCtrl.dispose();
    rueCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    if (nomCtrl.text.trim().isEmpty ||
        prenomCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        mdpCtrl.text.isEmpty ||
        communeCtrl.text.trim().isEmpty) {
      setState(() {
        _error = "Remplis au moins : Nom, Prénom, Email, Mot de passe, Commune.";
        _isLoading = false;
      });
      return;
    }

    try {
      final utilisateur = Utilisateur(
        nom: nomCtrl.text.trim(),
        prenom: prenomCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        telephone: telCtrl.text.trim().isEmpty ? null : telCtrl.text.trim(),
        photoProfil: null,
        motDePasse: null,
        typeConnexion: 'classique',
        dateCreation: DateTime.now(),
        etat: "Actif",
        adresse: Adresse(
          commune: communeCtrl.text.trim(),
          quartier: quartierCtrl.text.trim(),
          rue: rueCtrl.text.trim(),
        ),
        role: 'admin',
      );

      await _svc.createAdminFromModel(utilisateur: utilisateur, password: mdpCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin créé avec succès')));
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: Scaffold(
        appBar: const BarrePrincipale(titre: "Ajouter un admin",),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom')),
                  const SizedBox(height: 8),
                  TextField(controller: prenomCtrl, decoration: const InputDecoration(labelText: 'Prénom')),
                  const SizedBox(height: 8),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 8),
                  TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Téléphone'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 8),
                  TextField(controller: communeCtrl, decoration: const InputDecoration(labelText: 'Commune')),
                  const SizedBox(height: 8),
                  TextField(controller: quartierCtrl, decoration: const InputDecoration(labelText: 'Quartier (optionnel)')),
                  const SizedBox(height: 8),
                  TextField(controller: rueCtrl, decoration: const InputDecoration(labelText: 'Rue (optionnel)')),
                  const SizedBox(height: 8),
                  TextField(controller: mdpCtrl, decoration: const InputDecoration(labelText: 'Mot de passe'), obscureText: true),
                  const SizedBox(height: 16),
                  if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () { _submit(); },
                    child: Text(_isLoading ? 'Création...' : 'Créer admin'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ...existing code...