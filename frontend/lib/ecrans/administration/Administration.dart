// ...existing code...
import 'package:flutter/material.dart';
import '../../composants/BarrePrincipale.dart';
import '../../composants/AdminGate.dart';

class Administration extends StatefulWidget {
  const Administration({super.key});

  @override
  State<Administration> createState() => _AdministrationState();
}

class _AdministrationState extends State<Administration> {
  final List<Map<String, dynamic>> _adminModules = const [
    {
      'titre': "Gérer les Annonces",
      'sousTitre': "Valider, modifier ou supprimer toutes les annonces.",
      'icone': Icons.receipt_long,
      'route': '/admin/annonces',
    },
    {
      'titre': "Gérer les Utilisateurs",
      'sousTitre': "Bloquer, modifier les rôles ou voir les profils.",
      'icone': Icons.people,
      'route': '/admin/utilisateurs',
    },
    {
      'titre': "Statistiques et Rapports",
      'sousTitre': "Voir les métriques clés de la plateforme.",
      'icone': Icons.analytics,
      'route': '/admin/stats',
    },
    {
      'titre': "Modération des Litiges",
      'sousTitre': "Traiter les plaintes et les conflits entre utilisateurs.",
      'icone': Icons.gavel,
      'route': '/admin/litiges',
    },
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _adminModules
        .where((m) =>
            m['titre'].toString().toLowerCase().contains(_query.toLowerCase()) ||
            m['sousTitre'].toString().toLowerCase().contains(_query.toLowerCase()))
        .toList();
        WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Page Administration chargée - Vérification AdminGate en cours...')),
    );
  });

    return AdminGate(
      child: Scaffold(
        appBar: BarrePrincipale(titre: "Tableau de Bord Admin"),
        drawer: MenuPrincipal(),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Ligne de recherche / actions
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Rechercher un module...',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => setState(() => _query = v.trim()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/admin/create'),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Nouvel admin'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      // affichage grid si assez large
                      if (constraints.maxWidth >= 700) {
                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 3.4,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final module = filtered[index];
                            return _buildModuleCard(context, module);
                          },
                        );
                      }
                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final module = filtered[index];
                          return _buildModuleCard(context, module);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/admin/create'),
          icon: const Icon(Icons.person_add),
          label: const Text('Ajouter admin'),
        ),
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, Map<String, dynamic> module) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Icon(module['icone'], color: Theme.of(context).colorScheme.primary, size: 30),
        title: Text(module['titre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(module['sousTitre']),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, module['route']),
      ),
    );
  }
}
// ...existing code...