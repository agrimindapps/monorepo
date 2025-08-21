import 'package:flutter/material.dart';

/// Cores específicas do Plantis (foco em plantas e natureza)
class PlantisColors {
  // Primary colors (teal/turquoise theme for nature/plants)
  static const Color primary = Color(0xFF20B2AA); // Turquoise
  static const Color primaryLight = Color(0xFF52E4DC); // Light turquoise
  static const Color primaryDark = Color(0xFF00827A); // Dark turquoise

  // Secondary colors
  static const Color secondary = Color(0xFF98D8C8); // Mint green
  static const Color secondaryLight = Color(0xFFC9FFF9); // Very light mint
  static const Color secondaryDark = Color(0xFF69A697); // Dark mint

  // Tertiary/Nature colors
  static const Color accent = Color(0xFF4CAF50); // Natural green
  static const Color accentLight = Color(0xFFC8E6C9); // Light green
  static const Color accentDark = Color(0xFF2E7D32); // Dark green

  // Plant-themed colors
  static const Color leaf = Color(0xFF4CAF50); // Leaf green
  static const Color leafLight = Color(0xFFE8F5E8); // Light leaf
  static const Color leafDark = Color(0xFF1B5E20); // Dark leaf

  static const Color flower = Color(0xFFE91E63); // Flower pink
  static const Color flowerLight = Color(0xFFF8BBD9); // Light pink
  static const Color flowerDark = Color(0xFFAD1457); // Dark pink

  static const Color soil = Color(0xFF8D6E63); // Soil brown
  static const Color soilLight = Color(0xFFD7CCC8); // Light soil
  static const Color soilDark = Color(0xFF5D4037); // Dark soil

  static const Color water = Color(0xFF03A9F4); // Water blue
  static const Color waterLight = Color(0xFFB3E5FC); // Light water
  static const Color waterDark = Color(0xFF0277BD); // Dark water

  static const Color sun = Color(0xFFFFC107); // Sun yellow
  static const Color sunLight = Color(0xFFFFF9C4); // Light sun
  static const Color sunDark = Color(0xFFE65100); // Dark sun

  // Brand gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient leafGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [leaf, leafLight],
  );

  static const LinearGradient flowerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [flower, flowerLight],
  );

  // Helper methods
  static Color getPrimaryShade(int shade) {
    switch (shade) {
      case 50:
        return const Color(0xFFE0F2F1);
      case 100:
        return const Color(0xFFB2DFDB);
      case 200:
        return const Color(0xFF80CBC4);
      case 300:
        return const Color(0xFF4DB6AC);
      case 400:
        return const Color(0xFF26A69A);
      case 500:
        return primary;
      case 600:
        return const Color(0xFF00695C);
      case 700:
        return const Color(0xFF004D40);
      case 800:
        return primaryDark;
      case 900:
        return const Color(0xFF00251A);
      default:
        return primary;
    }
  }

  static Color getSecondaryShade(int shade) {
    switch (shade) {
      case 50:
        return const Color(0xFFE8F5F3);
      case 100:
        return const Color(0xFFC5E5E1);
      case 200:
        return const Color(0xFF9FD4CE);
      case 300:
        return const Color(0xFF79C3BA);
      case 400:
        return const Color(0xFF5CB5AB);
      case 500:
        return secondary;
      case 600:
        return const Color(0xFF7FA99C);
      case 700:
        return const Color(0xFF6F9C8F);
      case 800:
        return secondaryDark;
      case 900:
        return const Color(0xFF4A6B62);
      default:
        return secondary;
    }
  }
}
