import 'package:flutter/material.dart';

/// Design tokens específicos para componentes de loading
/// Centraliza configurações visuais para garantir consistência
class LoadingDesignTokens {
  LoadingDesignTokens._();

  // ========== CORES ==========
  static const Color primaryLoadingColor = Color(0xFF2196F3);
  static const Color secondaryLoadingColor = Color(0xFF64B5F6);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color onSurfaceColor = Color(0xFF424242);
  static const Color onSurfaceLightColor = Color(0xFF757575);

  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkOnSurfaceColor = Color(0xFFE0E0E0);
  static const Color darkOnSurfaceLightColor = Color(0xFFB0B0B0);

  // ========== DIMENSÕES ==========
  static const double loadingIndicatorSize = 24.0;
  static const double loadingIndicatorStrokeWidth = 3.0;
  static const double iconSize = 32.0;
  static const double largeIconSize = 48.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border radius
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 16.0;

  // ========== ANIMAÇÕES ==========
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 400);
  static const Duration slowDuration = Duration(milliseconds: 800);
  static const Duration verySlowDuration = Duration(milliseconds: 1200);

  // Curves
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;
  static const Curve bounceCurve = Curves.elasticOut;

  // ========== TIPOGRAFIA ==========
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle captionTextStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  // ========== ETAPAS DE LOADING ==========
  static const List<LoadingStepConfig> loginSteps = [
    LoadingStepConfig(
      icon: Icons.account_circle_outlined,
      title: 'Autenticando',
      subtitle: 'Verificando suas credenciais...',
      duration: Duration(milliseconds: 1000),
    ),
    LoadingStepConfig(
      icon: Icons.cloud_download_outlined,
      title: 'Sincronizando',
      subtitle: 'Baixando seus dados...',
      duration: Duration(milliseconds: 1500),
    ),
    LoadingStepConfig(
      icon: Icons.directions_car_outlined,
      title: 'Carregando veículos',
      subtitle: 'Preparando sua frota...',
      duration: Duration(milliseconds: 1200),
    ),
    LoadingStepConfig(
      icon: Icons.local_gas_station_outlined,
      title: 'Processando dados',
      subtitle: 'Analisando consumo...',
      duration: Duration(milliseconds: 800),
    ),
    LoadingStepConfig(
      icon: Icons.check_circle_outline,
      title: 'Pronto!',
      subtitle: 'Redirecionando...',
      duration: Duration(milliseconds: 600),
    ),
  ];

  // ========== SKELETON DIMENSIONS ==========
  static const double skeletonHeight = 16.0;
  static const double skeletonHeightSm = 12.0;
  static const double skeletonHeightLg = 20.0;
  static const double skeletonCardHeight = 120.0;
  static const double skeletonAvatarSize = 40.0;

  // ========== MÉTODOS UTILITÁRIOS ==========
  
  /// Retorna cores apropriadas para o tema atual
  static LoadingColorScheme getColorScheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return LoadingColorScheme(
      primary: primaryLoadingColor,
      secondary: secondaryLoadingColor,
      success: successColor,
      background: isDark ? darkBackgroundColor : backgroundColor,
      surface: isDark ? darkSurfaceColor : surfaceColor,
      onSurface: isDark ? darkOnSurfaceColor : onSurfaceColor,
      onSurfaceLight: isDark ? darkOnSurfaceLightColor : onSurfaceLightColor,
    );
  }

  /// Retorna configuração de animação baseada no contexto
  static AnimationConfig getAnimationConfig(AnimationSpeed speed) {
    switch (speed) {
      case AnimationSpeed.fast:
        return const AnimationConfig(
          duration: fastDuration,
          curve: enterCurve,
        );
      case AnimationSpeed.normal:
        return const AnimationConfig(
          duration: normalDuration,
          curve: standardCurve,
        );
      case AnimationSpeed.slow:
        return const AnimationConfig(
          duration: slowDuration,
          curve: exitCurve,
        );
      case AnimationSpeed.bounce:
        return const AnimationConfig(
          duration: normalDuration,
          curve: bounceCurve,
        );
    }
  }
}

// ========== CLASSES DE CONFIGURAÇÃO ==========

/// Configuração de uma etapa de loading
class LoadingStepConfig {

  const LoadingStepConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.duration,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Duration duration;
}

/// Schema de cores para loading
class LoadingColorScheme {

  const LoadingColorScheme({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceLight,
  });
  final Color primary;
  final Color secondary;
  final Color success;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceLight;
}

/// Configuração de animação
class AnimationConfig {

  const AnimationConfig({
    required this.duration,
    required this.curve,
  });
  final Duration duration;
  final Curve curve;
}

/// Velocidades de animação disponíveis
enum AnimationSpeed {
  fast,
  normal,
  slow,
  bounce,
}