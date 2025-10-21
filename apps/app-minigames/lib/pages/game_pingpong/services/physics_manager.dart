/// Gerenciador de física que integra o isolate com o jogo
/// 
/// Coordena os cálculos de física no isolate e sincroniza
/// os resultados com o estado principal do jogo.
library;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/models/game_state.dart';
import 'package:app_minigames/models/paddle.dart';
import 'physics_isolate.dart' as isolate;

/// Gerenciador que coordena física entre isolate e jogo principal
class PhysicsManager extends ChangeNotifier {
  /// Serviço de isolate de física
  final isolate.PhysicsIsolateService _isolateService = isolate.PhysicsIsolateService();
  
  /// Estado do jogo
  PingPongGameState? _gameState;
  
  /// Subscription para resultados de física
  StreamSubscription<isolate.PhysicsResult>? _physicsSubscription;
  
  /// Indica se está usando isolate para física
  bool _useIsolate = true;
  
  /// Indica se está inicializado
  bool _isInitialized = false;
  
  /// Buffer de resultados para sincronização
  final List<isolate.PhysicsResult> _resultBuffer = [];
  
  /// Última atualização processada
  int _lastProcessedTimestamp = 0;
  
  /// Estatísticas de performance
  int _framesProcessed = 0;
  int _isolateFrames = 0;
  int _mainThreadFrames = 0;
  double _averageProcessingTime = 0.0;
  
  /// Timer para fallback em caso de falha do isolate
  Timer? _fallbackTimer;
  
  /// Getter para verificar se está inicializado
  bool get isInitialized => _isInitialized;
  
  /// Getter para verificar se está usando isolate
  bool get usingIsolate => _useIsolate && _isolateService.isActive;
  
  /// Getter para estatísticas
  Map<String, dynamic> get performanceStats => {
    'framesProcessed': _framesProcessed,
    'isolateFrames': _isolateFrames,
    'mainThreadFrames': _mainThreadFrames,
    'averageProcessingTime': _averageProcessingTime,
    'usingIsolate': usingIsolate,
    'bufferSize': _resultBuffer.length,
  };
  
  /// Inicializa o gerenciador de física
  Future<void> initialize(PingPongGameState gameState, {bool useIsolate = true}) async {
    if (_isInitialized) return;
    
    _gameState = gameState;
    _useIsolate = useIsolate;
    
    if (_useIsolate) {
      try {
        await _isolateService.initialize();
        
        // Configura listener para resultados
        _physicsSubscription = _isolateService.physicsResults.listen(
          _handlePhysicsResult,
          onError: _handlePhysicsError,
        );
        
        _isInitialized = true;
        debugPrint('PhysicsManager inicializado com isolate');
      } catch (e) {
        debugPrint('Falha ao inicializar isolate, usando thread principal: $e');
        _useIsolate = false;
        _isInitialized = true;
      }
    } else {
      _isInitialized = true;
      debugPrint('PhysicsManager inicializado sem isolate');
    }
    
    notifyListeners();
  }
  
  /// Inicia os cálculos de física
  void startPhysics() {
    if (!_isInitialized || _gameState == null) return;
    
    if (usingIsolate) {
      _startIsolatePhysics();
    } else {
      _startMainThreadPhysics();
    }
  }
  
  /// Para os cálculos de física
  void stopPhysics() {
    if (usingIsolate) {
      _isolateService.stopPhysics();
    } else {
      _fallbackTimer?.cancel();
      _fallbackTimer = null;
    }
    
    _clearBuffer();
  }
  
  /// Pausa os cálculos de física
  void pausePhysics() {
    if (usingIsolate) {
      _isolateService.pausePhysics();
    } else {
      _fallbackTimer?.cancel();
    }
  }
  
  /// Retoma os cálculos de física
  void resumePhysics() {
    if (!_isInitialized) return;
    
    if (usingIsolate) {
      _isolateService.resumePhysics();
    } else {
      _startMainThreadPhysics();
    }
  }
  
  /// Atualiza posição da raquete do jogador
  void updatePlayerPaddle(double newY, double velocity) {
    if (!usingIsolate || _gameState == null) return;
    
    final update = isolate.PaddleUpdate(
      paddleType: PaddleType.player,
      newY: newY,
      velocity: velocity,
    );
    
    _isolateService.updatePaddle(update);
  }
  
  /// Atualiza posição da raquete da IA
  void updateAIPaddle(double newY, double velocity) {
    if (!usingIsolate || _gameState == null) return;
    
    final update = isolate.PaddleUpdate(
      paddleType: PaddleType.ai,
      newY: newY,
      velocity: velocity,
    );
    
    _isolateService.updatePaddle(update);
  }
  
  /// Inicia física no isolate
  void _startIsolatePhysics() {
    if (_gameState == null) return;
    
    final initialState = isolate.PhysicsState(
      ballX: _gameState!.ball.x,
      ballY: _gameState!.ball.y,
      ballSpeedX: _gameState!.ball.speedX,
      ballSpeedY: _gameState!.ball.speedY,
      playerPaddleY: _gameState!.playerPaddle.y,
      aiPaddleY: _gameState!.aiPaddle.y,
      playerPaddleVelocity: _gameState!.playerPaddle.velocity,
      aiPaddleVelocity: _gameState!.aiPaddle.velocity,
      screenWidth: _gameState!.screenWidth,
      screenHeight: _gameState!.screenHeight,
    );
    
    _isolateService.startPhysics(initialState);
  }
  
  /// Inicia física na thread principal (fallback)
  void _startMainThreadPhysics() {
    _fallbackTimer = Timer.periodic(
      const Duration(milliseconds: GameConfig.gameLoopIntervalMs),
      (timer) => _updateMainThreadPhysics(),
    );
  }
  
  /// Atualiza física na thread principal
  void _updateMainThreadPhysics() {
    if (_gameState == null || !_gameState!.isPlaying) return;
    
    final startTime = DateTime.now();
    
    // Atualiza posição da bola
    _gameState!.ball.updatePosition();
    
    // Verifica colisões com paredes
    if (_gameState!.ball.checkWallCollision(_gameState!.screenHeight)) {
      _gameState!.ball.reverseVertical();
    }
    
    // Aqui poderia adicionar mais lógica de física...
    
    _mainThreadFrames++;
    _framesProcessed++;
    
    // Atualiza estatísticas de performance
    final processingTime = DateTime.now().difference(startTime).inMicroseconds / 1000.0;
    _updatePerformanceStats(processingTime);
    
    notifyListeners();
  }
  
  /// Gerencia resultado de física do isolate
  void _handlePhysicsResult(isolate.PhysicsResult result) {
    if (_gameState == null) return;
    
    // Adiciona ao buffer
    _resultBuffer.add(result);
    
    // Processa resultados em ordem
    _processResultBuffer();
    
    _isolateFrames++;
    _framesProcessed++;
    
    notifyListeners();
  }
  
  /// Processa buffer de resultados
  void _processResultBuffer() {
    if (_gameState == null) return;
    
    // Ordena por timestamp
    _resultBuffer.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Processa resultados em ordem
    for (int i = 0; i < _resultBuffer.length; i++) {
      final result = _resultBuffer[i];
      
      // Evita processar resultados antigos
      if (result.timestamp <= _lastProcessedTimestamp) continue;
      
      _applyPhysicsResult(result);
      _lastProcessedTimestamp = result.timestamp;
      
      // Remove resultado processado
      _resultBuffer.removeAt(i);
      i--;
    }
    
    // Limita tamanho do buffer
    if (_resultBuffer.length > 10) {
      _resultBuffer.removeRange(0, _resultBuffer.length - 10);
    }
  }
  
  /// Aplica resultado de física ao estado do jogo
  void _applyPhysicsResult(isolate.PhysicsResult result) {
    if (_gameState == null) return;
    
    // Atualiza posição da bola
    _gameState!.ball.x = result.ballX;
    _gameState!.ball.y = result.ballY;
    _gameState!.ball.speedX = result.ballSpeedX;
    _gameState!.ball.speedY = result.ballSpeedY;
    
    // Gerencia colisões se necessário
    if (result.collisionType != null) {
      _handleCollisionResult(result.collisionType!);
    }
    
    // Gerencia pontuação se necessário
    if (result.scoreResult != null) {
      _handleScoreResult(result.scoreResult!);
    }
  }
  
  /// Gerencia resultado de colisão
  void _handleCollisionResult(isolate.CollisionType collisionType) {
    if (_gameState == null) return;
    
    switch (collisionType) {
      case isolate.CollisionType.paddle:
        _gameState!.registerPaddleHit();
        break;
      case isolate.CollisionType.wall:
        // Colisão com parede já foi tratada no isolate
        break;
      case isolate.CollisionType.score:
        // Pontuação será tratada separadamente
        break;
    }
  }
  
  /// Gerencia resultado de pontuação
  void _handleScoreResult(isolate.ScoreResult scoreResult) {
    if (_gameState == null) return;
    
    switch (scoreResult) {
      case isolate.ScoreResult.playerScored:
        _gameState!.addPlayerScore();
        break;
      case isolate.ScoreResult.aiScored:
        _gameState!.addAIScore();
        break;
    }
    
    // Reinicia rodada
    _gameState!.resetRound();
    
    // Reinicia física se necessário
    if (usingIsolate) {
      _startIsolatePhysics();
    }
  }
  
  /// Gerencia erros de física
  void _handlePhysicsError(error) {
    debugPrint('Erro no isolate de física: $error');
    
    // Fallback para thread principal
    _useIsolate = false;
    _startMainThreadPhysics();
    
    notifyListeners();
  }
  
  /// Atualiza estatísticas de performance
  void _updatePerformanceStats(double processingTime) {
    _averageProcessingTime = (_averageProcessingTime * (_framesProcessed - 1) + processingTime) / _framesProcessed;
  }
  
  /// Limpa buffer de resultados
  void _clearBuffer() {
    _resultBuffer.clear();
    _lastProcessedTimestamp = 0;
  }
  
  /// Reseta estatísticas
  void resetStatistics() {
    _framesProcessed = 0;
    _isolateFrames = 0;
    _mainThreadFrames = 0;
    _averageProcessingTime = 0.0;
    _clearBuffer();
  }
  
  /// Alterna entre isolate e thread principal
  Future<void> togglePhysicsMode() async {
    if (!_isInitialized) return;
    
    final wasPlaying = _gameState?.isPlaying ?? false;
    
    if (wasPlaying) {
      stopPhysics();
    }
    
    _useIsolate = !_useIsolate;
    
    if (_useIsolate && !_isolateService.isActive) {
      try {
        await _isolateService.initialize();
      } catch (e) {
        _useIsolate = false;
        debugPrint('Falha ao reativar isolate: $e');
      }
    }
    
    if (wasPlaying) {
      startPhysics();
    }
    
    notifyListeners();
  }
  
  /// Obtém configuração de física otimizada
  isolate.PhysicsConfig getOptimizedConfig() {
    return isolate.PhysicsConfig(
      gravity: 0.0,
      friction: 0.999,
      bounceFactor: 1.0,
      paddleReflection: 1.05,
      enableAdvancedPhysics: usingIsolate,
    );
  }
  
  @override
  void dispose() {
    stopPhysics();
    _physicsSubscription?.cancel();
    _isolateService.dispose();
    _fallbackTimer?.cancel();
    _clearBuffer();
    _gameState = null;
    super.dispose();
  }
}
