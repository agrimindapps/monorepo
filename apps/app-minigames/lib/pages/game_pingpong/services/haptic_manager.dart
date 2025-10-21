/// Gerenciador de feedback tátil para o jogo Ping Pong
/// 
/// Fornece feedback háptico contextual e personalizado
/// baseado nas ações e eventos do jogo.
library;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Gerenciador de feedback tátil contextual
class HapticManager extends ChangeNotifier {
  /// Configurações de intensidade
  double _intensity = 0.8;
  bool _isEnabled = true;
  
  /// Configurações avançadas
  bool _contextualFeedback = true;
  bool _adaptiveIntensity = true;
  HapticQuality _quality = HapticQuality.medium;
  
  /// Estatísticas de uso
  int _feedbackCount = 0;
  DateTime? _lastFeedback;
  
  /// Padrões de feedback customizados
  final Map<GameEvent, HapticPattern> _patterns = {};
  
  /// Timer para feedback contínuo
  Timer? _continuousFeedbackTimer;
  
  /// Histórico de feedback para análise
  final List<HapticEvent> _feedbackHistory = [];
  
  /// Configurações de acessibilidade
  bool _accessibilityMode = false;
  double _accessibilityIntensityMultiplier = 1.5;
  
  /// Getters
  double get intensity => _intensity;
  bool get isEnabled => _isEnabled;
  bool get contextualFeedback => _contextualFeedback;
  bool get adaptiveIntensity => _adaptiveIntensity;
  HapticQuality get quality => _quality;
  bool get accessibilityMode => _accessibilityMode;
  
  /// Inicializa o gerenciador de haptic
  Future<void> initialize() async {
    _loadDefaultPatterns();
    _feedbackCount = 0;
    _feedbackHistory.clear();
    
    debugPrint('HapticManager inicializado');
    notifyListeners();
  }
  
  /// Carrega padrões padrão de feedback
  void _loadDefaultPatterns() {
    _patterns[GameEvent.paddleHit] = HapticPattern(
      type: HapticType.impact,
      intensity: 0.7,
      duration: const Duration(milliseconds: 50),
      pattern: [50],
    );
    
    _patterns[GameEvent.wallBounce] = HapticPattern(
      type: HapticType.impact,
      intensity: 0.5,
      duration: const Duration(milliseconds: 30),
      pattern: [30],
    );
    
    _patterns[GameEvent.score] = HapticPattern(
      type: HapticType.notification,
      intensity: 1.0,
      duration: const Duration(milliseconds: 200),
      pattern: [100, 50, 100],
    );
    
    _patterns[GameEvent.gameWin] = HapticPattern(
      type: HapticType.success,
      intensity: 1.0,
      duration: const Duration(milliseconds: 500),
      pattern: [100, 50, 100, 50, 150],
    );
    
    _patterns[GameEvent.gameLose] = HapticPattern(
      type: HapticType.failure,
      intensity: 0.8,
      duration: const Duration(milliseconds: 300),
      pattern: [200, 100, 200],
    );
    
    _patterns[GameEvent.buttonPress] = HapticPattern(
      type: HapticType.selection,
      intensity: 0.4,
      duration: const Duration(milliseconds: 25),
      pattern: [25],
    );
    
    _patterns[GameEvent.menuNavigation] = HapticPattern(
      type: HapticType.selection,
      intensity: 0.3,
      duration: const Duration(milliseconds: 20),
      pattern: [20],
    );
    
    _patterns[GameEvent.powerUp] = HapticPattern(
      type: HapticType.impact,
      intensity: 0.9,
      duration: const Duration(milliseconds: 100),
      pattern: [25, 25, 25, 25],
    );
  }
  
  /// Executa feedback para um evento específico
  void triggerFeedback(GameEvent event, {
    double? customIntensity,
    Map<String, dynamic>? context,
  }) {
    if (!_isEnabled) return;
    
    final pattern = _patterns[event];
    if (pattern == null) return;
    
    // Calcula intensidade final
    final finalIntensity = _calculateFinalIntensity(
      pattern.intensity,
      customIntensity,
      context,
    );
    
    if (finalIntensity <= 0.0) return;
    
    // Registra evento
    _recordFeedbackEvent(event, finalIntensity, context);
    
    // Executa feedback baseado no tipo
    _executeFeedback(pattern, finalIntensity, context);
    
    _feedbackCount++;
    _lastFeedback = DateTime.now();
    
    // Cleanup do histórico
    _cleanupHistory();
  }
  
  /// Executa feedback para colisão com raquete
  void triggerPaddleHit(double impact, double ballSpeed, bool isPlayer) {
    if (!_isEnabled) return;
    
    final context = {
      'impact': impact,
      'ballSpeed': ballSpeed,
      'isPlayer': isPlayer,
    };
    
    // Intensidade baseada no impacto
    final impactIntensity = (impact / 5.0).clamp(0.3, 1.0);
    
    // Padrão diferente para jogador vs IA
    if (isPlayer) {
      triggerFeedback(
        GameEvent.paddleHit,
        customIntensity: impactIntensity,
        context: context,
      );
    } else {
      // Feedback mais suave para raquete da IA
      triggerFeedback(
        GameEvent.paddleHit,
        customIntensity: impactIntensity * 0.6,
        context: context,
      );
    }
  }
  
  /// Executa feedback para colisão com parede
  void triggerWallBounce(double ballSpeed, double angle) {
    if (!_isEnabled) return;
    
    final context = {
      'ballSpeed': ballSpeed,
      'angle': angle,
    };
    
    // Intensidade baseada na velocidade
    final speedIntensity = (ballSpeed / 10.0).clamp(0.2, 0.8);
    
    triggerFeedback(
      GameEvent.wallBounce,
      customIntensity: speedIntensity,
      context: context,
    );
  }
  
  /// Executa feedback para pontuação
  void triggerScore(bool playerScored, int newScore, int maxScore) {
    if (!_isEnabled) return;
    
    final context = {
      'playerScored': playerScored,
      'newScore': newScore,
      'maxScore': maxScore,
    };
    
    if (newScore >= maxScore) {
      // Fim de jogo
      triggerFeedback(
        playerScored ? GameEvent.gameWin : GameEvent.gameLose,
        context: context,
      );
    } else {
      // Pontuação normal
      final intensity = playerScored ? 1.0 : 0.6;
      triggerFeedback(
        GameEvent.score,
        customIntensity: intensity,
        context: context,
      );
    }
  }
  
  /// Executa feedback contínuo (para power-ups, etc.)
  void startContinuousFeedback(GameEvent event, Duration interval) {
    stopContinuousFeedback();
    
    _continuousFeedbackTimer = Timer.periodic(interval, (timer) {
      triggerFeedback(event);
    });
  }
  
  /// Para feedback contínuo
  void stopContinuousFeedback() {
    _continuousFeedbackTimer?.cancel();
    _continuousFeedbackTimer = null;
  }
  
  /// Calcula intensidade final considerando contexto
  double _calculateFinalIntensity(
    double baseIntensity,
    double? customIntensity,
    Map<String, dynamic>? context,
  ) {
    double finalIntensity = customIntensity ?? baseIntensity;
    
    // Aplica intensidade global
    finalIntensity *= _intensity;
    
    // Aplica multiplicador de acessibilidade
    if (_accessibilityMode) {
      finalIntensity *= _accessibilityIntensityMultiplier;
    }
    
    // Intensidade adaptativa baseada no contexto
    if (_adaptiveIntensity && context != null) {
      finalIntensity = _applyAdaptiveIntensity(finalIntensity, context);
    }
    
    return finalIntensity.clamp(0.0, 1.0);
  }
  
  /// Aplica intensidade adaptativa
  double _applyAdaptiveIntensity(double intensity, Map<String, dynamic> context) {
    // Reduz intensidade se houve feedback recente
    if (_lastFeedback != null) {
      final timeSinceLastFeedback = DateTime.now().difference(_lastFeedback!);
      if (timeSinceLastFeedback.inMilliseconds < 100) {
        intensity *= 0.7; // Reduz para evitar sobrecarga
      }
    }
    
    // Ajusta baseado na velocidade da bola
    if (context.containsKey('ballSpeed')) {
      final ballSpeed = context['ballSpeed'] as double;
      if (ballSpeed > 8.0) {
        intensity *= 1.2; // Aumenta para bolas rápidas
      } else if (ballSpeed < 3.0) {
        intensity *= 0.8; // Reduz para bolas lentas
      }
    }
    
    return intensity;
  }
  
  /// Executa o feedback físico
  void _executeFeedback(
    HapticPattern pattern,
    double intensity,
    Map<String, dynamic>? context,
  ) {
    switch (pattern.type) {
      case HapticType.impact:
        _executeImpactFeedback(intensity);
        break;
      case HapticType.notification:
        _executeNotificationFeedback(pattern, intensity);
        break;
      case HapticType.selection:
        _executeSelectionFeedback();
        break;
      case HapticType.success:
        _executeSuccessFeedback(pattern);
        break;
      case HapticType.failure:
        _executeFailureFeedback(pattern);
        break;
      case HapticType.custom:
        _executeCustomFeedback(pattern, intensity);
        break;
    }
  }
  
  /// Executa feedback de impacto
  void _executeImpactFeedback(double intensity) {
    if (intensity > 0.7) {
      HapticFeedback.heavyImpact();
    } else if (intensity > 0.4) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }
  
  /// Executa feedback de notificação
  void _executeNotificationFeedback(HapticPattern pattern, double intensity) {
    // Simula padrão de vibração para notificação
    for (int i = 0; i < pattern.pattern.length; i++) {
      Timer(Duration(milliseconds: i * 75), () {
        if (i % 2 == 0) {
          _executeImpactFeedback(intensity);
        }
      });
    }
  }
  
  /// Executa feedback de seleção
  void _executeSelectionFeedback() {
    HapticFeedback.selectionClick();
  }
  
  /// Executa feedback de sucesso
  void _executeSuccessFeedback(HapticPattern pattern) {
    // Padrão crescente para sucesso
    for (int i = 0; i < 3; i++) {
      Timer(Duration(milliseconds: i * 100), () {
        final intensity = 0.5 + (i * 0.25);
        _executeImpactFeedback(intensity);
      });
    }
  }
  
  /// Executa feedback de falha
  void _executeFailureFeedback(HapticPattern pattern) {
    // Padrão decrescente para falha
    for (int i = 0; i < 2; i++) {
      Timer(Duration(milliseconds: i * 150), () {
        final intensity = 0.8 - (i * 0.3);
        _executeImpactFeedback(intensity);
      });
    }
  }
  
  /// Executa feedback customizado
  void _executeCustomFeedback(HapticPattern pattern, double intensity) {
    for (int i = 0; i < pattern.pattern.length; i++) {
      final delay = pattern.pattern.take(i).fold(0, (a, b) => a + b);
      Timer(Duration(milliseconds: delay), () {
        _executeImpactFeedback(intensity);
      });
    }
  }
  
  /// Registra evento de feedback
  void _recordFeedbackEvent(
    GameEvent event,
    double intensity,
    Map<String, dynamic>? context,
  ) {
    _feedbackHistory.add(HapticEvent(
      event: event,
      intensity: intensity,
      timestamp: DateTime.now(),
      context: context ?? {},
    ));
  }
  
  /// Remove eventos antigos do histórico
  void _cleanupHistory() {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 5));
    _feedbackHistory.removeWhere((event) => event.timestamp.isBefore(cutoff));
    
    // Limita tamanho máximo
    if (_feedbackHistory.length > 100) {
      _feedbackHistory.removeRange(0, _feedbackHistory.length - 100);
    }
  }
  
  /// Cria padrão customizado
  void createCustomPattern(
    GameEvent event,
    HapticType type,
    double intensity,
    List<int> pattern,
  ) {
    _patterns[event] = HapticPattern(
      type: type,
      intensity: intensity,
      duration: Duration(milliseconds: pattern.fold(0, (a, b) => a + b)),
      pattern: pattern,
    );
    notifyListeners();
  }
  
  /// Configurações
  void setIntensity(double intensity) {
    _intensity = intensity.clamp(0.0, 1.0);
    notifyListeners();
  }
  
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stopContinuousFeedback();
    }
    notifyListeners();
  }
  
  void setContextualFeedback(bool enabled) {
    _contextualFeedback = enabled;
    notifyListeners();
  }
  
  void setAdaptiveIntensity(bool enabled) {
    _adaptiveIntensity = enabled;
    notifyListeners();
  }
  
  void setQuality(HapticQuality quality) {
    _quality = quality;
    notifyListeners();
  }
  
  void setAccessibilityMode(bool enabled) {
    _accessibilityMode = enabled;
    notifyListeners();
  }
  
  /// Obtém estatísticas
  Map<String, dynamic> getStatistics() {
    final eventCounts = <String, int>{};
    for (final event in _feedbackHistory) {
      final eventName = event.event.toString();
      eventCounts[eventName] = (eventCounts[eventName] ?? 0) + 1;
    }
    
    return {
      'totalFeedbacks': _feedbackCount,
      'recentEvents': _feedbackHistory.length,
      'lastFeedback': _lastFeedback?.millisecondsSinceEpoch,
      'eventCounts': eventCounts,
      'isEnabled': _isEnabled,
      'intensity': _intensity,
      'quality': _quality.toString(),
      'accessibilityMode': _accessibilityMode,
    };
  }
  
  /// Salva configurações
  Map<String, dynamic> saveSettings() {
    return {
      'intensity': _intensity,
      'isEnabled': _isEnabled,
      'contextualFeedback': _contextualFeedback,
      'adaptiveIntensity': _adaptiveIntensity,
      'quality': _quality.index,
      'accessibilityMode': _accessibilityMode,
      'accessibilityIntensityMultiplier': _accessibilityIntensityMultiplier,
    };
  }
  
  /// Carrega configurações
  void loadSettings(Map<String, dynamic> settings) {
    _intensity = settings['intensity']?.toDouble() ?? 0.8;
    _isEnabled = settings['isEnabled'] ?? true;
    _contextualFeedback = settings['contextualFeedback'] ?? true;
    _adaptiveIntensity = settings['adaptiveIntensity'] ?? true;
    _accessibilityMode = settings['accessibilityMode'] ?? false;
    _accessibilityIntensityMultiplier = 
        settings['accessibilityIntensityMultiplier']?.toDouble() ?? 1.5;
    
    final qualityIndex = settings['quality'] ?? HapticQuality.medium.index;
    _quality = HapticQuality.values[qualityIndex.clamp(0, HapticQuality.values.length - 1)];
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    stopContinuousFeedback();
    _feedbackHistory.clear();
    _patterns.clear();
    super.dispose();
  }
}

/// Eventos de jogo que podem gerar feedback
enum GameEvent {
  paddleHit,
  wallBounce,
  score,
  gameWin,
  gameLose,
  buttonPress,
  menuNavigation,
  powerUp,
  pause,
  resume,
}

/// Tipos de feedback háptico
enum HapticType {
  impact,
  notification,
  selection,
  success,
  failure,
  custom,
}

/// Qualidade do feedback háptico
enum HapticQuality {
  low,
  medium,
  high,
  ultra,
}

/// Padrão de feedback háptico
class HapticPattern {
  final HapticType type;
  final double intensity;
  final Duration duration;
  final List<int> pattern; // Duração de cada pulso em ms
  
  HapticPattern({
    required this.type,
    required this.intensity,
    required this.duration,
    required this.pattern,
  });
}

/// Evento de feedback registrado
class HapticEvent {
  final GameEvent event;
  final double intensity;
  final DateTime timestamp;
  final Map<String, dynamic> context;
  
  HapticEvent({
    required this.event,
    required this.intensity,
    required this.timestamp,
    required this.context,
  });
}
