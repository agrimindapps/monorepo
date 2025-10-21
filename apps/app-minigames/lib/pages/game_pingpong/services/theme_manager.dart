/// Gerenciador de temas e responsividade para o jogo Ping Pong
/// 
/// Controla temas visuais, adaptação para diferentes tamanhos de tela
/// e configurações de acessibilidade visual.
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';

/// Gerenciador central de temas e responsividade
class ThemeManager extends ChangeNotifier {
  /// Tema atual
  GameTheme _currentTheme = GameTheme.classic;
  
  /// Configurações de responsividade
  ResponsiveConfig _responsiveConfig = ResponsiveConfig();
  
  /// Configurações de acessibilidade
  AccessibilityConfig _accessibilityConfig = AccessibilityConfig();
  
  /// Tamanho atual da tela
  Size _screenSize = Size.zero;
  
  /// Orientação atual
  Orientation _orientation = Orientation.landscape;
  
  /// Categoria do dispositivo
  DeviceCategory _deviceCategory = DeviceCategory.phone;
  
  /// Cache de estilos computados
  final Map<String, dynamic> _styleCache = {};
  
  /// Getters
  GameTheme get currentTheme => _currentTheme;
  ResponsiveConfig get responsiveConfig => _responsiveConfig;
  AccessibilityConfig get accessibilityConfig => _accessibilityConfig;
  Size get screenSize => _screenSize;
  Orientation get orientation => _orientation;
  DeviceCategory get deviceCategory => _deviceCategory;
  
  /// Inicializa o gerenciador de temas
  void initialize() {
    _loadDefaultTheme();
    _loadDefaultConfigs();
    
    debugPrint('ThemeManager inicializado com tema: ${_currentTheme.name}');
    notifyListeners();
  }
  
  /// Carrega tema padrão
  void _loadDefaultTheme() {
    _currentTheme = GameTheme.classic;
    _clearStyleCache();
  }
  
  /// Carrega configurações padrão
  void _loadDefaultConfigs() {
    _responsiveConfig = ResponsiveConfig();
    _accessibilityConfig = AccessibilityConfig();
  }
  
  /// Atualiza informações da tela
  void updateScreenInfo(Size screenSize, Orientation orientation) {
    _screenSize = screenSize;
    _orientation = orientation;
    _deviceCategory = _calculateDeviceCategory(screenSize);
    _clearStyleCache();
    notifyListeners();
  }
  
  /// Calcula categoria do dispositivo
  DeviceCategory _calculateDeviceCategory(Size size) {
    final diagonal = _calculateScreenDiagonal(size);
    
    if (diagonal < 6.0) {
      return DeviceCategory.phone;
    } else if (diagonal < 9.0) {
      return DeviceCategory.phoneLarge;
    } else if (diagonal < 13.0) {
      return DeviceCategory.tablet;
    } else {
      return DeviceCategory.desktop;
    }
  }
  
  /// Calcula diagonal da tela em polegadas
  double _calculateScreenDiagonal(Size size) {
    // Assume densidade padrão de 160 DPI
    const dpi = 160.0;
    final widthInches = size.width / dpi;
    final heightInches = size.height / dpi;
    return (widthInches * widthInches + heightInches * heightInches) / 2;
  }
  
  /// Altera tema atual
  void setTheme(GameTheme theme) {
    _currentTheme = theme;
    _clearStyleCache();
    notifyListeners();
  }
  
  /// Limpa cache de estilos
  void _clearStyleCache() {
    _styleCache.clear();
  }
  
  /// Obtém configuração de cores do tema atual
  ThemeColors getColors() {
    return _getCachedStyle('colors', () {
      switch (_currentTheme) {
        case GameTheme.classic:
          return ThemeColors.classic();
        case GameTheme.neon:
          return ThemeColors.neon();
        case GameTheme.retro:
          return ThemeColors.retro();
        case GameTheme.modern:
          return ThemeColors.modern();
        case GameTheme.highContrast:
          return ThemeColors.highContrast();
        case GameTheme.darkMode:
          return ThemeColors.darkMode();
      }
    });
  }
  
  /// Obtém configuração de tipografia responsiva
  ResponsiveTypography getTypography() {
    return _getCachedStyle('typography', () {
      final baseScale = _getScaleFactor();
      
      return ResponsiveTypography(
        scoreSize: _scaleFont(36.0, baseScale),
        titleSize: _scaleFont(24.0, baseScale),
        bodySize: _scaleFont(16.0, baseScale),
        captionSize: _scaleFont(12.0, baseScale),
        buttonSize: _scaleFont(18.0, baseScale),
      );
    });
  }
  
  /// Obtém configuração de espaçamentos responsivos
  ResponsiveSpacing getSpacing() {
    return _getCachedStyle('spacing', () {
      final baseScale = _getScaleFactor();
      
      return ResponsiveSpacing(
        tiny: _scaleSize(4.0, baseScale),
        small: _scaleSize(8.0, baseScale),
        medium: _scaleSize(16.0, baseScale),
        large: _scaleSize(24.0, baseScale),
        extraLarge: _scaleSize(32.0, baseScale),
      );
    });
  }
  
  /// Obtém configuração de tamanhos de elementos do jogo
  GameElementSizes getGameElementSizes() {
    return _getCachedStyle('gameSizes', () {
      final baseScale = _getScaleFactor();
      
      return GameElementSizes(
        ballRadius: _scaleSize(GameConfig.ballRadius, baseScale),
        paddleWidth: _scaleSize(GameConfig.paddleWidth, baseScale),
        paddleHeight: _scaleSize(GameConfig.paddleHeight, baseScale),
        controlButtonSize: _scaleSize(56.0, baseScale),
        hudIconSize: _scaleSize(24.0, baseScale),
      );
    });
  }
  
  /// Obtém configuração de layout responsivo
  ResponsiveLayout getLayout() {
    return _getCachedStyle('layout', () {
      switch (_deviceCategory) {
        case DeviceCategory.phone:
          return ResponsiveLayout.phone();
        case DeviceCategory.phoneLarge:
          return ResponsiveLayout.phoneLarge();
        case DeviceCategory.tablet:
          return ResponsiveLayout.tablet();
        case DeviceCategory.desktop:
          return ResponsiveLayout.desktop();
      }
    });
  }
  
  /// Obtém fator de escala baseado no dispositivo
  double _getScaleFactor() {
    switch (_deviceCategory) {
      case DeviceCategory.phone:
        return 0.9;
      case DeviceCategory.phoneLarge:
        return 1.0;
      case DeviceCategory.tablet:
        return 1.2;
      case DeviceCategory.desktop:
        return 1.4;
    }
  }
  
  /// Escala tamanho de fonte
  double _scaleFont(double baseSize, double scale) {
    final scaledSize = baseSize * scale;
    
    // Aplica ajustes de acessibilidade
    final accessibilityScale = _accessibilityConfig.fontScale;
    return scaledSize * accessibilityScale;
  }
  
  /// Escala tamanho de elemento
  double _scaleSize(double baseSize, double scale) {
    return baseSize * scale;
  }
  
  /// Obtém valor do cache ou calcula novo
  T _getCachedStyle<T>(String key, T Function() calculator) {
    if (_styleCache.containsKey(key)) {
      return _styleCache[key] as T;
    }
    
    final value = calculator();
    _styleCache[key] = value;
    return value;
  }
  
  /// Configura acessibilidade
  void setAccessibilityConfig(AccessibilityConfig config) {
    _accessibilityConfig = config;
    _clearStyleCache();
    notifyListeners();
  }
  
  /// Configura responsividade
  void setResponsiveConfig(ResponsiveConfig config) {
    _responsiveConfig = config;
    _clearStyleCache();
    notifyListeners();
  }
  
  /// Verifica se tela é pequena
  bool get isSmallScreen => _deviceCategory == DeviceCategory.phone;
  
  /// Verifica se tela é grande
  bool get isLargeScreen => _deviceCategory == DeviceCategory.tablet || 
                           _deviceCategory == DeviceCategory.desktop;
  
  /// Verifica se está em modo landscape
  bool get isLandscape => _orientation == Orientation.landscape;
  
  /// Verifica se está em modo portrait
  bool get isPortrait => _orientation == Orientation.portrait;
  
  /// Obtém padding seguro para a tela
  EdgeInsets getSafePadding(MediaQueryData mediaQuery) {
    final padding = mediaQuery.padding;
    final layout = getLayout();
    
    return EdgeInsets.only(
      top: padding.top + layout.topSafeArea,
      bottom: padding.bottom + layout.bottomSafeArea,
      left: padding.left + layout.leftSafeArea,
      right: padding.right + layout.rightSafeArea,
    );
  }
  
  /// Obtém configurações de animação baseadas na performance
  AnimationConfig getAnimationConfig() {
    return _getCachedStyle('animation', () {
      // Reduz animações em dispositivos menores
      final reduced = _deviceCategory == DeviceCategory.phone || 
                     _accessibilityConfig.reduceAnimations;
      
      return AnimationConfig(
        enableParticles: !reduced,
        enableTrails: !reduced,
        enableGlow: !reduced,
        animationDuration: reduced ? 150 : 300,
        transitionDuration: reduced ? 200 : 400,
      );
    });
  }
  
  /// Salva configurações
  Map<String, dynamic> saveSettings() {
    return {
      'currentTheme': _currentTheme.index,
      'responsiveConfig': _responsiveConfig.toMap(),
      'accessibilityConfig': _accessibilityConfig.toMap(),
    };
  }
  
  /// Carrega configurações
  void loadSettings(Map<String, dynamic> settings) {
    if (settings.containsKey('currentTheme')) {
      final themeIndex = settings['currentTheme'] as int;
      _currentTheme = GameTheme.values[themeIndex.clamp(0, GameTheme.values.length - 1)];
    }
    
    if (settings.containsKey('responsiveConfig')) {
      _responsiveConfig = ResponsiveConfig.fromMap(settings['responsiveConfig']);
    }
    
    if (settings.containsKey('accessibilityConfig')) {
      _accessibilityConfig = AccessibilityConfig.fromMap(settings['accessibilityConfig']);
    }
    
    _clearStyleCache();
    notifyListeners();
  }
  
  /// Obtém estatísticas do tema
  Map<String, dynamic> getThemeStatistics() {
    return {
      'currentTheme': _currentTheme.name,
      'deviceCategory': _deviceCategory.name,
      'screenSize': '${_screenSize.width.round()}x${_screenSize.height.round()}',
      'orientation': _orientation.name,
      'scaleFactor': _getScaleFactor(),
      'cacheSize': _styleCache.length,
    };
  }
}

/// Temas disponíveis
enum GameTheme {
  classic,
  neon,
  retro,
  modern,
  highContrast,
  darkMode,
}

/// Categorias de dispositivo
enum DeviceCategory {
  phone,
  phoneLarge,
  tablet,
  desktop,
}

/// Configuração de cores do tema
class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onBackground;
  final Color onSurface;
  final Color ball;
  final Color playerPaddle;
  final Color aiPaddle;
  final Color fieldLines;
  final Color trail;
  final Color accent;
  
  ThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onBackground,
    required this.onSurface,
    required this.ball,
    required this.playerPaddle,
    required this.aiPaddle,
    required this.fieldLines,
    required this.trail,
    required this.accent,
  });
  
  factory ThemeColors.classic() {
    return ThemeColors(
      primary: Colors.white,
      secondary: Colors.grey,
      background: Colors.black,
      surface: Colors.grey.shade900,
      onBackground: Colors.white,
      onSurface: Colors.white,
      ball: Colors.white,
      playerPaddle: Colors.white,
      aiPaddle: Colors.white,
      fieldLines: Colors.white.withValues(alpha: 0.5),
      trail: Colors.cyan,
      accent: Colors.cyan,
    );
  }
  
  factory ThemeColors.neon() {
    return ThemeColors(
      primary: const Color(0xFF00FFFF),
      secondary: const Color(0xFFFF00FF),
      background: const Color(0xFF0A0A0A),
      surface: const Color(0xFF1A1A1A),
      onBackground: const Color(0xFF00FFFF),
      onSurface: const Color(0xFF00FFFF),
      ball: const Color(0xFF00FFFF),
      playerPaddle: const Color(0xFF00FF00),
      aiPaddle: const Color(0xFFFF0080),
      fieldLines: const Color(0xFF00FFFF),
      trail: const Color(0xFF00FFFF),
      accent: const Color(0xFFFF00FF),
    );
  }
  
  factory ThemeColors.retro() {
    return ThemeColors(
      primary: const Color(0xFFFFD700),
      secondary: const Color(0xFFFF6B35),
      background: const Color(0xFF2E1A47),
      surface: const Color(0xFF3E2A57),
      onBackground: const Color(0xFFFFD700),
      onSurface: const Color(0xFFFFD700),
      ball: const Color(0xFFFFD700),
      playerPaddle: const Color(0xFF4ECDC4),
      aiPaddle: const Color(0xFFFF6B35),
      fieldLines: const Color(0xFFFFD700),
      trail: const Color(0xFF4ECDC4),
      accent: const Color(0xFFFF6B35),
    );
  }
  
  factory ThemeColors.modern() {
    return ThemeColors(
      primary: const Color(0xFF6C63FF),
      secondary: const Color(0xFF4ECDC4),
      background: const Color(0xFFF8F9FA),
      surface: Colors.white,
      onBackground: const Color(0xFF2D3748),
      onSurface: const Color(0xFF2D3748),
      ball: const Color(0xFF6C63FF),
      playerPaddle: const Color(0xFF4ECDC4),
      aiPaddle: const Color(0xFFFF6B6B),
      fieldLines: const Color(0xFFE2E8F0),
      trail: const Color(0xFF6C63FF),
      accent: const Color(0xFF4ECDC4),
    );
  }
  
  factory ThemeColors.highContrast() {
    return ThemeColors(
      primary: Colors.white,
      secondary: Colors.yellow,
      background: Colors.black,
      surface: Colors.grey.shade900,
      onBackground: Colors.white,
      onSurface: Colors.white,
      ball: Colors.yellow,
      playerPaddle: Colors.white,
      aiPaddle: Colors.red,
      fieldLines: Colors.white,
      trail: Colors.yellow,
      accent: Colors.yellow,
    );
  }
  
  factory ThemeColors.darkMode() {
    return ThemeColors(
      primary: const Color(0xFF90CAF9),
      secondary: const Color(0xFFCE93D8),
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      onBackground: const Color(0xFFE1E1E1),
      onSurface: const Color(0xFFE1E1E1),
      ball: const Color(0xFF90CAF9),
      playerPaddle: const Color(0xFF81C784),
      aiPaddle: const Color(0xFFFFAB91),
      fieldLines: const Color(0xFF424242),
      trail: const Color(0xFF90CAF9),
      accent: const Color(0xFFCE93D8),
    );
  }
}

/// Configuração de tipografia responsiva
class ResponsiveTypography {
  final double scoreSize;
  final double titleSize;
  final double bodySize;
  final double captionSize;
  final double buttonSize;
  
  ResponsiveTypography({
    required this.scoreSize,
    required this.titleSize,
    required this.bodySize,
    required this.captionSize,
    required this.buttonSize,
  });
}

/// Configuração de espaçamentos responsivos
class ResponsiveSpacing {
  final double tiny;
  final double small;
  final double medium;
  final double large;
  final double extraLarge;
  
  ResponsiveSpacing({
    required this.tiny,
    required this.small,
    required this.medium,
    required this.large,
    required this.extraLarge,
  });
}

/// Tamanhos de elementos do jogo
class GameElementSizes {
  final double ballRadius;
  final double paddleWidth;
  final double paddleHeight;
  final double controlButtonSize;
  final double hudIconSize;
  
  GameElementSizes({
    required this.ballRadius,
    required this.paddleWidth,
    required this.paddleHeight,
    required this.controlButtonSize,
    required this.hudIconSize,
  });
}

/// Configuração de layout responsivo
class ResponsiveLayout {
  final double topSafeArea;
  final double bottomSafeArea;
  final double leftSafeArea;
  final double rightSafeArea;
  final double maxContentWidth;
  final bool showSidePanels;
  final bool compactMode;
  
  ResponsiveLayout({
    required this.topSafeArea,
    required this.bottomSafeArea,
    required this.leftSafeArea,
    required this.rightSafeArea,
    required this.maxContentWidth,
    required this.showSidePanels,
    required this.compactMode,
  });
  
  factory ResponsiveLayout.phone() {
    return ResponsiveLayout(
      topSafeArea: 8.0,
      bottomSafeArea: 8.0,
      leftSafeArea: 16.0,
      rightSafeArea: 16.0,
      maxContentWidth: double.infinity,
      showSidePanels: false,
      compactMode: true,
    );
  }
  
  factory ResponsiveLayout.phoneLarge() {
    return ResponsiveLayout(
      topSafeArea: 12.0,
      bottomSafeArea: 12.0,
      leftSafeArea: 20.0,
      rightSafeArea: 20.0,
      maxContentWidth: double.infinity,
      showSidePanels: false,
      compactMode: false,
    );
  }
  
  factory ResponsiveLayout.tablet() {
    return ResponsiveLayout(
      topSafeArea: 16.0,
      bottomSafeArea: 16.0,
      leftSafeArea: 32.0,
      rightSafeArea: 32.0,
      maxContentWidth: 1200.0,
      showSidePanels: true,
      compactMode: false,
    );
  }
  
  factory ResponsiveLayout.desktop() {
    return ResponsiveLayout(
      topSafeArea: 20.0,
      bottomSafeArea: 20.0,
      leftSafeArea: 48.0,
      rightSafeArea: 48.0,
      maxContentWidth: 1400.0,
      showSidePanels: true,
      compactMode: false,
    );
  }
}

/// Configuração de responsividade
class ResponsiveConfig {
  final bool autoScale;
  final double minScale;
  final double maxScale;
  final bool adaptToOrientation;
  
  ResponsiveConfig({
    this.autoScale = true,
    this.minScale = 0.8,
    this.maxScale = 1.5,
    this.adaptToOrientation = true,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'autoScale': autoScale,
      'minScale': minScale,
      'maxScale': maxScale,
      'adaptToOrientation': adaptToOrientation,
    };
  }
  
  factory ResponsiveConfig.fromMap(Map<String, dynamic> map) {
    return ResponsiveConfig(
      autoScale: map['autoScale'] ?? true,
      minScale: map['minScale']?.toDouble() ?? 0.8,
      maxScale: map['maxScale']?.toDouble() ?? 1.5,
      adaptToOrientation: map['adaptToOrientation'] ?? true,
    );
  }
}

/// Configuração de acessibilidade
class AccessibilityConfig {
  final double fontScale;
  final bool highContrast;
  final bool reduceAnimations;
  final bool showFocusIndicators;
  final bool enhanceHitTargets;
  
  AccessibilityConfig({
    this.fontScale = 1.0,
    this.highContrast = false,
    this.reduceAnimations = false,
    this.showFocusIndicators = false,
    this.enhanceHitTargets = false,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'fontScale': fontScale,
      'highContrast': highContrast,
      'reduceAnimations': reduceAnimations,
      'showFocusIndicators': showFocusIndicators,
      'enhanceHitTargets': enhanceHitTargets,
    };
  }
  
  factory AccessibilityConfig.fromMap(Map<String, dynamic> map) {
    return AccessibilityConfig(
      fontScale: map['fontScale']?.toDouble() ?? 1.0,
      highContrast: map['highContrast'] ?? false,
      reduceAnimations: map['reduceAnimations'] ?? false,
      showFocusIndicators: map['showFocusIndicators'] ?? false,
      enhanceHitTargets: map['enhanceHitTargets'] ?? false,
    );
  }
}

/// Configuração de animações
class AnimationConfig {
  final bool enableParticles;
  final bool enableTrails;
  final bool enableGlow;
  final int animationDuration;
  final int transitionDuration;
  
  AnimationConfig({
    required this.enableParticles,
    required this.enableTrails,
    required this.enableGlow,
    required this.animationDuration,
    required this.transitionDuration,
  });
}
