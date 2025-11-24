import 'package:flutter/material.dart';
import '../utils/constantes.dart';

/// Bouton principal avec gradient
class BoutonPrincipal extends StatelessWidget {
  final String texte;
  final VoidCallback onPressed;
  final bool chargement;
  final IconData? icone;
  final bool pleineLargeur;

  const BoutonPrincipal({
    Key? key,
    required this.texte,
    required this.onPressed,
    this.chargement = false,
    this.icone,
    this.pleineLargeur = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: pleineLargeur ? double.infinity : null,
      height: 56,
      decoration: BoxDecoration(
        gradient: gradientPrincipal,
        borderRadius: BorderRadius.circular(rayonBordure),
        boxShadow: ombreMoyenne,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: chargement ? null : onPressed,
          borderRadius: BorderRadius.circular(rayonBordure),
          child: Center(
            child: chargement
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icone != null) ...[
                        Icon(icone, color: Colors.white),
                        const SizedBox(width: espacementS),
                      ],
                      Text(
                        texte,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: tailleTexteCorps,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Bouton secondaire avec contour
class BoutonSecondaire extends StatelessWidget {
  final String texte;
  final VoidCallback onPressed;
  final IconData? icone;

  const BoutonSecondaire({
    Key? key,
    required this.texte,
    required this.onPressed,
    this.icone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(rayonBordure),
        border: Border.all(color: couleurPrincipale, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(rayonBordure),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icone != null) ...[
                  Icon(icone, color: couleurPrincipale),
                  const SizedBox(width: espacementS),
                ],
                Text(
                  texte,
                  style: const TextStyle(
                    color: couleurPrincipale,
                    fontSize: tailleTexteCorps,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte moderne avec animation
class CarteModerne extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const CarteModerne({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  State<CarteModerne> createState() => _CarteModerneState();
}

class _CarteModerneState extends State<CarteModerne>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: dureeAnimationCourte,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(espacementM),
          decoration: BoxDecoration(
            color: couleurCarte,
            borderRadius: BorderRadius.circular(rayonBordure),
            boxShadow: ombreLegere,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Badge de statut coloré
class BadgeStatut extends StatelessWidget {
  final String texte;
  final Color couleur;

  const BadgeStatut({
    Key? key,
    required this.texte,
    required this.couleur,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: espacementS,
        vertical: espacementXS,
      ),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(rayonBordureS),
        border: Border.all(color: couleur.withOpacity(0.3)),
      ),
      child: Text(
        texte,
        style: TextStyle(
          color: couleur,
          fontSize: tailleTexteSmall,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Champ de recherche moderne
class ChampRecherche extends StatelessWidget {
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const ChampRecherche({
    Key? key,
    required this.placeholder,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: couleurCarte,
        borderRadius: BorderRadius.circular(rayonBordure),
        boxShadow: ombreLegere,
      ),
      child: TextField(
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: placeholder,
          prefixIcon: const Icon(Icons.search, color: couleurTexteSecondaire),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: espacementM,
            vertical: espacementM,
          ),
        ),
      ),
    );
  }
}

/// Indicateur de chargement élégant
class ChargementElegant extends StatelessWidget {
  final String? message;

  const ChargementElegant({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(espacementL),
            decoration: BoxDecoration(
              color: couleurCarte,
              borderRadius: BorderRadius.circular(rayonBordure),
              boxShadow: ombreMoyenne,
            ),
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox(height: espacementM),
            Text(
              message!,
              style: const TextStyle(
                color: couleurTexteSecondaire,
                fontSize: tailleTexteCaption,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Message d'erreur stylisé
class MessageErreur extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const MessageErreur({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CarteModerne(
        padding: const EdgeInsets.all(espacementL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: couleurErreur,
            ),
            const SizedBox(height: espacementM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: tailleTexteCorps,
                color: couleurTexte,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: espacementM),
              BoutonSecondaire(
                texte: 'Réessayer',
                onPressed: onRetry!,
                icone: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// État vide stylisé
class EtatVide extends StatelessWidget {
  final String titre;
  final String message;
  final IconData icone;
  final VoidCallback? onAction;
  final String? texteAction;

  const EtatVide({
    Key? key,
    required this.titre,
    required this.message,
    required this.icone,
    this.onAction,
    this.texteAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(espacementXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(espacementXL),
              decoration: BoxDecoration(
                color: couleurPrincipale.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icone,
                size: 80,
                color: couleurPrincipale,
              ),
            ),
            const SizedBox(height: espacementL),
            Text(
              titre,
              style: const TextStyle(
                fontSize: tailleTexteSousTitre,
                fontWeight: FontWeight.bold,
                color: couleurTexte,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: espacementS),
            Text(
              message,
              style: const TextStyle(
                fontSize: tailleTexteCorps,
                color: couleurTexteSecondaire,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && texteAction != null) ...[
              const SizedBox(height: espacementL),
              BoutonPrincipal(
                texte: texteAction!,
                onPressed: onAction!,
                pleineLargeur: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Barre de navigation partagée
class BarreNavigationPrincipale extends StatelessWidget {
  const BarreNavigationPrincipale({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(Icons.home, 'Accueil', () => Navigator.of(context).pushNamed('/')),
      _NavItemData(Icons.devices, 'Électronique', () => Navigator.of(context).pushNamed('/catalogueProduits')),
      _NavItemData(Icons.checkroom, 'Mode', () => Navigator.of(context).pushNamed('/categorie/mode')),
      _NavItemData(Icons.home_outlined, 'Maison', () => Navigator.of(context).pushNamed('/categorie/maison')),
      _NavItemData(Icons.sports_soccer, 'Sports', () => Navigator.of(context).pushNamed('/categorie/sports')),
      _NavItemData(Icons.toys, 'Jouets', () => Navigator.of(context).pushNamed('/categorie/jouets')),
      _NavItemData(Icons.build, 'Services', () => Navigator.of(context).pushNamed('/catalogueServices')),
    ];

    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF000080),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: espacementM),
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) => _NavLink(item: item)).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final _NavItemData item;

  const _NavLink({Key? key, required this.item}) : super(key: key);

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedContainer(
          duration: dureeAnimationMoyenne,
          padding: const EdgeInsets.symmetric(horizontal: espacementM, vertical: espacementS),
          margin: const EdgeInsets.symmetric(horizontal: espacementXS),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(rayonBordureS),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, color: Colors.white, size: 18),
              const SizedBox(width: espacementXS),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: _hovered ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _NavItemData(this.icon, this.label, this.onTap);
}
