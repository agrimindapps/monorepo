/// Controlador integrado de feedback audiovisual para o jogo Ping Pong
/// 
/// Coordena sistemas de áudio e haptic para fornecer feedback
/// sincronizado e contextual ao jogador.
library;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/models/ball.dart';
import 'package:app_minigames/models/game_state.dart';
import 'package:app_minigames/models/paddle.dart';
import 'package:app_minigames/services/audio_manager.dart';
import 'package:app_minigames/services/haptic_manager.dart';

/// Controlador que integra feedback de áudio e haptic
class FeedbackController extends ChangeNotifier {
  /// Gerenciador de áudio
  final AudioManager _audioManager;
  
  /// Gerenciador de haptic
  final HapticManager _hapticManager;
  
  /// Estado do jogo para contexto
  PingPongGameState? _gameState;
  
  /// Configurações de sincronização
  bool _syncAudioHaptic = true;
  double _hapticDelay = 0.0; // ms de delay para sincronizar
  
  /// Sistema de análise de feedback
  final FeedbackAnalyzer _analyzer = FeedbackAnalyzer();
  
  /// Configurações avançadas
  bool _contextualFeedback = true;
  bool _adaptiveFeedback = true;
  FeedbackProfile _currentProfile = FeedbackProfile.balanced;
  
  /// Estatísticas
  int _totalFeedbacks = 0;
  DateTime? _lastFeedback;
  
  /// Getters
  bool get syncAudioHaptic => _syncAudioHaptic;
  double get hapticDelay => _hapticDelay;
  bool get contextualFeedback => _contextualFeedback;
  bool get adaptiveFeedback => _adaptiveFeedback;
  FeedbackProfile get currentProfile => _currentProfile;
  
  /// Construtor
  FeedbackController({
    required AudioManager audioManager,
    required HapticManager hapticManager,
  }) : _audioManager = audioManager,
       _hapticManager = hapticManager;
  
  /// Inicializa o controlador
  Future<void> initialize(PingPongGameState gameState) async {
    _gameState = gameState;
    
    await _audioManager.initialize();
    await _hapticManager.initialize();
    
    _loadFeedbackProfile(_currentProfile);
    
    debugPrint('FeedbackController inicializado');
    notifyListeners();
  }
  
  /// Feedback para colisão com raquete do jogador
  void onPlayerPaddleHit(Ball ball, Paddle paddle) {
    if (_gameState == null) return;
    
    final context = FeedbackContext(
      ballSpeed: ball.currentSpeed,
      ballPosition: {'x': ball.x, 'y': ball.y},
      paddleVelocity: paddle.velocity,
      impactStrength: _calculateImpactStrength(ball, paddle),
      isPlayer: true,
    );
    
    _executeFeedback(FeedbackEvent.paddleHit, context);
    _analyzer.recordEvent(FeedbackEvent.paddleHit, context);
  }
  
  /// Feedback para colisão com raquete da IA
  void onAIPaddleHit(Ball ball, Paddle paddle) {
    if (_gameState == null) return;
    
    final context = FeedbackContext(
      ballSpeed: ball.currentSpeed,
      ballPosition: {'x': ball.x, 'y': ball.y},
      paddleVelocity: paddle.velocity,
      impactStrength: _calculateImpactStrength(ball, paddle),
      isPlayer: false,
    );
    
    // Feedback reduzido para IA
    _executeFeedback(FeedbackEvent.paddleHit, context, intensityMultiplier: 0.6);
    _analyzer.recordEvent(FeedbackEvent.paddleHit, context);
  }
  
  /// Feedback para colisão com parede
  void onWallHit(Ball ball) {
    if (_gameState == null) return;
    
    final context = FeedbackContext(
      ballSpeed: ball.currentSpeed,
      ballPosition: {'x': ball.x, 'y': ball.y},
      impactStrength: _calculateWallImpactStrength(ball),
    );
    
    _executeFeedback(FeedbackEvent.wallHit, context);
    _analyzer.recordEvent(FeedbackEvent.wallHit, context);
  }
  
  /// Feedback para pontuação
  void onScore(bool playerScored, int playerScore, int aiScore) {
    if (_gameState == null) return;
    
    final context = FeedbackContext(
      playerScored: playerScored,
      currentScore: {'player': playerScore, 'ai': aiScore},
      isGamePoint: playerScore >= 9 || aiScore >= 9,
    );
    
    _executeFeedback(FeedbackEvent.score, context);
    _analyzer.recordEvent(FeedbackEvent.score, context);
  }
  
  /// Feedback para fim de jogo
  void onGameEnd(bool playerWon, int playerScore, int aiScore) {
    if (_gameState == null) return;
    
    final context = FeedbackContext(
      playerWon: playerWon,
      finalScore: {'player': playerScore, 'ai': aiScore},
      gameDuration: _gameState!.gameDuration,
    );
    
    final event = playerWon ? FeedbackEvent.victory : FeedbackEvent.defeat;
    _executeFeedback(event, context);
    _analyzer.recordEvent(event, context);
  }
  
  /// Feedback para início de jogo
  void onGameStart() {
    _executeFeedback(FeedbackEvent.gameStart, FeedbackContext());
  }
  
  /// Feedback para pausa/resume
  void onPauseToggle(bool isPaused) {
    final event = isPaused ? FeedbackEvent.pause : FeedbackEvent.resume;
    _executeFeedback(event, FeedbackContext());
  }
  
  /// Feedback para interação de UI
  void onButtonPress(String buttonId) {
    final context = FeedbackContext(buttonId: buttonId);
    _executeFeedback(FeedbackEvent.buttonPress, context);
  }
  
  /// Feedback para navegação em menu
  void onMenuNavigation(String direction) {
    final context = FeedbackContext(navigationDirection: direction);
    _executeFeedback(FeedbackEvent.menuNavigation, context);
  }
  
  /// Executa feedback coordenado
  void _executeFeedback(
    FeedbackEvent event,
    FeedbackContext context, {
    double intensityMultiplier = 1.0,
  }) {
    if (!_contextualFeedback && !_isBasicEvent(event)) return;
    
    // Aplica análise adaptativa
    final adaptedContext = _adaptiveFeedback ? 
        _analyzer.adaptContext(context) : context;
    
    // Executa áudio
    _executeAudioFeedback(event, adaptedContext, intensityMultiplier);
    
    // Executa haptic com delay opcional
    if (_syncAudioHaptic && _hapticDelay > 0) {
      Timer(Duration(milliseconds: _hapticDelay.round()), () {
        _executeHapticFeedback(event, adaptedContext, intensityMultiplier);
      });
    } else {
      _executeHapticFeedback(event, adaptedContext, intensityMultiplier);
    }
    
    _totalFeedbacks++;
    _lastFeedback = DateTime.now();
    notifyListeners();
  }
  
  /// Executa feedback de áudio
  void _executeAudioFeedback(
    FeedbackEvent event,
    FeedbackContext context,
    double intensityMultiplier,
  ) {
    switch (event) {
      case FeedbackEvent.paddleHit:
        final soundEffect = context.isPlayer == true ? 
            SoundEffect.paddleHit : SoundEffect.paddleHit;
        
        _audioManager.playSound(
          soundEffect,
          volume: (context.impactStrength ?? 0.5) * intensityMultiplier,
          pitch: _calculatePitchFromSpeed(context.ballSpeed ?? 5.0),
          x: context.ballPosition?['x'],
          y: context.ballPosition?['y'],
        );
        break;
        
      case FeedbackEvent.wallHit:
        _audioManager.playSound(
          SoundEffect.wallHit,
          volume: (context.impactStrength ?? 0.5) * intensityMultiplier,
          pitch: _calculatePitchFromSpeed(context.ballSpeed ?? 5.0),
          x: context.ballPosition?['x'],
          y: context.ballPosition?['y'],
        );
        break;
        
      case FeedbackEvent.score:
        _audioManager.playScoreSound(
          context.playerScored ?? false,
          context.currentScore?['player'] ?? 0,
        );
        break;
        
      case FeedbackEvent.victory:
      case FeedbackEvent.defeat:
        _audioManager.playSound(
          SoundEffect.gameEnd,
          volume: 0.8 * intensityMultiplier,
          pitch: event == FeedbackEvent.victory ? 1.2 : 0.8,
        );
        break;
        
      case FeedbackEvent.gameStart:
        _audioManager.playSound(SoundEffect.gameStart);
        break;
        
      case FeedbackEvent.buttonPress:
      case FeedbackEvent.menuNavigation:
        _audioManager.playSound(SoundEffect.buttonClick);
        break;
        
      default:
        break;
    }
  }
  
  /// Executa feedback háptico
  void _executeHapticFeedback(
    FeedbackEvent event,
    FeedbackContext context,
    double intensityMultiplier,
  ) {
    switch (event) {
      case FeedbackEvent.paddleHit:
        _hapticManager.triggerPaddleHit(
          context.impactStrength ?? 0.5,
          context.ballSpeed ?? 5.0,
          context.isPlayer ?? true,
        );
        break;
        
      case FeedbackEvent.wallHit:
        _hapticManager.triggerWallBounce(
          context.ballSpeed ?? 5.0,
          0.0, // ângulo simplificado
        );
        break;
        
      case FeedbackEvent.score:
      case FeedbackEvent.victory:
      case FeedbackEvent.defeat:
        _hapticManager.triggerScore(
          context.playerScored ?? false,
          context.currentScore?['player'] ?? 0,
          10, // pontuação máxima
        );
        break;
        
      case FeedbackEvent.gameStart:
        _hapticManager.triggerFeedback(GameEvent.buttonPress);
        break;
        
      case FeedbackEvent.pause:
      case FeedbackEvent.resume:
        _hapticManager.triggerFeedback(GameEvent.pause);
        break;
        
      case FeedbackEvent.buttonPress:
        _hapticManager.triggerFeedback(GameEvent.buttonPress);
        break;
        
      case FeedbackEvent.menuNavigation:
        _hapticManager.triggerFeedback(GameEvent.menuNavigation);
        break;
    }
  }
  
  /// Calcula força do impacto entre bola e raquete
  double _calculateImpactStrength(Ball ball, Paddle paddle) {
    final speedFactor = (ball.currentSpeed / 10.0).clamp(0.0, 1.0);
    final velocityFactor = (paddle.velocity.abs() / 5.0).clamp(0.0, 1.0);
    
    return ((speedFactor + velocityFactor) / 2.0).clamp(0.3, 1.0);
  }
  
  /// Calcula força do impacto com parede
  double _calculateWallImpactStrength(Ball ball) {
    return (ball.currentSpeed / 15.0).clamp(0.2, 0.8);
  }
  
  /// Calcula pitch baseado na velocidade
  double _calculatePitchFromSpeed(double speed) {
    return 0.8 + (speed / 20.0).clamp(0.0, 0.6);
  }
  
  /// Verifica se é evento básico (sempre executado)
  bool _isBasicEvent(FeedbackEvent event) {
    return [
      FeedbackEvent.buttonPress,
      FeedbackEvent.menuNavigation,
      FeedbackEvent.gameStart,
    ].contains(event);
  }
  
  /// Carrega perfil de feedback
  void _loadFeedbackProfile(FeedbackProfile profile) {
    switch (profile) {
      case FeedbackProfile.minimal:
        _audioManager.setSoundEffectsVolume(0.3);
        _hapticManager.setIntensity(0.3);
        _contextualFeedback = false;
        break;
        
      case FeedbackProfile.balanced:
        _audioManager.setSoundEffectsVolume(0.7);
        _hapticManager.setIntensity(0.7);
        _contextualFeedback = true;
        break;
        
      case FeedbackProfile.intense:
        _audioManager.setSoundEffectsVolume(1.0);
        _hapticManager.setIntensity(1.0);
        _contextualFeedback = true;
        break;
        
      case FeedbackProfile.accessibility:
        _audioManager.setSoundEffectsVolume(0.8);
        _hapticManager.setIntensity(1.0);
        _hapticManager.setAccessibilityMode(true);
        _contextualFeedback = true;
        break;
    }
  }
  
  /// Configurações
  void setProfile(FeedbackProfile profile) {
    _currentProfile = profile;
    _loadFeedbackProfile(profile);
    notifyListeners();
  }
  
  void setSyncAudioHaptic(bool sync) {
    _syncAudioHaptic = sync;
    notifyListeners();
  }
  
  void setHapticDelay(double delay) {
    _hapticDelay = delay.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setContextualFeedback(bool enabled) {
    _contextualFeedback = enabled;
    notifyListeners();
  }
  
  void setAdaptiveFeedback(bool enabled) {
    _adaptiveFeedback = enabled;
    notifyListeners();
  }
  
  /// Obtém estatísticas
  Map<String, dynamic> getStatistics() {
    return {
      'totalFeedbacks': _totalFeedbacks,
      'lastFeedback': _lastFeedback?.millisecondsSinceEpoch,
      'currentProfile': _currentProfile.toString(),
      'audioStats': _audioManager.getAudioStatistics(),
      'hapticStats': _hapticManager.getStatistics(),
      'analyzerStats': _analyzer.getStatistics(),
    };
  }
  
  /// Salva configurações
  Map<String, dynamic> saveSettings() {
    return {
      'profile': _currentProfile.index,
      'syncAudioHaptic': _syncAudioHaptic,
      'hapticDelay': _hapticDelay,
      'contextualFeedback': _contextualFeedback,
      'adaptiveFeedback': _adaptiveFeedback,
      'audioSettings': _audioManager.saveSettings(),
      'hapticSettings': _hapticManager.saveSettings(),
    };
  }
  
  /// Carrega configurações
  void loadSettings(Map<String, dynamic> settings) {
    final profileIndex = settings['profile'] ?? FeedbackProfile.balanced.index;
    _currentProfile = FeedbackProfile.values[profileIndex.clamp(0, FeedbackProfile.values.length - 1)];
    
    _syncAudioHaptic = settings['syncAudioHaptic'] ?? true;
    _hapticDelay = settings['hapticDelay']?.toDouble() ?? 0.0;
    _contextualFeedback = settings['contextualFeedback'] ?? true;
    _adaptiveFeedback = settings['adaptiveFeedback'] ?? true;
    
    if (settings.containsKey('audioSettings')) {
      _audioManager.loadSettings(settings['audioSettings']);
    }
    
    if (settings.containsKey('hapticSettings')) {
      _hapticManager.loadSettings(settings['hapticSettings']);
    }
    
    _loadFeedbackProfile(_currentProfile);
    notifyListeners();
  }
  
  @override
  void dispose() {
    _audioManager.dispose();
    _hapticManager.dispose();
    super.dispose();
  }
}

/// Eventos de feedback
enum FeedbackEvent {
  paddleHit,
  wallHit,
  score,
  victory,
  defeat,
  gameStart,
  pause,
  resume,
  buttonPress,
  menuNavigation,
}

/// Perfis de feedback predefinidos
enum FeedbackProfile {
  minimal,
  balanced,
  intense,
  accessibility,
}

/// Contexto para feedback
class FeedbackContext {
  final double? ballSpeed;
  final Map<String, double>? ballPosition;
  final double? paddleVelocity;
  final double? impactStrength;
  final bool? isPlayer;
  final bool? playerScored;
  final Map<String, int>? currentScore;
  final Map<String, int>? finalScore;
  final bool? isGamePoint;
  final bool? playerWon;
  final Duration? gameDuration;
  final String? buttonId;
  final String? navigationDirection;
  
  FeedbackContext({
    this.ballSpeed,
    this.ballPosition,
    this.paddleVelocity,
    this.impactStrength,
    this.isPlayer,
    this.playerScored,
    this.currentScore,
    this.finalScore,
    this.isGamePoint,
    this.playerWon,
    this.gameDuration,
    this.buttonId,
    this.navigationDirection,
  });
  
  FeedbackContext copyWith({
    double? ballSpeed,
    Map<String, double>? ballPosition,
    double? paddleVelocity,
    double? impactStrength,
    bool? isPlayer,
    bool? playerScored,
    Map<String, int>? currentScore,
    Map<String, int>? finalScore,
    bool? isGamePoint,
    bool? playerWon,
    Duration? gameDuration,
    String? buttonId,
    String? navigationDirection,
  }) {
    return FeedbackContext(
      ballSpeed: ballSpeed ?? this.ballSpeed,
      ballPosition: ballPosition ?? this.ballPosition,
      paddleVelocity: paddleVelocity ?? this.paddleVelocity,
      impactStrength: impactStrength ?? this.impactStrength,
      isPlayer: isPlayer ?? this.isPlayer,
      playerScored: playerScored ?? this.playerScored,
      currentScore: currentScore ?? this.currentScore,
      finalScore: finalScore ?? this.finalScore,
      isGamePoint: isGamePoint ?? this.isGamePoint,
      playerWon: playerWon ?? this.playerWon,
      gameDuration: gameDuration ?? this.gameDuration,
      buttonId: buttonId ?? this.buttonId,
      navigationDirection: navigationDirection ?? this.navigationDirection,
    );
  }
}

/// Analisador de feedback para adaptação
class FeedbackAnalyzer {
  final List<FeedbackRecord> _records = [];
  int _totalEvents = 0;
  
  void recordEvent(FeedbackEvent event, FeedbackContext context) {
    _records.add(FeedbackRecord(
      event: event,
      context: context,
      timestamp: DateTime.now(),
    ));
    
    _totalEvents++;
    
    // Limita histórico
    if (_records.length > 100) {
      _records.removeAt(0);
    }
  }
  
  FeedbackContext adaptContext(FeedbackContext context) {
    // Análise simples: reduz intensidade se muitos eventos recentes
    final recentEvents = _records.where((record) => 
        DateTime.now().difference(record.timestamp).inSeconds < 5).length;
    
    if (recentEvents > 10) {
      // Muitos eventos recentes, reduz intensidade
      return context.copyWith(
        impactStrength: (context.impactStrength ?? 0.5) * 0.7,
      );
    }
    
    return context;
  }
  
  Map<String, dynamic> getStatistics() {
    final eventCounts = <String, int>{};
    for (final record in _records) {
      final eventName = record.event.toString();
      eventCounts[eventName] = (eventCounts[eventName] ?? 0) + 1;
    }
    
    return {
      'totalEvents': _totalEvents,
      'recentRecords': _records.length,
      'eventCounts': eventCounts,
    };
  }
}

/// Registro de evento de feedback
class FeedbackRecord {
  final FeedbackEvent event;
  final FeedbackContext context;
  final DateTime timestamp;
  
  FeedbackRecord({
    required this.event,
    required this.context,
    required this.timestamp,
  });
}
