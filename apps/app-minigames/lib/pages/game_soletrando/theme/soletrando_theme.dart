// Flutter imports:
import 'package:flutter/material.dart';

/// Tema visual customizado para o jogo Soletrando
/// Implementa design responsivo e hierarquia visual clara
class SoletrandoTheme {
  // Cores principais
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Violet
  static const Color accentColor = Color(0xFFF59E0B); // Amber
  static const Color successColor = Color(0xFF10B981); // Emerald
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color warningColor = Color(0xFFF59E0B); // Amber

  // Cores de fundo
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color cardColor = Color(0xFFF1F5F9); // Slate 100

  // Cores de texto
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successColor, Color(0xFF059669)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorColor, Color(0xFFDC2626)],
  );

  // Espaçamentos responsivos
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return baseSpacing * 1.5;
    if (screenWidth > 800) return baseSpacing * 1.25;
    if (screenWidth < 400) return baseSpacing * 0.8;
    return baseSpacing;
  }

  // Tamanhos de fonte responsivos
  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return baseFontSize * 1.2;
    if (screenWidth > 800) return baseFontSize * 1.1;
    if (screenWidth < 400) return baseFontSize * 0.9;
    return baseFontSize;
  }

  // Estilos de texto
  static TextStyle titleLarge(BuildContext context) => TextStyle(
        fontSize: getResponsiveFontSize(context, 32),
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
        fontSize: getResponsiveFontSize(context, 24),
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle titleSmall(BuildContext context) => TextStyle(
        fontSize: getResponsiveFontSize(context, 20),
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: getResponsiveFontSize(context, 18),
        fontWeight: FontWeight.normal,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontSize: getResponsiveFontSize(context, 16),
        fontWeight: FontWeight.normal,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: getResponsiveFontSize(context, 14),
        fontWeight: FontWeight.normal,
        color: textTertiary,
        height: 1.5,
      );

  static TextStyle letterStyle(BuildContext context) => TextStyle(
        fontSize: getResponsiveFontSize(context, 24),
        fontWeight: FontWeight.bold,
        color: textPrimary,
        fontFamily: 'monospace',
      );

  // Decorações de container
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration letterButtonDecoration(Color color) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // Animações
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  static const Curve animationCurve = Curves.easeInOut;
  static const Curve fastAnimationCurve = Curves.easeOut;
  static const Curve slowAnimationCurve = Curves.ease;

  // Bordas
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;

  // Espaçamentos
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // Tamanhos de botões
  static double getButtonHeight(BuildContext context) {
    return getResponsiveSpacing(context, 56);
  }

  static double getLetterButtonSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 64;
    if (screenWidth > 800) return 56;
    if (screenWidth < 400) return 48;
    return 52;
  }

  // Largura máxima do conteúdo
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 1020;
    if (screenWidth > 800) return screenWidth * 0.9;
    return screenWidth - (spacingMedium * 2);
  }

  // Theme data completo
  static ThemeData get themeData => ThemeData(
        primaryColor: primaryColor,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          surface: surfaceColor,
          error: errorColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        cardColor: cardColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(120, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadiusMedium),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            minimumSize: const Size(80, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadiusSmall),
            ),
          ),
        ),
        // cardTheme: CardTheme(
        //   color: surfaceColor,
        //   elevation: 4,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(borderRadiusLarge),
        //   ),
        // ),
        useMaterial3: true,
      );
}

/// Widget helper para aplicar tema responsivo
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool centerContent;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: SoletrandoTheme.getMaxContentWidth(context),
        padding: padding ??
            EdgeInsets.all(
              SoletrandoTheme.getResponsiveSpacing(
                  context, SoletrandoTheme.spacingMedium),
            ),
        child: centerContent ? Center(child: child) : child,
      ),
    );
  }
}

/// Widget para espaçamento responsivo
class ResponsiveSpacing extends StatelessWidget {
  final double spacing;
  final bool horizontal;

  const ResponsiveSpacing({
    super.key,
    required this.spacing,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing =
        SoletrandoTheme.getResponsiveSpacing(context, spacing);
    return SizedBox(
      width: horizontal ? responsiveSpacing : null,
      height: horizontal ? null : responsiveSpacing,
    );
  }
}
