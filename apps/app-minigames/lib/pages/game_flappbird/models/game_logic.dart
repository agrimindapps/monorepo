// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/services/logger_service.dart';
import 'package:app_minigames/services/object_pool.dart';
import 'bird.dart';
import 'obstacle.dart';
import 'parallax_element.dart';

class FlappyBirdLogic {
  // Configurações
  GameDifficulty difficulty;
  GameState gameState = GameState.ready;

  // Dimensões do jogo
  late double screenWidth;
  late double screenHeight;
  late double groundHeight;

  // Componentes do jogo
  late Bird bird;
  List<Obstacle> obstacles = [];

  // Estado do jogo
  int score = 0;
  int highScore = 0;
  double obstacleSpacing = Spacing.obstacleSpacing;

  // Object pools
  late ObjectPool<Obstacle> _obstaclePool;
  late ObjectPool<ParallaxElement> _parallaxPool;

  // Elementos de parallax
  List<ParallaxElement> clouds = [];
  List<ParallaxElement> bushes = [];
  double cloudSpeed = Parallax.cloudSpeed;
  double bushSpeed = Parallax.bushSpeed;

  FlappyBirdLogic({
    required this.screenWidth,
    required this.screenHeight,
    this.difficulty = GameDifficulty.medium,
  }) {
    groundHeight = screenHeight * Layout.groundHeightRatio;
    
    // Initialize object pools
    _obstaclePool = ObjectPool<Obstacle>(
      createFunction: () => Obstacle(
        x: 0,
        screenHeight: screenHeight - groundHeight,
        gapSize: difficulty.gapSize,
      ),
      maxSize: 10,
    );
    
    _parallaxPool = ObjectPool<ParallaxElement>(
      createFunction: () => ParallaxElement(),
      maxSize: 20,
    );
    
    _initializeGame();
    _loadHighScore();
  }

  void _initializeGame() {
    // Inicializa o pássaro no centro da tela
    bird = Bird(
      x: screenWidth * Layout.birdXPositionRatio,
      y: screenHeight * Layout.birdYPositionRatio,
      size: GameSizes.birdSize,
    );

    // Clear existing elements
    for (var obstacle in obstacles) {
      _obstaclePool.release(obstacle);
    }
    obstacles.clear();
    
    for (var cloud in clouds) {
      _parallaxPool.release(cloud);
    }
    clouds.clear();
    
    for (var bush in bushes) {
      _parallaxPool.release(bush);
    }
    bushes.clear();
    
    score = 0;
    gameState = GameState.ready;

    // Initialize parallax elements
    _initializeParallaxElements();
    
    // Cria os primeiros obstáculos
    _addInitialObstacles();
  }

  void update() {
    updateWithDeltaTime(Physics.defaultDeltaTime); // Default 60fps for backwards compatibility
  }

  void updateWithDeltaTime(double deltaTime) {
    if (gameState != GameState.playing) return;

    // Atualiza o pássaro
    bird.updateWithDeltaTime(deltaTime);

    // Verifica colisão com o chão ou teto
    if (bird.isCollidingWithGround(screenHeight - groundHeight) ||
        bird.isCollidingWithCeiling()) {
      _endGame();
      return;
    }

    // Atualiza obstáculos
    for (int i = obstacles.length - 1; i >= 0; i--) {
      obstacles[i].updateWithDeltaTime(difficulty.gameSpeed, deltaTime);

      // Verifica colisão com obstáculos
      if (obstacles[i].checkCollision(bird.x, bird.y, bird.size)) {
        _endGame();
        return;
      }

      // Verifica se o pássaro passou pelo obstáculo
      if (obstacles[i].checkPassed(bird.x)) {
        score++;
      }

      // Remove obstáculos que saíram da tela
      if (obstacles[i].isOffScreen()) {
        final obstacle = obstacles.removeAt(i);
        _obstaclePool.release(obstacle);
      }
    }

    // Adiciona novos obstáculos se necessário
    _addObstaclesIfNeeded();

    // Atualiza elementos de parallax
    _updateParallaxElementsWithDeltaTime(deltaTime);
  }

  void _addInitialObstacles() {
    // Adiciona dois obstáculos iniciais
    final obstacle1 = _obstaclePool.acquire();
    obstacle1.configure(
      x: screenWidth + Spacing.initialObstacleDistance,
      screenHeight: screenHeight - groundHeight,
      gapSize: difficulty.gapSize,
    );
    obstacles.add(obstacle1);

    final obstacle2 = _obstaclePool.acquire();
    obstacle2.configure(
      x: screenWidth + Spacing.initialObstacleDistance + obstacleSpacing,
      screenHeight: screenHeight - groundHeight,
      gapSize: difficulty.gapSize,
    );
    obstacles.add(obstacle2);
  }

  void _addObstaclesIfNeeded() {
    // Verifica se é necessário adicionar mais obstáculos
    if (obstacles.isNotEmpty) {
      final lastObstacle = obstacles.last;

      if (lastObstacle.x < screenWidth - obstacleSpacing + Spacing.obstacleCreationDistance) {
        final newObstacle = _obstaclePool.acquire();
        newObstacle.configure(
          x: screenWidth + Spacing.newObstacleOffset,
          screenHeight: screenHeight - groundHeight,
          gapSize: difficulty.gapSize,
        );
        obstacles.add(newObstacle);
      }
    } else {
      // Caso não haja obstáculos (improvável, mas para segurança)
      final newObstacle = _obstaclePool.acquire();
      newObstacle.configure(
        x: screenWidth + Spacing.newObstacleOffset,
        screenHeight: screenHeight - groundHeight,
        gapSize: difficulty.gapSize,
      );
      obstacles.add(newObstacle);
    }
  }

  void startGame() {
    if (gameState == GameState.ready) {
      gameState = GameState.playing;
    }
  }

  void jump() {
    if (gameState == GameState.playing) {
      bird.jump();
    } else if (gameState == GameState.gameOver) {
      restartGame();
    } else if (gameState == GameState.ready) {
      startGame();
    }
  }

  void _endGame() {
    gameState = GameState.gameOver;
    _saveHighScore();
  }

  void restartGame() {
    _initializeGame();
    startGame();
  }

  void changeDifficulty(GameDifficulty newDifficulty) {
    difficulty = newDifficulty;
    restartGame();
  }

  void updateScreenDimensions(double width, double height) {
    screenWidth = width;
    screenHeight = height;
    groundHeight = screenHeight * Layout.groundHeightRatio;
    
    bird.x = screenWidth * Layout.birdXPositionRatio;
    bird.y = screenHeight * Layout.birdYPositionRatio;
  }

  Future<void> _loadHighScore() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      highScore = prefs.getInt('flappy_high_score') ?? 0;
      LoggerService.info('High score loaded: $highScore');
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to load high score from SharedPreferences. Using default value (0).',
        error: e,
        stackTrace: stackTrace,
      );
      // Fallback: Use in-memory value (already initialized to 0)
      highScore = 0;
    }
  }

  Future<void> _saveHighScore() async {
    if (score > highScore) {
      highScore = score;
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('flappy_high_score', highScore);
        LoggerService.info('New high score saved: $highScore');
      } catch (e, stackTrace) {
        LoggerService.error(
          'Failed to save high score to SharedPreferences. Score will be lost after app restart.',
          error: e,
          stackTrace: stackTrace,
        );
        // Fallback: Keep the high score in memory for current session
        // but show warning that it won't persist
        LoggerService.warning('High score ($highScore) will only be available for current session');
      }
    }
  }

  void _initializeParallaxElements() {
    // Initialize clouds
    for (int i = 0; i < ParallaxPositions.cloudPositions.length; i++) {
      final cloud = _parallaxPool.acquire();
      cloud.configure(
        x: ParallaxPositions.cloudPositions[i],
        y: Parallax.cloudBaseHeight + (i * Parallax.cloudHeightVariation % Parallax.cloudHeightModulo),
        type: ParallaxType.cloud,
      );
      clouds.add(cloud);
    }

    // Initialize bushes
    for (final position in ParallaxPositions.bushPositions) {
      final bush = _parallaxPool.acquire();
      bush.configure(
        x: position,
        y: groundHeight + Parallax.bushGroundOffset,
        type: ParallaxType.bush,
      );
      bushes.add(bush);
    }
  }


  void _updateParallaxElementsWithDeltaTime(double deltaTime) {
    // Update clouds
    for (int i = clouds.length - 1; i >= 0; i--) {
      clouds[i].updateWithDeltaTime(cloudSpeed * difficulty.gameSpeed, deltaTime);
      if (clouds[i].isOffScreen()) {
        final cloud = clouds.removeAt(i);
        _parallaxPool.release(cloud);
        
        // Add new cloud
        final newCloud = _parallaxPool.acquire();
        newCloud.configure(
          x: Parallax.cloudRespawnX,
          y: Parallax.cloudBaseHeight + (i * Parallax.cloudHeightVariation % Parallax.cloudHeightModulo),
          type: ParallaxType.cloud,
        );
        clouds.add(newCloud);
      }
    }

    // Update bushes
    for (int i = bushes.length - 1; i >= 0; i--) {
      bushes[i].updateWithDeltaTime(bushSpeed * difficulty.gameSpeed, deltaTime);
      if (bushes[i].isOffScreen()) {
        final bush = bushes.removeAt(i);
        _parallaxPool.release(bush);
        
        // Add new bush
        final newBush = _parallaxPool.acquire();
        newBush.configure(
          x: Parallax.bushRespawnX,
          y: groundHeight + Parallax.bushGroundOffset,
          type: ParallaxType.bush,
        );
        bushes.add(newBush);
      }
    }
  }
}
