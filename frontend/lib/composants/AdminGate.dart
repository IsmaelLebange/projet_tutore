// ...existing code...
import 'package:flutter/material.dart';
import 'package:frontend/services/authService.dart';
import '../services/administration/adminService.dart';

class AdminGate extends StatelessWidget {
  final Widget child;
  final AdminService? adminService;

  const AdminGate({super.key, required this.child, this.adminService});

  @override
  Widget build(BuildContext context) {
    final svc = adminService ?? AdminService();
    return FutureBuilder<bool>(
      future: _isAdmin(svc),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) return child;
        return Scaffold(
          appBar: AppBar(title: const Text('Accès Refusé')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.security_update_warning,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Accès Interdit',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Seuls les administrateurs sont autorisés à consulter cette page.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/connexion'),
                  icon: const Icon(Icons.login),
                  label: const Text('Retour à la Connexion'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Dans AdminGate.dart
Future<bool> _isAdmin(AdminService svc) async {
  try {
    final authService = AuthService();
    final role = await authService.getUserRole();
    return role == 'admin'; // ✅ Vérifie le rôle stocké localement
    try {
      return await svc.isAdmin(); // Appel API
    } catch (e) {
      // Si API échoue, on trust le cache local
      print('⚠️ API admin/check inaccessible, utilisation cache local');
      return true;
    }
  } catch (e) {
    return false;
  }
}
