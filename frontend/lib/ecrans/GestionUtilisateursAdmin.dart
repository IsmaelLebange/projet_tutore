// GestionUtilisateursAdmin.dart
import 'package:flutter/material.dart';
import '../composants/BarrePrincipale.dart';
import '../composants/AdminGate.dart';
import '../services/administration/gestionUtilisateurService.dart';
import '../models/Utilisateur.dart';

class GestionUtilisateursAdmin extends StatefulWidget {
  const GestionUtilisateursAdmin({super.key});

  @override
  State<GestionUtilisateursAdmin> createState() =>
      _GestionUtilisateursAdminState();
}

class _GestionUtilisateursAdminState extends State<GestionUtilisateursAdmin> {
  final GestionUtilisateurService _service =
      GestionUtilisateurService(); // ✅ SERVICE SPÉCIALISÉ
  List<Utilisateur> _utilisateurs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerUtilisateurs();
  }

  Future<void> _chargerUtilisateurs() async {
    try {
      final users = await _service.getUtilisateurs();
      setState(() {
        _utilisateurs = users;
        _loading = false;
      });
    } catch (e) {
      print('Erreur chargement utilisateurs: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _changerEtat(Utilisateur user, bool actif) async {
    try {
      await _service.changerEtatUtilisateur(
        user.id!,
        actif ? 'Actif' : 'Bloqué',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.prenom} ${actif ? 'débloqué' : 'bloqué'}'),
        ),
      );
      _chargerUtilisateurs();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _changerRole(Utilisateur user, String nouveauRole) async {
    try {
      await _service.changerRoleUtilisateur(user.id!, nouveauRole);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Rôle changé en $nouveauRole')));
      _chargerUtilisateurs();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  void _showChangerRoleDialog(Utilisateur user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer rôle de ${user.prenom}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['utilisateur', 'admin', 'moderateur'].map((role) {
            return ListTile(
              title: Text(role[0].toUpperCase() + role.substring(1)),
              leading: Radio<String>(
                value: role,
                groupValue: user.role,
                onChanged: (value) {
                  Navigator.pop(context);
                  _changerRole(user, value!);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: Scaffold(
        appBar: const BarrePrincipale(titre: "Gérer les Utilisateurs"),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: _utilisateurs.map((user) {
                        final actif = user.actif;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(
                              actif ? Icons.person : Icons.person_off,
                              color: actif ? Colors.green : Colors.red,
                            ),
                            title: Text('${user.prenom} ${user.nom}'),
                            subtitle: Text(
                              "${user.email} | Rôle: ${user.role ?? 'utilisateur'}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _showChangerRoleDialog(user),
                                  tooltip: "Changer rôle",
                                ),
                                actif
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.lock,
                                          color: Colors.orange,
                                        ),
                                        onPressed: () =>
                                            _changerEtat(user, false),
                                        tooltip: "Bloquer",
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                          Icons.lock_open,
                                          color: Colors.green,
                                        ),
                                        onPressed: () =>
                                            _changerEtat(user, true),
                                        tooltip: "Débloquer",
                                      ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
