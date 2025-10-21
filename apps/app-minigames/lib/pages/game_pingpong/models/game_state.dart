/// Estado principal do jogo Ping Pong
/// 
/// Classe que centraliza todo o estado do jogo, incluindo posições,
/// pontuação, configurações e métricas de performance.
library;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:app_minigames/constants/game_constants.dart';
import 'ball.dart';
import 'paddle.dart';

/// Representa o estado completo do jogo Ping Pong
class PingPongGameState extends ChangeNotifier {
  /// Bola do jogo
  late Ball _ball;
  
  /// Raquete do jogador
  late Paddle _playerPaddle;
  
  /// Raquete da IA
  late Paddle _aiPaddle;
  
  /// Pontuação do jogador
  int _playerScore = 0;
  
  /// Pontuação da IA
  int _aiScore = 0;
  
  /// Estado atual do jogo
  GameState _currentState = GameState.menu;
  
  /// Modo de jogo atual
  GameMode _gameMode = GameMode.singlePlayer;
  
  /// Dificuldade atual
  Difficulty _difficulty = Difficulty.medium;
  
  /// Dimensões da tela
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;
  
  /// Timer do loop do jogo
  Timer? _gameTimer;
  
  /// Tempo de início do jogo
  DateTime? _gameStartTime;
  
  /// Tempo total de jogo
  Duration _gameDuration = Duration.zero;
  
  /// Estatísticas de jogo
  int _totalHits = 0;
  int _maxRally = 0;
  int _currentRally = 0;
  double _maxBallSpeed = 0.0;
  
  /// Indica se o jogo está pausado
  bool _isPaused = false;
  
  /// Cria uma nova instância do estado do jogo
  PingPongGameState() {
    _initializeGame();
  }
  
  /// Inicializa os elementos do jogo
  void _initializeGame() {
    _ball = Ball();
    _playerPaddle = Paddle(
      x: 0, // Será ajustado quando as dimensões da tela forem definidas
      type: PaddleType.player,
    );
    _aiPaddle = Paddle(
      x: 0, // Será ajustado quando as dimensões da tela forem definidas
      type: PaddleType.ai,
    );
  }
  
  /// Getters para acessar o estado
  Ball get ball => _ball;
  Paddle get playerPaddle => _playerPaddle;
  Paddle get aiPaddle => _aiPaddle;
  int get playerScore => _playerScore;
  int get aiScore => _aiScore;
  GameState get currentState => _currentState;
  GameMode get gameMode => _gameMode;
  Difficulty get difficulty => _difficulty;
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  bool get isPaused => _isPaused;
  Duration get gameDuration => _gameDuration;
  int get totalHits => _totalHits;
  int get maxRally => _maxRally;
  int get currentRally => _currentRally;
  double get maxBallSpeed => _maxBallSpeed;
  
  /// Define as dimensões da tela
  void setScreenDimensions(double width, double height) {
    _screenWidth = width;
    _screenHeight = height;
    
    // Ajusta as posições das raquetes
    _playerPaddle = Paddle(
      x: -width / 2 + GameConfig.paddleWidth,
      type: PaddleType.player,
    );
    _aiPaddle = Paddle(
      x: width / 2 - GameConfig.paddleWidth,
      type: PaddleType.ai,
    );
    
    notifyListeners();
  }
  
  /// Inicia um novo jogo
  void startGame() {
    _currentState = GameState.playing;
    _playerScore = 0;
    _aiScore = 0;
    _gameStartTime = DateTime.now();
    _gameDuration = Duration.zero;
    _totalHits = 0;
    _maxRally = 0;
    _currentRally = 0;
    _maxBallSpeed = 0.0;
    _isPaused = false;
    
    _resetRound();
    _startGameLoop();
    
    notifyListeners();
  }
  
  /// Para o jogo
  void stopGame() {
    _gameTimer?.cancel();
    _currentState = GameState.menu;
    _isPaused = false;
    
    _resetRound();
    notifyListeners();
  }
  
  /// Pausa ou despausa o jogo
  void togglePause() {
    if (_currentState != GameState.playing) return;
    
    _isPaused = !_isPaused;
    
    if (_isPaused) {
      _gameTimer?.cancel();
    } else {
      _startGameLoop();
    }
    
    notifyListeners();
  }
  
  /// Reinicia a rodada atual
  void _resetRound() {
    _ball.reset();
    _playerPaddle.reset();
    _aiPaddle.reset();
    _currentRally = 0;
  }
  
  /// Reinicia a rodada atual (método público)
  void resetRound() {
    _resetRound();
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
    if (_isPaused || _currentState != GameState.playing) return;
    
    // Atualiza duração do jogo
    if (_gameStartTime != null) {
      _gameDuration = DateTime.now().difference(_gameStartTime!);
    }
    
    // Atualiza posição da bola
    _ball.updatePosition();
    
    // Verifica colisões com paredes
    if (_ball.checkWallCollision(_screenHeight)) {
      _ball.reverseVertical();
    }
    
    // Atualiza estatísticas
    _updateStatistics();
    
    // Verifica se a bola saiu pelas laterais
    _checkScore();
    
    notifyListeners();
  }
  
  /// Atualiza as estatísticas do jogo
  void _updateStatistics() {
    _maxBallSpeed = _ball.maxSpeed > _maxBallSpeed ? _ball.maxSpeed : _maxBallSpeed;
  }
  
  /// Verifica se alguém marcou ponto
  void _checkScore() {
    if (_ball.isOutLeft(_screenWidth)) {
      _aiScore++;
      _endRally();
      _checkGameEnd();
    } else if (_ball.isOutRight(_screenWidth)) {
      _playerScore++;
      _endRally();
      _checkGameEnd();
    }
  }
  
  /// Finaliza o rally atual
  void _endRally() {
    if (_currentRally > _maxRally) {
      _maxRally = _currentRally;
    }
    _resetRound();
  }
  
  /// Verifica se o jogo terminou
  void _checkGameEnd() {
    if (_playerScore >= GameConfig.maxScore || _aiScore >= GameConfig.maxScore) {
      _gameTimer?.cancel();
      _currentState = GameState.gameOver;
    }
  }
  
  /// Move a raquete do jogador
  void movePlayerPaddle(double deltaY) {
    if (_currentState != GameState.playing || _isPaused) return;
    
    _playerPaddle.move(deltaY, _screenHeight);
    notifyListeners();
  }
  
  /// Atualiza a posição da raquete da IA
  void updateAIPaddle(double newY) {
    if (_currentState != GameState.playing || _isPaused) return;
    
    _aiPaddle.updatePosition(newY, _screenHeight);
    notifyListeners();
  }
  
  /// Registra uma colisão com raquete
  void registerPaddleHit() {
    _totalHits++;
    _currentRally++;
  }
  
  /// Muda o modo de jogo
  void setGameMode(GameMode mode) {
    _gameMode = mode;
    notifyListeners();
  }
  
  /// Muda a dificuldade
  void setDifficulty(Difficulty difficulty) {
    _difficulty = difficulty;
    notifyListeners();
  }
  
  /// Adiciona ponto ao jogador
  void addPlayerScore() {
    _playerScore++;
    notifyListeners();
  }
  
  /// Adiciona ponto à IA
  void addAIScore() {
    _aiScore++;
    notifyListeners();
  }
  
  /// Define o estado do jogo
  void setGameState(GameState state) {
    _currentState = state;
    notifyListeners();
  }
  
  /// Verifica se o jogador venceu
  bool get playerWon => _playerScore >= GameConfig.maxScore;
  
  /// Verifica se a IA venceu
  bool get aiWon => _aiScore >= GameConfig.maxScore;
  
  /// Verifica se o jogo está em andamento
  bool get isPlaying => _currentState == GameState.playing && !_isPaused;
  
  /// Verifica se o jogo terminou
  bool get isGameOver => _currentState == GameState.gameOver;
  
  /// Obtém a porcentagem de vitórias do jogador
  double get winPercentage {
    final totalGames = _playerScore + _aiScore;
    return totalGames > 0 ? _playerScore / totalGames : 0.0;
  }
  
  /// Obtém estatísticas detalhadas do jogo
  Map<String, dynamic> getGameStatistics() {
    return {
      'duration': _gameDuration,
      'totalHits': _totalHits,
      'maxRally': _maxRally,
      'maxBallSpeed': _maxBallSpeed.toStringAsFixed(2),
      'playerScore': _playerScore,
      'aiScore': _aiScore,
      'winPercentage': (winPercentage * 100).toStringAsFixed(1),
    };
  }
  
  /// Salva o estado atual do jogo
  Map<String, dynamic> saveState() {
    return {
      'ball': {
        'x': _ball.x,
        'y': _ball.y,
        'speedX': _ball.speedX,
        'speedY': _ball.speedY,
      },
      'playerPaddle': {
        'y': _playerPaddle.y,
      },
      'aiPaddle': {
        'y': _aiPaddle.y,
      },
      'playerScore': _playerScore,
      'aiScore': _aiScore,
      'gameMode': _gameMode.index,
      'difficulty': _difficulty.index,
      'gameStartTime': _gameStartTime?.millisecondsSinceEpoch,
      'totalHits': _totalHits,
      'maxRally': _maxRally,
      'currentRally': _currentRally,
      'maxBallSpeed': _maxBallSpeed,
    };
  }
  
  /// Carrega um estado salvo do jogo
  void loadState(Map<String, dynamic> state) {
    final ballState = state['ball'] as Map<String, dynamic>;
    _ball.x = ballState['x'];
    _ball.y = ballState['y'];
    _ball.speedX = ballState['speedX'];
    _ball.speedY = ballState['speedY'];
    
    final playerPaddleState = state['playerPaddle'] as Map<String, dynamic>;
    _playerPaddle.y = playerPaddleState['y'];
    
    final aiPaddleState = state['aiPaddle'] as Map<String, dynamic>;
    _aiPaddle.y = aiPaddleState['y'];
    
    _playerScore = state['playerScore'];
    _aiScore = state['aiScore'];
    _gameMode = GameMode.values[state['gameMode']];
    _difficulty = Difficulty.values[state['difficulty']];
    
    final startTimeMs = state['gameStartTime'];
    if (startTimeMs != null) {
      _gameStartTime = DateTime.fromMillisecondsSinceEpoch(startTimeMs);
    }
    
    _totalHits = state['totalHits'];
    _maxRally = state['maxRally'];
    _currentRally = state['currentRally'];
    _maxBallSpeed = state['maxBallSpeed'];
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
