// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';

/// Sistema de configuração avançado para o jogo Ping Pong
///
/// Permite personalização e persistência de configurações do jogador,
/// incluindo preferências de gameplay, interface e acessibilidade.


/// Gerenciador central de configurações
class GameConfiguration extends ChangeNotifier {
  /// Instância singleton
  static GameConfiguration? _instance;
  static GameConfiguration get instance => _instance ??= GameConfiguration._();

  GameConfiguration._();

  /// Configurações de gameplay
  GameplaySettings _gameplaySettings = GameplaySettings();

  /// Configurações de interface
  InterfaceSettings _interfaceSettings = InterfaceSettings();

  /// Configurações de áudio
  AudioSettings _audioSettings = AudioSettings();

  /// Configurações de controles
  ControlSettings _controlSettings = ControlSettings();

  /// Configurações de acessibilidade
  AccessibilitySettings _accessibilitySettings = AccessibilitySettings();

  /// Configurações de performance
  PerformanceSettings _performanceSettings = PerformanceSettings();

  /// Getters
  GameplaySettings get gameplay => _gameplaySettings;
  InterfaceSettings get interface => _interfaceSettings;
  AudioSettings get audio => _audioSettings;
  ControlSettings get controls => _controlSettings;
  AccessibilitySettings get accessibility => _accessibilitySettings;
  PerformanceSettings get performance => _performanceSettings;

  /// Inicializa as configurações
  Future<void> initialize() async {
    await _loadConfigurations();
    debugPrint('GameConfiguration inicializado');
    notifyListeners();
  }

  /// Carrega configurações salvas
  Future<void> _loadConfigurations() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Carrega configurações de gameplay
      final gameplayJson = prefs.getString('pingpong_gameplay_settings');
      if (gameplayJson != null) {
        _gameplaySettings =
            GameplaySettings.fromJson(json.decode(gameplayJson));
      }

      // Carrega configurações de interface
      final interfaceJson = prefs.getString('pingpong_interface_settings');
      if (interfaceJson != null) {
        _interfaceSettings =
            InterfaceSettings.fromJson(json.decode(interfaceJson));
      }

      // Carrega configurações de áudio
      final audioJson = prefs.getString('pingpong_audio_settings');
      if (audioJson != null) {
        _audioSettings = AudioSettings.fromJson(json.decode(audioJson));
      }

      // Carrega configurações de controles
      final controlsJson = prefs.getString('pingpong_control_settings');
      if (controlsJson != null) {
        _controlSettings = ControlSettings.fromJson(json.decode(controlsJson));
      }

      // Carrega configurações de acessibilidade
      final accessibilityJson =
          prefs.getString('pingpong_accessibility_settings');
      if (accessibilityJson != null) {
        _accessibilitySettings =
            AccessibilitySettings.fromJson(json.decode(accessibilityJson));
      }

      // Carrega configurações de performance
      final performanceJson = prefs.getString('pingpong_performance_settings');
      if (performanceJson != null) {
        _performanceSettings =
            PerformanceSettings.fromJson(json.decode(performanceJson));
      }
    } catch (e) {
      debugPrint('Erro ao carregar configurações: $e');
    }
  }

  /// Salva todas as configurações
  Future<void> saveConfigurations() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('pingpong_gameplay_settings',
          json.encode(_gameplaySettings.toJson()));
      await prefs.setString('pingpong_interface_settings',
          json.encode(_interfaceSettings.toJson()));
      await prefs.setString(
          'pingpong_audio_settings', json.encode(_audioSettings.toJson()));
      await prefs.setString(
          'pingpong_control_settings', json.encode(_controlSettings.toJson()));
      await prefs.setString('pingpong_accessibility_settings',
          json.encode(_accessibilitySettings.toJson()));
      await prefs.setString('pingpong_performance_settings',
          json.encode(_performanceSettings.toJson()));

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar configurações: $e');
    }
  }

  /// Atualiza configurações de gameplay
  void updateGameplaySettings(GameplaySettings settings) {
    _gameplaySettings = settings;
    saveConfigurations();
  }

  /// Atualiza configurações de interface
  void updateInterfaceSettings(InterfaceSettings settings) {
    _interfaceSettings = settings;
    saveConfigurations();
  }

  /// Atualiza configurações de áudio
  void updateAudioSettings(AudioSettings settings) {
    _audioSettings = settings;
    saveConfigurations();
  }

  /// Atualiza configurações de controles
  void updateControlSettings(ControlSettings settings) {
    _controlSettings = settings;
    saveConfigurations();
  }

  /// Atualiza configurações de acessibilidade
  void updateAccessibilitySettings(AccessibilitySettings settings) {
    _accessibilitySettings = settings;
    saveConfigurations();
  }

  /// Atualiza configurações de performance
  void updatePerformanceSettings(PerformanceSettings settings) {
    _performanceSettings = settings;
    saveConfigurations();
  }

  /// Reseta todas as configurações para padrão
  Future<void> resetToDefaults() async {
    _gameplaySettings = GameplaySettings();
    _interfaceSettings = InterfaceSettings();
    _audioSettings = AudioSettings();
    _controlSettings = ControlSettings();
    _accessibilitySettings = AccessibilitySettings();
    _performanceSettings = PerformanceSettings();

    await saveConfigurations();
  }

  /// Exporta configurações para compartilhamento
  Map<String, dynamic> exportSettings() {
    return {
      'gameplay': _gameplaySettings.toJson(),
      'interface': _interfaceSettings.toJson(),
      'audio': _audioSettings.toJson(),
      'controls': _controlSettings.toJson(),
      'accessibility': _accessibilitySettings.toJson(),
      'performance': _performanceSettings.toJson(),
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Importa configurações
  Future<bool> importSettings(Map<String, dynamic> settings) async {
    try {
      if (settings['gameplay'] != null) {
        _gameplaySettings = GameplaySettings.fromJson(settings['gameplay']);
      }
      if (settings['interface'] != null) {
        _interfaceSettings = InterfaceSettings.fromJson(settings['interface']);
      }
      if (settings['audio'] != null) {
        _audioSettings = AudioSettings.fromJson(settings['audio']);
      }
      if (settings['controls'] != null) {
        _controlSettings = ControlSettings.fromJson(settings['controls']);
      }
      if (settings['accessibility'] != null) {
        _accessibilitySettings =
            AccessibilitySettings.fromJson(settings['accessibility']);
      }
      if (settings['performance'] != null) {
        _performanceSettings =
            PerformanceSettings.fromJson(settings['performance']);
      }

      await saveConfigurations();
      return true;
    } catch (e) {
      debugPrint('Erro ao importar configurações: $e');
      return false;
    }
  }
}

/// Configurações de gameplay
class GameplaySettings {
  Difficulty defaultDifficulty;
  GameMode preferredGameMode;
  double ballSpeedMultiplier;
  double paddleSpeedMultiplier;
  int targetScore;
  bool enableAdaptiveDifficulty;
  bool autoRestart;
  bool quickStart;

  GameplaySettings({
    this.defaultDifficulty = Difficulty.medium,
    this.preferredGameMode = GameMode.singlePlayer,
    this.ballSpeedMultiplier = 1.0,
    this.paddleSpeedMultiplier = 1.0,
    this.targetScore = 10,
    this.enableAdaptiveDifficulty = true,
    this.autoRestart = false,
    this.quickStart = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'defaultDifficulty': defaultDifficulty.index,
      'preferredGameMode': preferredGameMode.index,
      'ballSpeedMultiplier': ballSpeedMultiplier,
      'paddleSpeedMultiplier': paddleSpeedMultiplier,
      'targetScore': targetScore,
      'enableAdaptiveDifficulty': enableAdaptiveDifficulty,
      'autoRestart': autoRestart,
      'quickStart': quickStart,
    };
  }

  factory GameplaySettings.fromJson(Map<String, dynamic> json) {
    return GameplaySettings(
      defaultDifficulty: Difficulty.values[json['defaultDifficulty'] ?? 1],
      preferredGameMode: GameMode.values[json['preferredGameMode'] ?? 0],
      ballSpeedMultiplier: json['ballSpeedMultiplier']?.toDouble() ?? 1.0,
      paddleSpeedMultiplier: json['paddleSpeedMultiplier']?.toDouble() ?? 1.0,
      targetScore: json['targetScore'] ?? 10,
      enableAdaptiveDifficulty: json['enableAdaptiveDifficulty'] ?? true,
      autoRestart: json['autoRestart'] ?? false,
      quickStart: json['quickStart'] ?? false,
    );
  }

  GameplaySettings copyWith({
    Difficulty? defaultDifficulty,
    GameMode? preferredGameMode,
    double? ballSpeedMultiplier,
    double? paddleSpeedMultiplier,
    int? targetScore,
    bool? enableAdaptiveDifficulty,
    bool? autoRestart,
    bool? quickStart,
  }) {
    return GameplaySettings(
      defaultDifficulty: defaultDifficulty ?? this.defaultDifficulty,
      preferredGameMode: preferredGameMode ?? this.preferredGameMode,
      ballSpeedMultiplier: ballSpeedMultiplier ?? this.ballSpeedMultiplier,
      paddleSpeedMultiplier:
          paddleSpeedMultiplier ?? this.paddleSpeedMultiplier,
      targetScore: targetScore ?? this.targetScore,
      enableAdaptiveDifficulty:
          enableAdaptiveDifficulty ?? this.enableAdaptiveDifficulty,
      autoRestart: autoRestart ?? this.autoRestart,
      quickStart: quickStart ?? this.quickStart,
    );
  }
}

/// Configurações de interface
class InterfaceSettings {
  ThemeType themeType;
  double uiScale;
  bool showFps;
  bool showStatistics;
  bool enableAnimations;
  bool enableParticleEffects;
  bool showBallTrail;
  Color customAccentColor;
  double interfaceOpacity;

  InterfaceSettings({
    this.themeType = ThemeType.classic,
    this.uiScale = 1.0,
    this.showFps = false,
    this.showStatistics = true,
    this.enableAnimations = true,
    this.enableParticleEffects = true,
    this.showBallTrail = true,
    this.customAccentColor = const Color(0xFF00BCD4),
    this.interfaceOpacity = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'themeType': themeType.index,
      'uiScale': uiScale,
      'showFps': showFps,
      'showStatistics': showStatistics,
      'enableAnimations': enableAnimations,
      'enableParticleEffects': enableParticleEffects,
      'showBallTrail': showBallTrail,
      'customAccentColor': customAccentColor.toARGB32(),
      'interfaceOpacity': interfaceOpacity,
    };
  }

  factory InterfaceSettings.fromJson(Map<String, dynamic> json) {
    return InterfaceSettings(
      themeType: ThemeType.values[json['themeType'] ?? 0],
      uiScale: json['uiScale']?.toDouble() ?? 1.0,
      showFps: json['showFps'] ?? false,
      showStatistics: json['showStatistics'] ?? true,
      enableAnimations: json['enableAnimations'] ?? true,
      enableParticleEffects: json['enableParticleEffects'] ?? true,
      showBallTrail: json['showBallTrail'] ?? true,
      customAccentColor: Color(json['customAccentColor'] ?? 0xFF00BCD4),
      interfaceOpacity: json['interfaceOpacity']?.toDouble() ?? 1.0,
    );
  }

  InterfaceSettings copyWith({
    ThemeType? themeType,
    double? uiScale,
    bool? showFps,
    bool? showStatistics,
    bool? enableAnimations,
    bool? enableParticleEffects,
    bool? showBallTrail,
    Color? customAccentColor,
    double? interfaceOpacity,
  }) {
    return InterfaceSettings(
      themeType: themeType ?? this.themeType,
      uiScale: uiScale ?? this.uiScale,
      showFps: showFps ?? this.showFps,
      showStatistics: showStatistics ?? this.showStatistics,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableParticleEffects:
          enableParticleEffects ?? this.enableParticleEffects,
      showBallTrail: showBallTrail ?? this.showBallTrail,
      customAccentColor: customAccentColor ?? this.customAccentColor,
      interfaceOpacity: interfaceOpacity ?? this.interfaceOpacity,
    );
  }
}

/// Configurações de áudio
class AudioSettings {
  bool enableSound;
  bool enableMusic;
  double masterVolume;
  double effectsVolume;
  double musicVolume;
  bool enableHapticFeedback;
  HapticIntensity hapticIntensity;
  bool enable3DAudio;

  AudioSettings({
    this.enableSound = true,
    this.enableMusic = true,
    this.masterVolume = 0.8,
    this.effectsVolume = 0.7,
    this.musicVolume = 0.3,
    this.enableHapticFeedback = true,
    this.hapticIntensity = HapticIntensity.medium,
    this.enable3DAudio = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'enableSound': enableSound,
      'enableMusic': enableMusic,
      'masterVolume': masterVolume,
      'effectsVolume': effectsVolume,
      'musicVolume': musicVolume,
      'enableHapticFeedback': enableHapticFeedback,
      'hapticIntensity': hapticIntensity.index,
      'enable3DAudio': enable3DAudio,
    };
  }

  factory AudioSettings.fromJson(Map<String, dynamic> json) {
    return AudioSettings(
      enableSound: json['enableSound'] ?? true,
      enableMusic: json['enableMusic'] ?? true,
      masterVolume: json['masterVolume']?.toDouble() ?? 0.8,
      effectsVolume: json['effectsVolume']?.toDouble() ?? 0.7,
      musicVolume: json['musicVolume']?.toDouble() ?? 0.3,
      enableHapticFeedback: json['enableHapticFeedback'] ?? true,
      hapticIntensity: HapticIntensity.values[json['hapticIntensity'] ?? 1],
      enable3DAudio: json['enable3DAudio'] ?? true,
    );
  }

  AudioSettings copyWith({
    bool? enableSound,
    bool? enableMusic,
    double? masterVolume,
    double? effectsVolume,
    double? musicVolume,
    bool? enableHapticFeedback,
    HapticIntensity? hapticIntensity,
    bool? enable3DAudio,
  }) {
    return AudioSettings(
      enableSound: enableSound ?? this.enableSound,
      enableMusic: enableMusic ?? this.enableMusic,
      masterVolume: masterVolume ?? this.masterVolume,
      effectsVolume: effectsVolume ?? this.effectsVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      hapticIntensity: hapticIntensity ?? this.hapticIntensity,
      enable3DAudio: enable3DAudio ?? this.enable3DAudio,
    );
  }
}

/// Configurações de controles
class ControlSettings {
  double touchSensitivity;
  bool enableGestures;
  bool invertVerticalAxis;
  double deadZone;
  ControlScheme primaryControlScheme;
  ControlScheme secondaryControlScheme;
  bool enableAutoMove;
  double autoMoveSpeed;

  ControlSettings({
    this.touchSensitivity = 1.0,
    this.enableGestures = true,
    this.invertVerticalAxis = false,
    this.deadZone = 0.1,
    this.primaryControlScheme = ControlScheme.touch,
    this.secondaryControlScheme = ControlScheme.keyboard,
    this.enableAutoMove = false,
    this.autoMoveSpeed = 0.5,
  });

  Map<String, dynamic> toJson() {
    return {
      'touchSensitivity': touchSensitivity,
      'enableGestures': enableGestures,
      'invertVerticalAxis': invertVerticalAxis,
      'deadZone': deadZone,
      'primaryControlScheme': primaryControlScheme.index,
      'secondaryControlScheme': secondaryControlScheme.index,
      'enableAutoMove': enableAutoMove,
      'autoMoveSpeed': autoMoveSpeed,
    };
  }

  factory ControlSettings.fromJson(Map<String, dynamic> json) {
    return ControlSettings(
      touchSensitivity: json['touchSensitivity']?.toDouble() ?? 1.0,
      enableGestures: json['enableGestures'] ?? true,
      invertVerticalAxis: json['invertVerticalAxis'] ?? false,
      deadZone: json['deadZone']?.toDouble() ?? 0.1,
      primaryControlScheme:
          ControlScheme.values[json['primaryControlScheme'] ?? 0],
      secondaryControlScheme:
          ControlScheme.values[json['secondaryControlScheme'] ?? 1],
      enableAutoMove: json['enableAutoMove'] ?? false,
      autoMoveSpeed: json['autoMoveSpeed']?.toDouble() ?? 0.5,
    );
  }

  ControlSettings copyWith({
    double? touchSensitivity,
    bool? enableGestures,
    bool? invertVerticalAxis,
    double? deadZone,
    ControlScheme? primaryControlScheme,
    ControlScheme? secondaryControlScheme,
    bool? enableAutoMove,
    double? autoMoveSpeed,
  }) {
    return ControlSettings(
      touchSensitivity: touchSensitivity ?? this.touchSensitivity,
      enableGestures: enableGestures ?? this.enableGestures,
      invertVerticalAxis: invertVerticalAxis ?? this.invertVerticalAxis,
      deadZone: deadZone ?? this.deadZone,
      primaryControlScheme: primaryControlScheme ?? this.primaryControlScheme,
      secondaryControlScheme:
          secondaryControlScheme ?? this.secondaryControlScheme,
      enableAutoMove: enableAutoMove ?? this.enableAutoMove,
      autoMoveSpeed: autoMoveSpeed ?? this.autoMoveSpeed,
    );
  }
}

/// Configurações de acessibilidade
class AccessibilitySettings {
  bool highContrastMode;
  double fontSize;
  bool enableScreenReader;
  bool reduceMotion;
  bool enableColorBlindSupport;
  ColorBlindType colorBlindType;
  bool enableVoiceCommands;
  bool showVisualIndicators;
  double buttonMinSize;

  AccessibilitySettings({
    this.highContrastMode = false,
    this.fontSize = 1.0,
    this.enableScreenReader = false,
    this.reduceMotion = false,
    this.enableColorBlindSupport = false,
    this.colorBlindType = ColorBlindType.none,
    this.enableVoiceCommands = false,
    this.showVisualIndicators = false,
    this.buttonMinSize = 44.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'highContrastMode': highContrastMode,
      'fontSize': fontSize,
      'enableScreenReader': enableScreenReader,
      'reduceMotion': reduceMotion,
      'enableColorBlindSupport': enableColorBlindSupport,
      'colorBlindType': colorBlindType.index,
      'enableVoiceCommands': enableVoiceCommands,
      'showVisualIndicators': showVisualIndicators,
      'buttonMinSize': buttonMinSize,
    };
  }

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      highContrastMode: json['highContrastMode'] ?? false,
      fontSize: json['fontSize']?.toDouble() ?? 1.0,
      enableScreenReader: json['enableScreenReader'] ?? false,
      reduceMotion: json['reduceMotion'] ?? false,
      enableColorBlindSupport: json['enableColorBlindSupport'] ?? false,
      colorBlindType: ColorBlindType.values[json['colorBlindType'] ?? 0],
      enableVoiceCommands: json['enableVoiceCommands'] ?? false,
      showVisualIndicators: json['showVisualIndicators'] ?? false,
      buttonMinSize: json['buttonMinSize']?.toDouble() ?? 44.0,
    );
  }

  AccessibilitySettings copyWith({
    bool? highContrastMode,
    double? fontSize,
    bool? enableScreenReader,
    bool? reduceMotion,
    bool? enableColorBlindSupport,
    ColorBlindType? colorBlindType,
    bool? enableVoiceCommands,
    bool? showVisualIndicators,
    double? buttonMinSize,
  }) {
    return AccessibilitySettings(
      highContrastMode: highContrastMode ?? this.highContrastMode,
      fontSize: fontSize ?? this.fontSize,
      enableScreenReader: enableScreenReader ?? this.enableScreenReader,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      enableColorBlindSupport:
          enableColorBlindSupport ?? this.enableColorBlindSupport,
      colorBlindType: colorBlindType ?? this.colorBlindType,
      enableVoiceCommands: enableVoiceCommands ?? this.enableVoiceCommands,
      showVisualIndicators: showVisualIndicators ?? this.showVisualIndicators,
      buttonMinSize: buttonMinSize ?? this.buttonMinSize,
    );
  }
}

/// Configurações de performance
class PerformanceSettings {
  int targetFps;
  bool enableVSync;
  QualityLevel visualQuality;
  bool enablePhysicsOptimization;
  bool enableMemoryOptimization;
  bool enableBatching;
  int maxParticles;
  bool enableBackgroundProcessing;

  PerformanceSettings({
    this.targetFps = 60,
    this.enableVSync = true,
    this.visualQuality = QualityLevel.high,
    this.enablePhysicsOptimization = true,
    this.enableMemoryOptimization = true,
    this.enableBatching = true,
    this.maxParticles = 100,
    this.enableBackgroundProcessing = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'targetFps': targetFps,
      'enableVSync': enableVSync,
      'visualQuality': visualQuality.index,
      'enablePhysicsOptimization': enablePhysicsOptimization,
      'enableMemoryOptimization': enableMemoryOptimization,
      'enableBatching': enableBatching,
      'maxParticles': maxParticles,
      'enableBackgroundProcessing': enableBackgroundProcessing,
    };
  }

  factory PerformanceSettings.fromJson(Map<String, dynamic> json) {
    return PerformanceSettings(
      targetFps: json['targetFps'] ?? 60,
      enableVSync: json['enableVSync'] ?? true,
      visualQuality: QualityLevel.values[json['visualQuality'] ?? 2],
      enablePhysicsOptimization: json['enablePhysicsOptimization'] ?? true,
      enableMemoryOptimization: json['enableMemoryOptimization'] ?? true,
      enableBatching: json['enableBatching'] ?? true,
      maxParticles: json['maxParticles'] ?? 100,
      enableBackgroundProcessing: json['enableBackgroundProcessing'] ?? true,
    );
  }

  PerformanceSettings copyWith({
    int? targetFps,
    bool? enableVSync,
    QualityLevel? visualQuality,
    bool? enablePhysicsOptimization,
    bool? enableMemoryOptimization,
    bool? enableBatching,
    int? maxParticles,
    bool? enableBackgroundProcessing,
  }) {
    return PerformanceSettings(
      targetFps: targetFps ?? this.targetFps,
      enableVSync: enableVSync ?? this.enableVSync,
      visualQuality: visualQuality ?? this.visualQuality,
      enablePhysicsOptimization:
          enablePhysicsOptimization ?? this.enablePhysicsOptimization,
      enableMemoryOptimization:
          enableMemoryOptimization ?? this.enableMemoryOptimization,
      enableBatching: enableBatching ?? this.enableBatching,
      maxParticles: maxParticles ?? this.maxParticles,
      enableBackgroundProcessing:
          enableBackgroundProcessing ?? this.enableBackgroundProcessing,
    );
  }
}

/// Enums para configurações

enum ThemeType {
  classic,
  neon,
  retro,
  modern,
  highContrast,
  custom,
}

enum HapticIntensity {
  light,
  medium,
  heavy,
}

enum ControlScheme {
  touch,
  keyboard,
  gamepad,
  hybrid,
}

enum ColorBlindType {
  none,
  deuteranopia,
  protanopia,
  tritanopia,
}

enum QualityLevel {
  low,
  medium,
  high,
  ultra,
}

/// Extensões para facilitar uso

extension ThemeTypeExtension on ThemeType {
  String get name {
    switch (this) {
      case ThemeType.classic:
        return 'Clássico';
      case ThemeType.neon:
        return 'Neon';
      case ThemeType.retro:
        return 'Retrô';
      case ThemeType.modern:
        return 'Moderno';
      case ThemeType.highContrast:
        return 'Alto Contraste';
      case ThemeType.custom:
        return 'Personalizado';
    }
  }
}

extension HapticIntensityExtension on HapticIntensity {
  String get name {
    switch (this) {
      case HapticIntensity.light:
        return 'Leve';
      case HapticIntensity.medium:
        return 'Médio';
      case HapticIntensity.heavy:
        return 'Forte';
    }
  }
}

extension ControlSchemeExtension on ControlScheme {
  String get name {
    switch (this) {
      case ControlScheme.touch:
        return 'Toque';
      case ControlScheme.keyboard:
        return 'Teclado';
      case ControlScheme.gamepad:
        return 'Controle';
      case ControlScheme.hybrid:
        return 'Híbrido';
    }
  }
}

extension QualityLevelExtension on QualityLevel {
  String get name {
    switch (this) {
      case QualityLevel.low:
        return 'Baixa';
      case QualityLevel.medium:
        return 'Média';
      case QualityLevel.high:
        return 'Alta';
      case QualityLevel.ultra:
        return 'Ultra';
    }
  }
}
