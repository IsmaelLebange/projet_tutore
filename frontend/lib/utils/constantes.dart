import 'package:flutter/material.dart';

// 🎨 Palette de couleurs moderne et fluide
const Color couleurPrincipale = Color(0xFF6C63FF); // Violet moderne
const Color couleurSecondaire = Color(0xFF00D9FF); // Cyan vibrant
const Color couleurAccent = Color(0xFFFF6584); // Rose accent
const Color couleurFond = Color(0xFFF8F9FE); // Fond très clair
const Color couleurCarte = Color(0xFFFFFFFF); // Blanc pur pour les cartes
const Color couleurTexte = Color(0xFF2D3142); // Texte sombre
const Color couleurTexteSecondaire = Color(0xFF9B9FB4); // Texte secondaire
const Color couleurSucces = Color(0xFF4CAF50); // Vert succès
const Color couleurErreur = Color(0xFFFF5252); // Rouge erreur
const Color couleurWarning = Color(0xFFFFA726); // Orange warning

// 🌐 Configuration API
const String apiBaseUrl = "http://localhost:3000/api";

// 📐 Espacements et dimensions
const double espacementXS = 4.0;
const double espacementS = 8.0;
const double espacementM = 16.0;
const double espacementL = 24.0;
const double espacementXL = 32.0;
const double espacementXXL = 48.0;

const double rayonBordure = 16.0;
const double rayonBordureS = 8.0;
const double rayonBordureL = 24.0;

// 🔤 Tailles de texte
const double tailleTexteTitre = 28.0;
const double tailleTexteSousTitre = 20.0;
const double tailleTexteCorps = 16.0;
const double tailleTexteCaption = 14.0;
const double tailleTexteSmall = 12.0;

// 🎭 Ombres et élévations
const List<BoxShadow> ombreLegere = [
  BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 10,
    offset: Offset(0, 2),
  ),
];

const List<BoxShadow> ombreMoyenne = [
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 20,
    offset: Offset(0, 4),
  ),
];

const List<BoxShadow> ombreForte = [
  BoxShadow(
    color: Color(0x26000000),
    blurRadius: 30,
    offset: Offset(0, 8),
  ),
];

// 🎨 Gradients
const LinearGradient gradientPrincipal = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [couleurPrincipale, couleurSecondaire],
);

const LinearGradient gradientAccent = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [couleurAccent, Color(0xFFFF8FA3)],
);

const LinearGradient gradientSucces = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
);

// ⏱️ Durées d'animation
const Duration dureeAnimationCourte = Duration(milliseconds: 200);
const Duration dureeAnimationMoyenne = Duration(milliseconds: 300);
const Duration dureeAnimationLongue = Duration(milliseconds: 500);
