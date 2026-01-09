import 'package:flutter/material.dart';

/// Cores específicas do MiniGames (tema vibrante para jogos)
class MinigamesColors {
  MinigamesColors._();

  // ============================================================================
  // Cores Primárias - Roxo vibrante
  // ============================================================================
  static const Color primary = Color(0xFF7C4DFF);        // Deep Purple A200
  static const Color primaryLight = Color(0xFFB388FF);   // Deep Purple A100
  static const Color primaryDark = Color(0xFF651FFF);    // Deep Purple A400
  
  // ============================================================================
  // Cores Secundárias - Cyan energético
  // ============================================================================
  static const Color secondary = Color(0xFF00E5FF);      // Cyan A200
  static const Color secondaryLight = Color(0xFF84FFFF); // Cyan A100
  static const Color secondaryDark = Color(0xFF00B8D4);  // Cyan A700
  
  // ============================================================================
  // Cores de Destaque - Amarelo/Dourado
  // ============================================================================
  static const Color accent = Color(0xFFFFD740);         // Amber A200
  static const Color accentLight = Color(0xFFFFE57F);    // Amber A100
  static const Color accentDark = Color(0xFFFFC400);     // Amber A400
  
  // ============================================================================
  // Cores de Estado (Jogos)
  // ============================================================================
  static const Color success = Color(0xFF00E676);        // Green A400 - Vitória/Correto
  static const Color successLight = Color(0xFF69F0AE);   // Green A200
  static const Color warning = Color(0xFFFFAB00);        // Amber A700 - Atenção
  static const Color warningLight = Color(0xFFFFD740);   // Amber A200
  static const Color error = Color(0xFFFF5252);          // Red A200 - Erro/Derrota
  static const Color errorLight = Color(0xFFFF8A80);     // Red A100
  static const Color info = Color(0xFF40C4FF);           // Light Blue A200 - Info
  static const Color infoLight = Color(0xFF80D8FF);      // Light Blue A100

  // ============================================================================
  // Cores de Background
  // ============================================================================
  static const Color backgroundLight = Color(0xFFF8F5FF);  // Lavender muito claro
  static const Color backgroundDark = Color(0xFF1A1A2E);   // Dark purple-navy
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF16213E);      // Dark blue-purple

  // ============================================================================
  // Gradientes para Jogos
  // ============================================================================
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

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successLight],
  );

  static const LinearGradient gameBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF7C4DFF),
      Color(0xFF536DFE),
      Color(0xFF448AFF),
    ],
  );

  static const LinearGradient darkGameBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
      Color(0xFF0F3460),
    ],
  );

  // ============================================================================
  // Cores para Elementos de Jogo
  // ============================================================================
  static const List<Color> gameColors = [
    Color(0xFFFF5252), // Red
    Color(0xFF7C4DFF), // Purple
    Color(0xFF00E5FF), // Cyan
    Color(0xFFFFD740), // Amber
    Color(0xFF00E676), // Green
    Color(0xFFFF4081), // Pink
    Color(0xFF536DFE), // Indigo
    Color(0xFFFF6E40), // Deep Orange
  ];

  /// Obtém cor de jogo por índice (com loop)
  static Color getGameColor(int index) {
    return gameColors[index % gameColors.length];
  }

  /// Cor de fundo padrão das páginas
  static Color getPageBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  /// Cor de superfície baseada no tema
  static Color getSurfaceColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }
}
