import 'package:flutter/material.dart';

class BarreRetour extends StatelessWidget implements PreferredSizeWidget {
  final String titre;
  final VoidCallback? onBack;

  const BarreRetour({
    super.key,
    required this.titre,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 4,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
            if (onBack != null) {
              onBack!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamed(context, '/accueil');
            }
        },
      ),
      title: Text(
        titre,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: const [
        // Conserve un espace/alignement cohérent (icône transparente)
        SizedBox(width: 48),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}