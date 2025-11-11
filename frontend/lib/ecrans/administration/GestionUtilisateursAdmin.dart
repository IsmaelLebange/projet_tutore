import 'package:flutter/material.dart';
import '../../composants/BarreRetour.dart';
import '../../composants/AdminGate.dart';
import '../../services/administration/gestionUtilisateurService.dart';
import '../../models/Utilisateur.dart';

class GestionUtilisateursAdmin extends StatefulWidget {
  const GestionUtilisateursAdmin({super.key});

  @override
  State<GestionUtilisateursAdmin> createState() =>
      _GestionUtilisateursAdminState();
}

class _GestionUtilisateursAdminState extends State<GestionUtilisateursAdmin> {
  final GestionUtilisateurService _service = GestionUtilisateurService();
  List<Utilisateur> _utilisateurs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerUtilisateurs();
  }

  Future<void> _chargerUtilisateurs() async {
    setState(() => _loading = true);
    try {
      final users = await _service.getUtilisateurs();
      setState(() {
        _utilisateurs = users;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _loading = false);
    }
  }

  Future<void> _changerEtat(Utilisateur user, bool actif) async {
    try {
      await _service.changerEtatUtilisateur(
        user.id!,
        actif ? 'Actif' : 'Bloqué',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.prenom} ${actif ? 'débloqué' : 'bloqué'}')),
        );
      }
      _chargerUtilisateurs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'))
        );
      }
    }
  }

  Future<void> _changerRole(Utilisateur user, String nouveauRole) async {
    try {
      await _service.changerRoleUtilisateur(user.id!, nouveauRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rôle changé en $nouveauRole'))
        );
      }
      _chargerUtilisateurs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'))
        );
      }
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

  // ✅ Helper : construit l'URL avatar (photo backend OU UI-Avatars fallback)
  String _getAvatarUrl(Utilisateur user) {
    if (user.photoProfil != null && user.photoProfil!.isNotEmpty) {
      // Si commence par http => déjà absolue
      if (user.photoProfil!.startsWith('http')) {
        return user.photoProfil!;
      }
      // Sinon ajoute prefix backend
      return 'http://localhost:3000${user.photoProfil!.startsWith('/') ? '' : '/'}${user.photoProfil}';
    }
    
    // ✅ Fallback : génère avatar via UI-Avatars (pas de 404 possible)
    final seed = '${user.prenom} ${user.nom}'.trim();
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(seed)}&background=0D8ABC&color=fff&size=128';
  }

  @override
  Widget build(BuildContext context) {
    return AdminGate(
      child: Scaffold(
        appBar: const BarreRetour(titre: 'Gérer les utilisateurs'),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _utilisateurs.isEmpty
                ? const Center(child: Text('Aucun utilisateur trouvé'))
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: _utilisateurs.map((user) {
                            final estActif = user.etat == 'Actif';
                            final avatarUrl = _getAvatarUrl(user);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                // ✅ Avatar avec image réseau (backend OU UI-Avatars)
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey[300],
                                  child: ClipOval(
                                    child: Image.network(
                                      avatarUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              value: progress.expectedTotalBytes != null
                                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        // ✅ Si erreur (404), affiche initiales
                                        return Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: estActif ? Colors.green[100] : Colors.red[100],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${user.prenom.isNotEmpty ? user.prenom[0] : '?'}${user.nom.isNotEmpty ? user.nom[0] : ''}'.toUpperCase(),
                                              style: TextStyle(
                                                color: estActif ? Colors.green[900] : Colors.red[900],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${user.prenom} ${user.nom}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(user.email),
                                    if (user.telephone != null) Text(user.telephone!),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: estActif
                                                ? Colors.green.withOpacity(0.2)
                                                : Colors.red.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            user.etat,
                                            style: TextStyle(
                                              color: estActif ? Colors.green : Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: user.role == 'admin'
                                                ? Colors.orange.withOpacity(0.2)
                                                : Colors.blue.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            user.role ?? 'utilisateur',
                                            style: TextStyle(
                                              color: user.role == 'admin' ? Colors.orange : Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                                      onPressed: () => _showChangerRoleDialog(user),
                                      tooltip: "Changer rôle",
                                    ),
                                    estActif
                                        ? IconButton(
                                            icon: const Icon(Icons.lock, color: Colors.orange),
                                            onPressed: () => _changerEtat(user, false),
                                            tooltip: "Bloquer",
                                          )
                                        : IconButton(
                                            icon: const Icon(Icons.lock_open, color: Colors.green),
                                            onPressed: () => _changerEtat(user, true),
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