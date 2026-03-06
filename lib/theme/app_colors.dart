import 'package:flutter/material.dart';

ThemeData AppColors = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(

    // Background général app
    surface: Color(0xFFF4F7FB),

    // Couleur principale (boutons / appbar)
    primary: Color(0xFF2E86DE),

    // Accent secondaire
    secondary: Color(0xFF54A0FF),

    // Accent capsules / validation
    tertiary: Color(0xFF10AC84),

    // Surfaces inversées (cards foncées)
    inverseSurface: Color(0xFF1E272E),

    // Texte sur primary
    inversePrimary: Color(0xFFFFFFFF),

    // Champs / containers / cards
    secondaryContainer: Color(0xFFD6E9FF),
  ),
);