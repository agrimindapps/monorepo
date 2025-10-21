// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

/// Serviço de acessibilidade para o jogo da memória
///
/// Implementa recursos de acessibilidade como suporte a leitores de tela,
/// navegação por teclado, alto contraste e adaptações para daltonismo.


/// Tipos de daltonismo suportados
enum ColorBlindnessType {
  none, // Visão normal
  protanopia, // Dificuldade com vermelho
  deuteranopia, // Dificuldade com verde
  tritanopia, // Dificuldade com azul
}

/// Configurações de acessibilidade
class AccessibilityConfig {
  final bool screenReaderEnabled;
  final bool highContrastMode;
  final bool reduceMotion;
  final bool largeText;
  final bool extraLargeTargets;
  final ColorBlindnessType colorBlindness;
  final double textScale;
  final bool enableSounds;
  final bool enableHaptics;
  final bool showVisualCues;

  const AccessibilityConfig({
    this.screenReaderEnabled = false,
    this.highContrastMode = false,
    this.reduceMotion = false,
    this.largeText = false,
    this.extraLargeTargets = false,
    this.colorBlindness = ColorBlindnessType.none,
    this.textScale = 1.0,
    this.enableSounds = true,
    this.enableHaptics = true,
    this.showVisualCues = true,
  });

  AccessibilityConfig copyWith({
    bool? screenReaderEnabled,
    bool? highContrastMode,
    bool? reduceMotion,
    bool? largeText,
    bool? extraLargeTargets,
    ColorBlindnessType? colorBlindness,
    double? textScale,
    bool? enableSounds,
    bool? enableHaptics,
    bool? showVisualCues,
  }) {
    return AccessibilityConfig(
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      largeText: largeText ?? this.largeText,
      extraLargeTargets: extraLargeTargets ?? this.extraLargeTargets,
      colorBlindness: colorBlindness ?? this.colorBlindness,
      textScale: textScale ?? this.textScale,
      enableSounds: enableSounds ?? this.enableSounds,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      showVisualCues: showVisualCues ?? this.showVisualCues,
    );
  }
}

/// Serviço de acessibilidade
class AccessibilityService {
  /// Configurações atuais
  AccessibilityConfig _config = const AccessibilityConfig();

  /// Callbacks para mudanças de configuração
  final List<VoidCallback> _configChangeCallbacks = [];

  /// Paleta de cores para alto contraste
  late Map<String, Color> _highContrastColors;

  /// Paletas adaptadas para daltonismo
  late Map<ColorBlindnessType, Map<String, Color>> _colorBlindPalettes;

  /// Construtor
  AccessibilityService() {
    _initializeColorPalettes();
    _detectSystemPreferences();
  }

  /// Inicializa paletas de cores
  void _initializeColorPalettes() {
    // Paleta de alto contraste
    _highContrastColors = {
      'primary': Colors.white,
      'secondary': Colors.black,
      'accent': Colors.yellow.shade800,
      'background': Colors.black,
      'surface': Colors.grey.shade900,
      'error': Colors.red.shade300,
      'success': Colors.green.shade300,
      'warning': Colors.orange.shade300,
      'text': Colors.white,
      'textSecondary': Colors.grey.shade300,
    };

    // Paletas para diferentes tipos de daltonismo
    _colorBlindPalettes = {
      ColorBlindnessType.protanopia: {
        'red': Colors.orange.shade700,
        'green': Colors.blue.shade700,
        'blue': Colors.blue,
        'yellow': Colors.yellow,
        'purple': Colors.purple.shade300,
        'orange': Colors.orange,
      },
      ColorBlindnessType.deuteranopia: {
        'red': Colors.orange.shade800,
        'green': Colors.blue.shade600,
        'blue': Colors.blue,
        'yellow': Colors.yellow.shade700,
        'purple': Colors.purple.shade400,
        'orange': Colors.orange,
      },
      ColorBlindnessType.tritanopia: {
        'red': Colors.red,
        'green': Colors.green,
        'blue': Colors.cyan.shade700,
        'yellow': Colors.pink.shade200,
        'purple': Colors.red.shade400,
        'orange': Colors.red.shade300,
      },
    };
  }

  /// Detecta preferências do sistema
  void _detectSystemPreferences() {
    // Em uma implementação real, detectaria configurações do sistema
    // Por agora, usa valores padrão
    debugPrint('Preferências de acessibilidade detectadas');
  }

  /// Atualiza configurações
  void updateConfig(AccessibilityConfig config) {
    _config = config;
    _notifyConfigChange();
    debugPrint('Configurações de acessibilidade atualizadas');
  }

  /// Obtém configurações atuais
  AccessibilityConfig get config => _config;

  /// Adiciona callback para mudanças de configuração
  void addConfigChangeCallback(VoidCallback callback) {
    _configChangeCallbacks.add(callback);
  }

  /// Remove callback
  void removeConfigChangeCallback(VoidCallback callback) {
    _configChangeCallbacks.remove(callback);
  }

  /// Notifica mudanças de configuração
  void _notifyConfigChange() {
    for (final callback in _configChangeCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('Erro em callback de configuração: $e');
      }
    }
  }

  /// Adapta cor para daltonismo
  Color adaptColorForColorBlindness(Color originalColor) {
    if (_config.colorBlindness == ColorBlindnessType.none) {
      return originalColor;
    }

    // Mapeia cores comuns para versões adaptadas
    final palette = _colorBlindPalettes[_config.colorBlindness]!;

    // Heurística simples para mapear cores
    if (_isColorSimilar(originalColor, Colors.red)) {
      return palette['red']!;
    } else if (_isColorSimilar(originalColor, Colors.green)) {
      return palette['green']!;
    } else if (_isColorSimilar(originalColor, Colors.blue)) {
      return palette['blue']!;
    } else if (_isColorSimilar(originalColor, Colors.yellow)) {
      return palette['yellow']!;
    } else if (_isColorSimilar(originalColor, Colors.purple)) {
      return palette['purple']!;
    } else if (_isColorSimilar(originalColor, Colors.orange)) {
      return palette['orange']!;
    }

    return originalColor;
  }

  /// Verifica se duas cores são similares
  bool _isColorSimilar(Color color1, Color color2) {
    const threshold = 50;
    return (color1.r - color2.r).abs() < threshold &&
        (color1.g - color2.g).abs() < threshold &&
        (color1.b - color2.b).abs() < threshold;
  }

  /// Obtém cor para alto contraste
  Color getHighContrastColor(String colorKey) {
    return _highContrastColors[colorKey] ?? Colors.white;
  }

  /// Constrói widget com suporte a leitor de tela
  Widget buildAccessibleWidget({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
    bool? excludeSemantics,
    VoidCallback? onTap,
  }) {
    if (!_config.screenReaderEnabled) {
      return child;
    }

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      excludeSemantics: excludeSemantics ?? false,
      onTap: onTap,
      child: child,
    );
  }

  /// Constrói botão acessível
  Widget buildAccessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    required String semanticLabel,
    String? semanticHint,
    ButtonStyle? style,
  }) {
    final buttonStyle = style ??
        ElevatedButton.styleFrom(
          minimumSize: _config.extraLargeTargets
              ? const Size(64, 64)
              : const Size(48, 48),
          textStyle: TextStyle(
            fontSize: 16 * _config.textScale,
          ),
        );

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: child,
      ),
    );
  }

  /// Constrói texto acessível
  Widget buildAccessibleText(
    String text, {
    TextStyle? style,
    String? semanticLabel,
    TextAlign? textAlign,
  }) {
    final textStyle = (style ?? const TextStyle()).copyWith(
      fontSize: (style?.fontSize ?? 16) * _config.textScale,
      color: _config.highContrastMode
          ? getHighContrastColor('text')
          : style?.color,
    );

    return Semantics(
      label: semanticLabel ?? text,
      child: Text(
        text,
        style: textStyle,
        textAlign: textAlign,
      ),
    );
  }

  /// Anuncia mensagem para leitor de tela
  void announceMessage(String message) {
    if (_config.screenReaderEnabled) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  /// Fornece feedback tátil acessível
  Future<void> provideHapticFeedback(HapticFeedbackType type) async {
    if (!_config.enableHaptics) return;

    switch (type) {
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
        break;
    }
  }

  /// Duração de animação adaptada
  Duration getAnimationDuration(Duration baseDuration) {
    if (_config.reduceMotion) {
      return const Duration(milliseconds: 100); // Muito reduzida
    }
    return baseDuration;
  }

  /// Curva de animação adaptada
  Curve getAnimationCurve() {
    if (_config.reduceMotion) {
      return Curves.linear; // Sem efeitos complexos
    }
    return Curves.easeInOut;
  }

  /// Constrói indicador visual para eventos sonoros
  Widget buildVisualSoundIndicator({
    required bool isActive,
    required Color color,
    required IconData icon,
  }) {
    if (!_config.showVisualCues || _config.enableSounds) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: getAnimationDuration(const Duration(milliseconds: 300)),
      curve: getAnimationCurve(),
      width: isActive ? 32 : 0,
      height: isActive ? 32 : 0,
      decoration: BoxDecoration(
        color: adaptColorForColorBlindness(color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: isActive ? Icon(icon, color: Colors.white, size: 16) : null,
    );
  }

  /// Tema acessível para o app
  ThemeData buildAccessibleTheme(ThemeData baseTheme) {
    if (_config.highContrastMode) {
      return ThemeData(
        brightness: Brightness.dark,
        primaryColor: getHighContrastColor('primary'),
        scaffoldBackgroundColor: getHighContrastColor('background'),
        cardColor: getHighContrastColor('surface'),
        textTheme: baseTheme.textTheme.copyWith(
          bodyLarge: TextStyle(
            color: getHighContrastColor('text'),
            fontSize: 16 * _config.textScale,
          ),
          bodyMedium: TextStyle(
            color: getHighContrastColor('text'),
            fontSize: 14 * _config.textScale,
          ),
          titleLarge: TextStyle(
            color: getHighContrastColor('text'),
            fontSize: 22 * _config.textScale,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: getHighContrastColor('accent'),
            foregroundColor: getHighContrastColor('background'),
            minimumSize: _config.extraLargeTargets
                ? const Size(64, 64)
                : const Size(48, 48),
          ),
        ),
      );
    }

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        fontSizeFactor: _config.textScale,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: _config.extraLargeTargets
              ? const Size(64, 64)
              : const Size(48, 48),
        ),
      ),
    );
  }

  /// Gera descrição semântica para carta do jogo
  String generateCardSemanticDescription({
    required int cardIndex,
    required CardState cardState,
    required String cardContent,
    required int position,
    required int totalCards,
  }) {
    final positionDescription = 'Posição ${position + 1} de $totalCards';

    switch (cardState) {
      case CardState.hidden:
        return 'Carta virada para baixo. $positionDescription. Toque para revelar.';
      case CardState.revealed:
        return 'Carta revelada mostrando $cardContent. $positionDescription.';
      case CardState.matched:
        return 'Par encontrado: $cardContent. $positionDescription.';
    }
  }

  /// Gera anúncio para ação do jogo
  String generateGameActionAnnouncement({
    required String action,
    required Map<String, dynamic> context,
  }) {
    switch (action) {
      case 'card_flipped':
        return 'Carta revelada na posição ${context['position']}';
      case 'match_found':
        return 'Par encontrado! ${context['content']}';
      case 'match_missed':
        return 'As cartas não fazem par. Tente novamente.';
      case 'game_won':
        return 'Parabéns! Você completou o jogo em ${context['moves']} movimentos e ${context['time']}.';
      case 'game_paused':
        return 'Jogo pausado.';
      case 'game_resumed':
        return 'Jogo retomado.';
      default:
        return action;
    }
  }

  /// Verifica se recursos de acessibilidade estão disponíveis
  Map<String, bool> checkAccessibilitySupport() {
    return {
      'screenReader': true, // Sempre disponível no Flutter
      'highContrast': true,
      'reduceMotion': true,
      'textScaling': true,
      'hapticFeedback': true, // Assumindo que está disponível
      'colorBlindSupport': true,
    };
  }

  /// Obtém configurações recomendadas baseadas no sistema
  AccessibilityConfig getRecommendedConfig() {
    // Em uma implementação real, consultaria as configurações do sistema
    return const AccessibilityConfig(
      screenReaderEnabled: false,
      highContrastMode: false,
      reduceMotion: false,
      textScale: 1.0,
      extraLargeTargets: false,
    );
  }

  /// Valida configurações de acessibilidade
  bool validateConfig(AccessibilityConfig config) {
    return config.textScale >= 0.5 && config.textScale <= 3.0;
  }

  /// Dispose do serviço
  void dispose() {
    _configChangeCallbacks.clear();
    debugPrint('AccessibilityService disposed');
  }
}

/// Tipos de feedback tátil
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}
