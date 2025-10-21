// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants_optimized.dart';
import 'package:app_minigames/services/accessibility_service.dart';

/// Tipos de tema disponíveis
enum ThemeType {
  light, // Tema claro
  dark, // Tema escuro
  auto, // Automático (segue sistema)
  highContrast, // Alto contraste
}

/// Estilos de carta disponíveis
enum CardStyle {
  modern, // Moderno com gradientes
  classic, // Clássico com cores sólidas
  minimal, // Minimalista
  playful, // Divertido com mais cores
}

/// Configurações de tema
class ThemeConfig {
  final ThemeType themeType;
  final CardStyle cardStyle;
  final double interfaceScale;
  final bool enableAnimations;
  final bool enableParticles;
  final bool enableGradients;
  final Color? customAccentColor;

  const ThemeConfig({
    this.themeType = ThemeType.auto,
    this.cardStyle = CardStyle.modern,
    this.interfaceScale = 1.0,
    this.enableAnimations = true,
    this.enableParticles = true,
    this.enableGradients = true,
    this.customAccentColor,
  });

  ThemeConfig copyWith({
    ThemeType? themeType,
    CardStyle? cardStyle,
    double? interfaceScale,
    bool? enableAnimations,
    bool? enableParticles,
    bool? enableGradients,
    Color? customAccentColor,
  }) {
    return ThemeConfig(
      themeType: themeType ?? this.themeType,
      cardStyle: cardStyle ?? this.cardStyle,
      interfaceScale: interfaceScale ?? this.interfaceScale,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableParticles: enableParticles ?? this.enableParticles,
      enableGradients: enableGradients ?? this.enableGradients,
      customAccentColor: customAccentColor ?? this.customAccentColor,
    );
  }
}

/// Paleta de cores para um tema
class ColorPalette {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color error;
  final Color warning;
  final Color success;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardBackground;
  final Color cardBorder;
  final Color shadow;

  const ColorPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.error,
    required this.warning,
    required this.success,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardBackground,
    required this.cardBorder,
    required this.shadow,
  });
}

/// Gerenciador de temas
class ThemeManager extends ChangeNotifier {
  /// Configuração atual
  ThemeConfig _config = const ThemeConfig();

  /// Serviço de acessibilidade
  AccessibilityService? _accessibilityService;

  /// Paletas de cores
  late Map<ThemeType, ColorPalette> _colorPalettes;

  /// Estilos de carta
  late Map<CardStyle, CardStyleConfig> _cardStyles;

  /// Construtor
  ThemeManager({AccessibilityService? accessibilityService}) {
    _accessibilityService = accessibilityService;
    _initializePalettes();
    _initializeCardStyles();
  }

  /// Inicializa paletas de cores
  void _initializePalettes() {
    _colorPalettes = {
      ThemeType.light: const ColorPalette(
        primary: GameColors.primary,
        secondary: GameColors.secondary,
        accent: GameColors.primary,
        background: Color(0xFFF8F9FA),
        surface: Colors.white,
        error: GameColors.error,
        warning: GameColors.warning,
        success: GameColors.success,
        textPrimary: Color(0xFF212529),
        textSecondary: Color(0xFF6C757D),
        cardBackground: Colors.white,
        cardBorder: Color(0xFFE9ECEF),
        shadow: Color(0x1A000000),
      ),
      ThemeType.dark: const ColorPalette(
        primary: Color(0xFF64B5F6),
        secondary: Color(0xFF81C784),
        accent: Color(0xFF64B5F6),
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
        error: Color(0xFFEF5350),
        warning: Color(0xFFFFB74D),
        success: Color(0xFF66BB6A),
        textPrimary: Color(0xFFE0E0E0),
        textSecondary: Color(0xFFBDBDBD),
        cardBackground: Color(0xFF2A2A2A),
        cardBorder: Color(0xFF404040),
        shadow: Color(0x33000000),
      ),
      ThemeType.highContrast: const ColorPalette(
        primary: Colors.white,
        secondary: Colors.yellow,
        accent: Colors.yellow,
        background: Colors.black,
        surface: Color(0xFF1A1A1A),
        error: Color(0xFFFF6B6B),
        warning: Color(0xFFFFD93D),
        success: Color(0xFF6BCF7F),
        textPrimary: Colors.white,
        textSecondary: Color(0xFFCCCCCC),
        cardBackground: Color(0xFF2D2D2D),
        cardBorder: Colors.white,
        shadow: Colors.transparent,
      ),
    };
  }

  /// Inicializa estilos de carta
  void _initializeCardStyles() {
    _cardStyles = {
      CardStyle.modern: const CardStyleConfig(
        borderRadius: 16.0,
        elevation: 4.0,
        borderWidth: 0.0,
        useGradient: true,
        animationDuration: GameAnimations.normalAnimation,
        shadowBlur: 8.0,
      ),
      CardStyle.classic: const CardStyleConfig(
        borderRadius: 8.0,
        elevation: 2.0,
        borderWidth: 1.0,
        useGradient: false,
        animationDuration: GameAnimations.normalAnimation,
        shadowBlur: 4.0,
      ),
      CardStyle.minimal: const CardStyleConfig(
        borderRadius: 4.0,
        elevation: 1.0,
        borderWidth: 0.5,
        useGradient: false,
        animationDuration: GameAnimations.fastAnimation,
        shadowBlur: 2.0,
      ),
      CardStyle.playful: const CardStyleConfig(
        borderRadius: 20.0,
        elevation: 6.0,
        borderWidth: 2.0,
        useGradient: true,
        animationDuration: GameAnimations.slowAnimation,
        shadowBlur: 12.0,
      ),
    };
  }

  /// Atualiza configuração
  void updateConfig(ThemeConfig config) {
    _config = config;
    notifyListeners();
  }

  /// Obtém configuração atual
  ThemeConfig get config => _config;

  /// Determina se deve usar tema escuro
  bool get shouldUseDarkTheme {
    switch (_config.themeType) {
      case ThemeType.light:
        return false;
      case ThemeType.dark:
        return true;
      case ThemeType.highContrast:
        return true;
      case ThemeType.auto:
        // Em uma implementação real, consultaria MediaQuery.platformBrightnessOf
        return false;
    }
  }

  /// Obtém paleta de cores atual
  ColorPalette get currentPalette {
    final themeType = _config.themeType == ThemeType.auto
        ? (shouldUseDarkTheme ? ThemeType.dark : ThemeType.light)
        : _config.themeType;

    return _colorPalettes[themeType] ?? _colorPalettes[ThemeType.light]!;
  }

  /// Obtém estilo de carta atual
  CardStyleConfig get currentCardStyle {
    return _cardStyles[_config.cardStyle] ?? _cardStyles[CardStyle.modern]!;
  }

  /// Constrói tema do Flutter
  ThemeData buildThemeData() {
    final palette = currentPalette;
    final isDark = shouldUseDarkTheme;

    // Aplica acessibilidade se disponível
    Color accent = _config.customAccentColor ?? palette.accent;
    if (_accessibilityService?.config.colorBlindness !=
        ColorBlindnessType.none) {
      accent = _accessibilityService!.adaptColorForColorBlindness(accent);
    }

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: palette.primary,
      scaffoldBackgroundColor: palette.background,
      cardColor: palette.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: isDark ? Brightness.dark : Brightness.light,
        background: palette.background,
        surface: palette.surface,
        error: palette.error,
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.textPrimary,
        elevation: 2,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),

      // Texto
      textTheme: TextTheme(
        headlineLarge: GameTypography.headline.copyWith(
          color: palette.textPrimary,
          fontSize: GameTypography.headlineSize * _config.interfaceScale,
        ),
        titleLarge: GameTypography.title.copyWith(
          color: palette.textPrimary,
          fontSize: GameTypography.titleSize * _config.interfaceScale,
        ),
        titleMedium: GameTypography.subtitle.copyWith(
          color: palette.textSecondary,
          fontSize: GameTypography.subtitleSize * _config.interfaceScale,
        ),
        bodyLarge: GameTypography.body.copyWith(
          color: palette.textPrimary,
          fontSize: GameTypography.bodySize * _config.interfaceScale,
        ),
        bodyMedium: GameTypography.caption.copyWith(
          color: palette.textSecondary,
          fontSize: GameTypography.captionSize * _config.interfaceScale,
        ),
      ),

      // Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: palette.surface,
          elevation: 2,
          padding: GameLayout.buttonPadding * _config.interfaceScale,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameLayout.buttonBorderRadius),
          ),
          textStyle: GameTypography.button.copyWith(
            fontSize: GameTypography.bodySize * _config.interfaceScale,
          ),
        ),
      ),

      // Cards
      // cardTheme: CardTheme(
      //   color: palette.cardBackground,
      //   elevation: currentCardStyle.elevation,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(currentCardStyle.borderRadius),
      //     side: currentCardStyle.borderWidth > 0
      //         ? BorderSide(
      //             color: palette.cardBorder,
      //             width: currentCardStyle.borderWidth)
      //         : BorderSide.none,
      //   ),
      //   shadowColor: palette.shadow,
      // ),

      // Diálogos
      // dialogTheme: DialogTheme(
      //   backgroundColor: palette.surface,
      //   elevation: 8,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(GameLayout.dialogBorderRadius),
      //   ),
      // ),

      // Ícones
      iconTheme: IconThemeData(
        color: palette.textSecondary,
        size: 24 * _config.interfaceScale,
      ),

      // Divisores
      dividerTheme: DividerThemeData(
        color: palette.cardBorder,
        thickness: 1,
      ),
    );
  }

  /// Constrói decoração para carta
  BoxDecoration buildCardDecoration({
    required Color color,
    bool isRevealed = false,
    bool isMatched = false,
    bool isSelected = false,
  }) {
    final palette = currentPalette;
    final cardStyle = currentCardStyle;

    Color cardColor = color;
    if (_accessibilityService?.config.colorBlindness !=
        ColorBlindnessType.none) {
      cardColor = _accessibilityService!.adaptColorForColorBlindness(color);
    }

    // Aplica modificadores de estado
    if (isMatched) {
      cardColor = cardColor.withValues(alpha: 0.7);
    } else if (isSelected) {
      cardColor = Color.lerp(cardColor, Colors.white, 0.2) ?? cardColor;
    }

    return BoxDecoration(
      color:
          cardStyle.useGradient && _config.enableGradients ? null : cardColor,
      gradient: cardStyle.useGradient && _config.enableGradients
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                cardColor.withValues(alpha: 0.8),
              ],
            )
          : null,
      borderRadius: BorderRadius.circular(cardStyle.borderRadius),
      border: cardStyle.borderWidth > 0
          ? Border.all(color: palette.cardBorder, width: cardStyle.borderWidth)
          : null,
      boxShadow: [
        BoxShadow(
          color: palette.shadow,
          blurRadius: cardStyle.shadowBlur,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Obtém duração de animação
  Duration getAnimationDuration() {
    if (!_config.enableAnimations) {
      return const Duration(milliseconds: 100);
    }

    // Aplica acessibilidade se disponível
    Duration baseDuration = currentCardStyle.animationDuration;
    if (_accessibilityService?.config.reduceMotion == true) {
      baseDuration = const Duration(milliseconds: 150);
    }

    return baseDuration;
  }

  /// Obtém curva de animação
  Curve getAnimationCurve() {
    if (!_config.enableAnimations ||
        _accessibilityService?.config.reduceMotion == true) {
      return Curves.linear;
    }

    switch (_config.cardStyle) {
      case CardStyle.modern:
        return Curves.easeInOutCubic;
      case CardStyle.classic:
        return Curves.easeInOut;
      case CardStyle.minimal:
        return Curves.easeOut;
      case CardStyle.playful:
        return Curves.elasticOut;
    }
  }

  /// Define tema baseado na luminosidade do sistema
  void setAutoTheme(Brightness systemBrightness) {
    if (_config.themeType == ThemeType.auto) {
      notifyListeners();
    }
  }

  /// Aplica tema de alto contraste
  void enableHighContrast(bool enable) {
    final newType = enable ? ThemeType.highContrast : ThemeType.auto;
    updateConfig(_config.copyWith(themeType: newType));
  }

  /// Obtém cores personalizadas para elementos específicos
  Map<String, Color> getCustomColors() {
    final palette = currentPalette;

    return {
      'gameInfoBackground': palette.surface.withValues(alpha: 0.9),
      'progressBarBackground': palette.cardBorder,
      'progressBarForeground': palette.accent,
      'pauseOverlay': Colors.black.withValues(alpha: 0.7),
      'successGlow': palette.success.withValues(alpha: 0.3),
      'errorGlow': palette.error.withValues(alpha: 0.3),
      'warningGlow': palette.warning.withValues(alpha: 0.3),
    };
  }

  /// Valida configuração de tema
  bool validateConfig(ThemeConfig config) {
    return config.interfaceScale >= 0.5 && config.interfaceScale <= 2.0;
  }

  /// Exporta configurações de tema
  Map<String, dynamic> exportConfig() {
    return {
      'themeType': _config.themeType.name,
      'cardStyle': _config.cardStyle.name,
      'interfaceScale': _config.interfaceScale,
      'enableAnimations': _config.enableAnimations,
      'enableParticles': _config.enableParticles,
      'enableGradients': _config.enableGradients,
      'customAccentColor': _config.customAccentColor?.value,
    };
  }

  /// Importa configurações de tema
  bool importConfig(Map<String, dynamic> data) {
    try {
      final themeType = ThemeType.values
              .where((t) => t.name == data['themeType'])
              .firstOrNull ??
          ThemeType.auto;

      final cardStyle = CardStyle.values
              .where((s) => s.name == data['cardStyle'])
              .firstOrNull ??
          CardStyle.modern;

      final config = ThemeConfig(
        themeType: themeType,
        cardStyle: cardStyle,
        interfaceScale: (data['interfaceScale'] as num?)?.toDouble() ?? 1.0,
        enableAnimations: data['enableAnimations'] as bool? ?? true,
        enableParticles: data['enableParticles'] as bool? ?? true,
        enableGradients: data['enableGradients'] as bool? ?? true,
        customAccentColor: data['customAccentColor'] != null
            ? Color(data['customAccentColor'] as int)
            : null,
      );

      if (validateConfig(config)) {
        updateConfig(config);
        return true;
      }
    } catch (e) {
      debugPrint('Erro ao importar configuração de tema: $e');
    }

    return false;
  }
}

/// Configuração de estilo de carta
class CardStyleConfig {
  final double borderRadius;
  final double elevation;
  final double borderWidth;
  final bool useGradient;
  final Duration animationDuration;
  final double shadowBlur;

  const CardStyleConfig({
    required this.borderRadius,
    required this.elevation,
    required this.borderWidth,
    required this.useGradient,
    required this.animationDuration,
    required this.shadowBlur,
  });
}
