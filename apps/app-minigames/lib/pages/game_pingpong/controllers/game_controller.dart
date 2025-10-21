/// Controlador principal do jogo Ping Pong
/// 
/// Centraliza a lógica de controle do jogo, coordenando as interações
/// entre os modelos, controllers e a interface do usuário.
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
import 'ai_controller.dart';
import 'collision_controller.dart' as collision;

/// Controlador principal que gerencia o loop do jogo e coordena todos os componentes
class GameController extends ChangeNotifier {
  /// Estado atual do jogo
  final PingPongGameState _gameState;
  
  /// Controlador de IA
  final AIController _aiController;
  
  /// Controlador de colisões
  final collision.CollisionController _collisionController;
  
  /// Timer para o loop principal do jogo
  Timer? _gameTimer;
  
  /// Indica se o controlador foi inicializado
  bool _isInitialized = false;
  
  /// Cria uma nova instância do controlador do jogo
  GameController({
    required PingPongGameState gameState,
    AIController? aiController,
    collision.CollisionController? collisionController,
  }) : _gameState = gameState,
       _aiController = aiController ?? AIController(),
       _collisionController = collisionController ?? collision.CollisionController();
  
  /// Getter para o estado do jogo
  PingPongGameState get gameState => _gameState;
  
  /// Getter para verificar se está inicializado
  bool get isInitialized => _isInitialized;
  
  /// Inicializa o controlador do jogo
  void initialize(double screenWidth, double screenHeight) {
    if (_isInitialized) return;
    
    _gameState.setScreenDimensions(screenWidth, screenHeight);
    _aiController.initialize(_gameState);
    _collisionController.initialize(_gameState);
    
    _isInitialized = true;
    notifyListeners();
  }
  
  /// Inicia um novo jogo
  void startGame() {
    if (!_isInitialized) {
      throw StateError('GameController deve ser inicializado antes de iniciar o jogo');
    }
    
    _gameState.startGame();
    _aiController.resetAI();
    _startGameLoop();
    
    notifyListeners();
  }
  
  /// Para o jogo atual
  void stopGame() {
    _gameTimer?.cancel();
    _gameState.stopGame();
    
    notifyListeners();
  }
  
  /// Pausa ou despausa o jogo
  void togglePause() {
    if (_gameState.currentState != GameState.playing) return;
    
    _gameState.togglePause();
    
    if (_gameState.isPaused) {
      _gameTimer?.cancel();
    } else {
      _startGameLoop();
    }
    
    notifyListeners();
  }
  
  /// Move a raquete do jogador
  void movePlayerPaddle(double deltaY) {
    _gameState.movePlayerPaddle(deltaY);
    notifyListeners();
  }
  
  /// Atualiza a posição da raquete do jogador
  void updatePlayerPaddle(double newY) {
    _gameState.playerPaddle.updatePosition(newY, _gameState.screenHeight);
    notifyListeners();
  }
  
  /// Altera o modo de jogo
  void setGameMode(GameMode mode) {
    _gameState.setGameMode(mode);
    _aiController.updateDifficulty(_gameState.difficulty);
    notifyListeners();
  }
  
  /// Altera a dificuldade do jogo
  void setDifficulty(Difficulty difficulty) {
    _gameState.setDifficulty(difficulty);
    _aiController.updateDifficulty(difficulty);
    notifyListeners();
  }
  
  /// Inicia o loop principal do jogo
  void _startGameLoop() {
    _gameTimer = Timer.periodic(
      const Duration(milliseconds: GameConfig.gameLoopIntervalMs),
      (timer) => _updateGame(),
    );
  }
  
  /// Atualiza o estado do jogo a cada frame
  void _updateGame() {
    if (_gameState.isPaused || _gameState.currentState != GameState.playing) {
      return;
    }
    
    // Atualiza a IA
    _aiController.updateAI();
    
    // Atualiza a posição da bola
    _gameState.ball.updatePosition();
    
    // Verifica colisões
    _handleCollisions();
    
    // Verifica se o jogo terminou
    _checkGameEnd();
    
    notifyListeners();
  }
  
  /// Gerencia todas as colisões do jogo
  void _handleCollisions() {
    final ball = _gameState.ball;
    final playerPaddle = _gameState.playerPaddle;
    final aiPaddle = _gameState.aiPaddle;
    
    // Verifica colisão com paredes
    if (_collisionController.checkWallCollision(ball, _gameState.screenHeight)) {
      ball.reverseVertical();
    }
    
    // Verifica colisão com raquete do jogador
    if (_collisionController.checkPaddleCollision(ball, playerPaddle)) {
      _handlePaddleCollision(ball, playerPaddle);
    }
    
    // Verifica colisão com raquete da IA
    if (_collisionController.checkPaddleCollision(ball, aiPaddle)) {
      _handlePaddleCollision(ball, aiPaddle);
    }
    
    // Verifica se a bola saiu pela lateral
    final scoreResult = _collisionController.checkScoreCollision(ball, _gameState.screenWidth);
    if (scoreResult != null) {
      _handleScore(scoreResult);
    }
  }
  
  /// Lida com a colisão entre a bola e uma raquete
  void _handlePaddleCollision(Ball ball, Paddle paddle) {
    // Registra o hit para estatísticas
    _gameState.registerPaddleHit();
    
    // Calcula o impacto relativo
    final relativeImpact = paddle.getRelativeImpactPosition(ball.y);
    
    // Obtém a zona de impacto
    final impactZone = paddle.getImpactZone(ball.y);
    
    // Aplica efeitos baseados na zona de impacto
    ball.reverseHorizontal();
    ball.adjustAngle(relativeImpact * impactZone.angleEffect);
    
    // Aplica boost de velocidade se necessário
    if (impactZone.speedBoost > 1.0) {
      ball.speedX *= impactZone.speedBoost;
      ball.speedY *= impactZone.speedBoost;
    }
    
    // Adiciona efeito da velocidade da raquete
    if (!paddle.isStationary) {
      ball.speedY += paddle.velocity * 0.1;
    }
  }
  
  /// Lida com a pontuação
  void _handleScore(collision.ScoreResult scoreResult) {
    if (scoreResult == collision.ScoreResult.playerScored) {
      _gameState.addPlayerScore();
    } else if (scoreResult == collision.ScoreResult.aiScored) {
      _gameState.addAIScore();
    }
    
    // Reinicia a rodada
    _gameState.resetRound();
    
    // Atualiza a dificuldade adaptativa se necessário
    if (_gameState.difficulty == Difficulty.adaptive) {
      _aiController.adjustAdaptiveDifficulty(scoreResult);
    }
  }
  
  /// Verifica se o jogo terminou
  void _checkGameEnd() {
    if (_gameState.playerScore >= GameConfig.maxScore || 
        _gameState.aiScore >= GameConfig.maxScore) {
      _gameTimer?.cancel();
      _gameState.setGameState(GameState.gameOver);
    }
  }
  
  /// Reinicia o jogo atual
  void restartGame() {
    stopGame();
    startGame();
  }
  
  /// Obtém estatísticas detalhadas do jogo
  Map<String, dynamic> getGameStatistics() {
    return _gameState.getGameStatistics();
  }
  
  /// Salva o estado atual do jogo
  Map<String, dynamic> saveGameState() {
    return _gameState.saveState();
  }
  
  /// Carrega um estado salvo do jogo
  void loadGameState(Map<String, dynamic> state) {
    _gameState.loadState(state);
    
    // Reinicia o timer se o jogo estava rodando
    if (_gameState.isPlaying) {
      _startGameLoop();
    }
    
    notifyListeners();
  }
  
  /// Verifica se o jogo pode ser pausado
  bool canPause() {
    return _gameState.currentState == GameState.playing;
  }
  
  /// Verifica se o jogo pode ser iniciado
  bool canStart() {
    return _isInitialized && 
           (_gameState.currentState == GameState.menu || 
            _gameState.currentState == GameState.gameOver);
  }
  
  /// Obtém informações sobre o vencedor
  String? getWinnerInfo() {
    if (!_gameState.isGameOver) return null;
    
    if (_gameState.playerWon) {
      return 'Jogador venceu! ${_gameState.playerScore} x ${_gameState.aiScore}';
    } else if (_gameState.aiWon) {
      return 'IA venceu! ${_gameState.aiScore} x ${_gameState.playerScore}';
    }
    
    return null;
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    _gameState.dispose();
    _aiController.dispose();
    _collisionController.dispose();
    super.dispose();
  }
}

