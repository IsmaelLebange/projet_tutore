import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes.dart';
import 'utils/constantes.dart';
import 'ecrans/AccueilEcommerce.dart';

void main() {
  // Configuration du style de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(MonApp());
}

class MonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusyKin - Marketplace',
      debugShowCheckedModeBanner: false,
      
      // 🎨 Thème moderne et fluide
      theme: ThemeData(
        // Couleurs principales
        primaryColor: couleurPrincipale,
        scaffoldBackgroundColor: couleurFond,
        colorScheme: ColorScheme.fromSeed(
          seedColor: couleurPrincipale,
          secondary: couleurSecondaire,
          brightness: Brightness.light,
        ),
        
        // Police moderne
        fontFamily: 'Segoe UI',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: tailleTexteTitre,
            fontWeight: FontWeight.bold,
            color: couleurTexte,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: tailleTexteSousTitre,
            fontWeight: FontWeight.w600,
            color: couleurTexte,
          ),
          bodyLarge: TextStyle(
            fontSize: tailleTexteCorps,
            color: couleurTexte,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: tailleTexteCaption,
            color: couleurTexteSecondaire,
          ),
        ),
        
        // Boutons avec style moderne
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: couleurPrincipale,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: espacementL,
              vertical: espacementM,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rayonBordure),
            ),
            textStyle: const TextStyle(
              fontSize: tailleTexteCorps,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Cartes avec ombre douce
        cardTheme: CardThemeData(
          color: couleurCarte,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rayonBordure),
          ),
          margin: const EdgeInsets.all(espacementS),
        ),
        
        // Champs de texte modernes
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: couleurCarte,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: espacementM,
            vertical: espacementM,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rayonBordure),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rayonBordure),
            borderSide: BorderSide(color: couleurTexteSecondaire.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rayonBordure),
            borderSide: const BorderSide(color: couleurPrincipale, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rayonBordure),
            borderSide: const BorderSide(color: couleurErreur),
          ),
          hintStyle: TextStyle(color: couleurTexteSecondaire),
        ),
        
        // AppBar moderne
        appBarTheme: const AppBarTheme(
          backgroundColor: couleurCarte,
          foregroundColor: couleurTexte,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: couleurTexte,
            fontSize: tailleTexteSousTitre,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: couleurTexte),
        ),
        
        // Bottom Navigation Bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: couleurCarte,
          selectedItemColor: couleurPrincipale,
          unselectedItemColor: couleurTexteSecondaire,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
        
        // Indicateur de progression
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: couleurPrincipale,
        ),
        
        // Animations fluides
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      
      initialRoute: '/',
      routes: AppRoutes.getRoutes(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
