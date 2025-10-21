/// Controlador de Inteligência Artificial para o jogo Ping Pong
/// 
/// Gerencia o comportamento da IA, incluindo diferentes níveis de dificuldade
/// e sistema de dificuldade adaptativa.
library;

// Dart imports:
import 'dart:math';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/models/ball.dart';
import 'package:app_minigames/models/game_state.dart';
import 'package:app_minigames/models/paddle.dart';
import 'package:app_minigames/services/adaptive_difficulty.dart';

/// Controlador responsável pela lógica da IA
class AIController {
  /// Estado do jogo
  PingPongGameState? _gameState;
  
  /// Configuração atual de dificuldade
  Difficulty _currentDifficulty = Difficulty.medium;
  
  /// Velocidade de reação atual da IA
  double _reactionSpeed = AIConfig.mediumReactionSpeed;
  
  /// Fator de predição atual
  double _predictionFactor = AIConfig.aiPredictionFactor;
  
  /// Gerador de números aleatórios
  final Random _random = Random();
  
  /// Estatísticas para dificuldade adaptativa
  int _consecutivePlayerWins = 0;
  int _consecutiveAIWins = 0;
  
  /// Sistema de dificuldade adaptativa
  AdaptiveDifficultyManager? _adaptiveDifficulty;
  
  /// Última posição Y da bola para calcular predição
  double _lastBallY = 0.0;
  
  /// Tempo da última atualização
  DateTime? _lastUpdateTime;
  
  /// Posição alvo atual da IA
  double _targetY = 0.0;
  
  /// Inicializa o controlador de IA
  void initialize(PingPongGameState gameState, {AdaptiveDifficultyManager? adaptiveDifficulty}) {
    _gameState = gameState;
    _currentDifficulty = gameState.difficulty;
    _adaptiveDifficulty = adaptiveDifficulty;
    _updateDifficultySettings();
    _lastUpdateTime = DateTime.now();
    
    // Ativa sistema adaptativo se necessário
    if (_currentDifficulty == Difficulty.adaptive && _adaptiveDifficulty != null) {
      _adaptiveDifficulty!.activate();
    }
  }
  
  /// Atualiza a dificuldade da IA
  void updateDifficulty(Difficulty difficulty) {
    _currentDifficulty = difficulty;
    _updateDifficultySettings();
    
    // Gerencia sistema adaptativo
    if (_adaptiveDifficulty != null) {
      if (difficulty == Difficulty.adaptive) {
        _adaptiveDifficulty!.activate();
      } else {
        _adaptiveDifficulty!.deactivate();
      }
    }
  }
  
  /// Atualiza as configurações baseadas na dificuldade
  void _updateDifficultySettings() {
    switch (_currentDifficulty) {
      case Difficulty.easy:
        _reactionSpeed = AIConfig.easyReactionSpeed;
        _predictionFactor = 0.3;
        break;
      case Difficulty.medium:
        _reactionSpeed = AIConfig.mediumReactionSpeed;
        _predictionFactor = 0.5;
        break;
      case Difficulty.hard:
        _reactionSpeed = AIConfig.hardReactionSpeed;
        _predictionFactor = 0.7;
        break;
      case Difficulty.adaptive:
        _reactionSpeed = AIConfig.adaptiveReactionSpeed;
        _predictionFactor = 0.5;
        break;
    }
    
    // Se tem sistema adaptativo ativo, usa configurações dele
    if (_currentDifficulty == Difficulty.adaptive && _adaptiveDifficulty?.isActive == true) {
      _reactionSpeed = _adaptiveDifficulty!.currentSettings.aiReactionSpeed;
      _predictionFactor = _adaptiveDifficulty!.currentSettings.predictionFactor;
    }
  }
  
  /// Atualiza o comportamento da IA
  void updateAI() {
    final gameState = _gameState;
    if (gameState == null || !gameState.isPlaying) return;
    
    final ball = gameState.ball;
    final aiPaddle = gameState.aiPaddle;
    
    // Atualiza a posição alvo
    _updateTargetPosition(ball);
    
    // Move a IA em direção ao alvo
    _moveToTarget(aiPaddle, gameState.screenHeight);
    
    // Atualiza estatísticas
    _updateStatistics(ball);
    
    _lastUpdateTime = DateTime.now();
  }
  
  /// Calcula a posição alvo da IA
  void _updateTargetPosition(Ball ball) {
    // Posição base: posição atual da bola
    _targetY = ball.y;
    
    // Adiciona predição baseada na velocidade da bola
    if (ball.isMovingRight) {
      // Calcula onde a bola estará quando chegar à raquete da IA
      final timeToReach = _calculateTimeToReach(ball);
      _targetY += ball.speedY * timeToReach * _predictionFactor;
    }
    
    // Adiciona um fator de randomização baseado na dificuldade
    final randomFactor = _calculateRandomFactor();
    _targetY += randomFactor;
    
    // Aplica estratégia baseada na dificuldade
    _applyDifficultyStrategy(ball);
  }
  
  /// Calcula o tempo estimado para a bola chegar à raquete da IA
  double _calculateTimeToReach(Ball ball) {
    final gameState = _gameState;
    if (gameState == null) return 0.0;
    
    final distanceToAI = (gameState.screenWidth / 2 - GameConfig.paddleWidth) - ball.x;
    
    if (ball.speedX <= 0) return 0.0;
    
    return distanceToAI / ball.speedX;
  }
  
  /// Calcula um fator de randomização baseado na dificuldade
  double _calculateRandomFactor() {
    final maxRandom = switch (_currentDifficulty) {
      Difficulty.easy => 30.0,
      Difficulty.medium => 15.0,
      Difficulty.hard => 5.0,
      Difficulty.adaptive => 10.0,
    };
    
    return (_random.nextDouble() - 0.5) * maxRandom;
  }
  
  /// Aplica estratégias específicas baseadas na dificuldade
  void _applyDifficultyStrategy(Ball ball) {
    switch (_currentDifficulty) {
      case Difficulty.easy:
        _applyEasyStrategy(ball);
        break;
      case Difficulty.medium:
        _applyMediumStrategy(ball);
        break;
      case Difficulty.hard:
        _applyHardStrategy(ball);
        break;
      case Difficulty.adaptive:
        _applyAdaptiveStrategy(ball);
        break;
    }
  }
  
  /// Estratégia para dificuldade fácil
  void _applyEasyStrategy(Ball ball) {
    // Reage mais lentamente e com menos precisão
    const reactionDelay = 0.1;
    _targetY += (ball.y - _lastBallY) * reactionDelay;
    
    // Ocasionalmente "perde" a bola propositalmente
    if (_random.nextDouble() < 0.1) {
      _targetY += (_random.nextDouble() - 0.5) * 100;
    }
  }
  
  /// Estratégia para dificuldade média
  void _applyMediumStrategy(Ball ball) {
    // Comportamento balanceado
    const reactionDelay = 0.05;
    _targetY += (ball.y - _lastBallY) * reactionDelay;
  }
  
  /// Estratégia para dificuldade difícil
  void _applyHardStrategy(Ball ball) {
    // Reação mais rápida e precisa
    final gameState = _gameState;
    if (gameState == null) return;
    
    // Tenta interceptar a bola no ponto ótimo
    final optimalY = _calculateOptimalInterceptionPoint(ball);
    _targetY = optimalY;
    
    // Adiciona antecipação para rebatidas mais agressivas
    if (ball.isMovingRight && ball.currentSpeed > 6.0) {
      _targetY += ball.speedY * 0.3;
    }
  }
  
  /// Estratégia para dificuldade adaptativa
  void _applyAdaptiveStrategy(Ball ball) {
    // Ajusta a estratégia baseada no desempenho recente
    if (_consecutivePlayerWins > 2) {
      // Facilita o jogo
      _applyEasyStrategy(ball);
      _reactionSpeed = AIConfig.easyReactionSpeed * 0.8;
    } else if (_consecutiveAIWins > 2) {
      // Dificulta o jogo
      _applyMediumStrategy(ball);
      _reactionSpeed = AIConfig.mediumReactionSpeed * 1.2;
    } else {
      // Comportamento normal
      _applyMediumStrategy(ball);
      _reactionSpeed = AIConfig.adaptiveReactionSpeed;
    }
  }
  
  /// Calcula o ponto ótimo de interceptação
  double _calculateOptimalInterceptionPoint(Ball ball) {
    final gameState = _gameState;
    if (gameState == null) return ball.y;
    
    // Simula a trajetória da bola
    final simulatedBall = ball.copy();
    const steps = 50;
    
    for (int i = 0; i < steps; i++) {
      simulatedBall.updatePosition();
      
      // Verifica colisão com paredes
      if (simulatedBall.checkWallCollision(gameState.screenHeight)) {
        simulatedBall.reverseVertical();
      }
      
      // Se chegou próximo da raquete da IA
      if (simulatedBall.x >= gameState.screenWidth / 2 - GameConfig.paddleWidth * 2) {
        return simulatedBall.y;
      }
    }
    
    return ball.y;
  }
  
  /// Move a IA em direção ao alvo
  void _moveToTarget(Paddle aiPaddle, double screenHeight) {
    final difference = _targetY - aiPaddle.y;
    final movement = difference * _reactionSpeed;
    
    // Aplica suavização para movimento mais natural
    final smoothedMovement = _applySmoothening(movement);
    
    // Atualiza a posição da raquete
    aiPaddle.updatePosition(aiPaddle.y + smoothedMovement, screenHeight);
  }
  
  /// Aplica suavização ao movimento da IA
  double _applySmoothening(double movement) {
    // Limita a velocidade máxima de movimento
    final maxMovement = switch (_currentDifficulty) {
      Difficulty.easy => 3.0,
      Difficulty.medium => 5.0,
      Difficulty.hard => 8.0,
      Difficulty.adaptive => 6.0,
    };
    
    return movement.clamp(-maxMovement, maxMovement);
  }
  
  /// Atualiza estatísticas para análise
  void _updateStatistics(Ball ball) {
    _lastBallY = ball.y;
  }
  
  /// Ajusta a dificuldade adaptativa baseada no resultado
  void adjustAdaptiveDifficulty(dynamic scoreResult) {
    if (_currentDifficulty != Difficulty.adaptive) return;
    
    // Registra no sistema adaptativo se disponível
    if (_adaptiveDifficulty?.isActive == true) {
      if (scoreResult.toString().contains('playerScored')) {
        _adaptiveDifficulty!.registerPlayerScore();
      } else if (scoreResult.toString().contains('aiScored')) {
        _adaptiveDifficulty!.registerAIScore();
      }
      
      // Atualiza configurações baseadas no sistema adaptativo
      _updateDifficultySettings();
    } else {
      // Fallback para sistema antigo
      if (scoreResult.toString().contains('playerScored')) {
        _consecutivePlayerWins++;
        _consecutiveAIWins = 0;
      } else if (scoreResult.toString().contains('aiScored')) {
        _consecutiveAIWins++;
        _consecutivePlayerWins = 0;
      }
      
      // Ajusta parâmetros baseado nas estatísticas
      _adjustAdaptiveParameters();
    }
  }
  
  /// Registra hit do jogador para análise adaptativa
  void registerPlayerHit(double ballSpeed, double accuracy) {
    if (_currentDifficulty == Difficulty.adaptive && _adaptiveDifficulty?.isActive == true) {
      _adaptiveDifficulty!.registerPlayerHit(ballSpeed, accuracy);
    }
  }
  
  /// Registra tempo de reação do jogador
  void registerPlayerReactionTime(Duration reactionTime) {
    if (_currentDifficulty == Difficulty.adaptive && _adaptiveDifficulty?.isActive == true) {
      _adaptiveDifficulty!.registerReactionTime(reactionTime);
    }
  }
  
  /// Ajusta parâmetros para dificuldade adaptativa
  void _adjustAdaptiveParameters() {
    if (_consecutivePlayerWins >= 3) {
      // Jogador está ganhando muito, facilita
      _reactionSpeed = AIConfig.adaptiveReactionSpeed * 0.7;
      _predictionFactor = 0.3;
    } else if (_consecutiveAIWins >= 3) {
      // IA está ganhando muito, dificulta
      _reactionSpeed = AIConfig.adaptiveReactionSpeed * 1.3;
      _predictionFactor = 0.7;
    } else {
      // Equilibra os parâmetros
      _reactionSpeed = AIConfig.adaptiveReactionSpeed;
      _predictionFactor = 0.5;
    }
  }
  
  /// Reseta o estado da IA
  void resetAI() {
    _consecutivePlayerWins = 0;
    _consecutiveAIWins = 0;
    _lastBallY = 0.0;
    _targetY = 0.0;
    _lastUpdateTime = DateTime.now();
    _updateDifficultySettings();
  }
  
  /// Obtém estatísticas da IA
  Map<String, dynamic> getAIStatistics() {
    return {
      'currentDifficulty': _currentDifficulty.toString(),
      'reactionSpeed': _reactionSpeed.toStringAsFixed(3),
      'predictionFactor': _predictionFactor.toStringAsFixed(2),
      'consecutivePlayerWins': _consecutivePlayerWins,
      'consecutiveAIWins': _consecutiveAIWins,
      'targetY': _targetY.toStringAsFixed(2),
    };
  }
  
  /// Verifica se a IA deve tentar fazer um movimento especial
  bool shouldAttemptSpecialMove(Ball ball) {
    // Apenas em dificuldade difícil ou adaptativa
    if (_currentDifficulty != Difficulty.hard && 
        _currentDifficulty != Difficulty.adaptive) {
      return false;
    }
    
    // Probabilidade baseada na velocidade da bola
    final probability = (ball.currentSpeed / GameConfig.maxBallSpeed) * 0.3;
    return _random.nextDouble() < probability;
  }
  
  /// Libera recursos
  void dispose() {
    _gameState = null;
  }
}
