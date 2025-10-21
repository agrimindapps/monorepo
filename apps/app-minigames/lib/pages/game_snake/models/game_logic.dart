// Dart imports:
import 'dart:async';
import 'dart:math';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/services/snake_persistence_service.dart';
import 'food.dart';
import 'game_statistics.dart';
import 'position.dart';

/**
 * ✅ FIXED: Posição da cobra não sai mais dos limites com operação módulo segura
 * 
 * BUG (prioridade: ALTA): Timer não inicializado mas declarado como late 
 * pode causar crash
 * 
 * ✅ FIXED: Geração de comida agora usa algoritmo determinístico para evitar loop infinito
 * 
 * FIXME (prioridade: MÉDIA): SharedPreferences chamado de forma síncrona 
 * pode causar travamento
 * 
 * TODO (prioridade: ALTA): Implementar sistema de power-ups (crescimento 
 * duplo, velocidade temporária, etc)
 * 
 * TODO (prioridade: ALTA): Adicionar múltiplos tipos de comida com 
 * pontuações diferentes
 * 
 * TODO (prioridade: MÉDIA): Implementar obstáculos no grid
 * 
 * TODO (prioridade: MÉDIA): Adicionar modo multiplayer local
 * 
 * TODO (prioridade: BAIXA): Salvar estatísticas detalhadas (tempo jogado, 
 * comidas consumidas, etc)
 * 
 * ✅ FIXED: Lógica de persistência separada em SnakePersistenceService dedicado
 * 
 * ✅ FIXED: Enum GameState criado para gerenciar estados do jogo de forma centralizada
 * 
 * REFACTOR (prioridade: MÉDIA): Criar classes para diferentes tipos de 
 * comida e power-ups
 * 
 * REFACTOR (prioridade: BAIXA): Usar padrão State para gerenciar estados 
 * do jogo
 * 
 * ✅ OPTIMIZED: Set implementado para verificação de posições da cobra O(1) vs O(n)
 * 
 * OPTIMIZE (prioridade: BAIXA): Cachear cálculos de posições válidas para 
 * comida
 * 
 * SECURITY (prioridade: BAIXA): Validar dados salvos no SharedPreferences 
 * contra tampering
 * 
 * TEST (prioridade: ALTA): Adicionar testes para todos os métodos públicos
 * 
 * TEST (prioridade: MÉDIA): Adicionar testes de integração com 
 * SharedPreferences
 */

class SnakeGameLogic {
  // Configuração do jogo
  final int gridSize;
  GameDifficulty difficulty;
  final SnakePersistenceService _persistenceService;

  // Estado do jogo
  late List<Position> snake;
  late Set<Position> _snakePositions; // Set para verificações O(1)
  late Food food;
  late Direction direction;
  late Timer timer;
  
  // Efeitos temporários
  Timer? _speedEffectTimer;
  bool _hasSpeedEffect = false;
  
  // Estatísticas da sessão atual
  DateTime? _gameStartTime;
  final Map<String, int> _currentSessionFoodStats = {};
  GameStatistics _currentStatistics = GameStatistics.empty();

  // Variáveis de controle
  int score = 0;
  int highScore = 0;
  GameState gameState = GameState.notStarted;

  // Construtor
  SnakeGameLogic({
    this.gridSize = 20,
    this.difficulty = GameDifficulty.medium,
    SnakePersistenceService? persistenceService,
  }) : _persistenceService = persistenceService ?? SharedPreferencesSnakePersistenceService();

  // Dispose para limpar recursos
  void dispose() {
    _speedEffectTimer?.cancel();
  }
  
  // Carrega estatísticas do jogo
  Future<void> loadStatistics() async {
    _currentStatistics = await _persistenceService.getDetailedGameStatistics();
  }

  // Inicializa o jogo
  void initializeGame() {
    // Posição inicial da cobra no centro da tela
    final initialPosition = Position(gridSize ~/ 2, gridSize ~/ 2);
    snake = [initialPosition];
    _snakePositions = {initialPosition}; // Inicializa Set sincronizado

    direction = Direction.right;
    generateFood();
    gameState = GameState.notStarted;
    score = 0;
  }

  // Gera uma nova comida evitando loop infinito (otimizado com Set)
  void generateFood() {
    final random = Random();

    // Calcula todas as posições livres do grid usando Set para verificação O(1)
    final availablePositions = <Position>[];
    
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final position = Position(x, y);
        // Verifica se a posição não está ocupada pela cobra usando Set O(1)
        if (!_snakePositions.contains(position)) {
          availablePositions.add(position);
        }
      }
    }

    // Verifica se há posições disponíveis (condição de vitória)
    if (availablePositions.isEmpty) {
      // Jogo completado - cobra ocupou todo o grid!
      gameState = GameState.gameOver;
      return;
    }

    // Seleciona aleatoriamente uma posição da lista de disponíveis
    final randomIndex = random.nextInt(availablePositions.length);
    final selectedPosition = availablePositions[randomIndex];
    
    // Cria uma comida com tipo aleatório
    food = Food.random(selectedPosition);
  }

  // Move a cobra na direção atual (otimizado com Set)
  void moveSnake() {
    if (!gameState.isPlayable) return;

    // Pega a cabeça atual da cobra
    final head = snake.first;

    // Usa o método getNewPosition para calcular a nova posição da cabeça
    Position newHead = head.getNewPosition(direction, gridSize);

    // Verificação de colisão com o próprio corpo usando Set O(1)
    if (_snakePositions.contains(newHead)) {
      gameState = GameState.gameOver;
      return;
    }

    // Adiciona nova cabeça à cobra e ao Set
    snake.insert(0, newHead);
    _snakePositions.add(newHead);

    // Verifica se comeu a comida
    if (newHead == food.position) {
      // Aplica efeito da comida
      _applyFoodEffect(food);
      
      // Aumenta pontuação baseada no tipo da comida
      score += food.points;
      
      // Gera nova comida
      generateFood();
    } else {
      // Remove a cauda se não comeu (mantém Set sincronizado)
      final removedTail = snake.removeLast();
      _snakePositions.remove(removedTail);
    }
  }

  // Muda a direção da cobra
  bool changeDirection(Direction newDirection) {
    // Evita que a cobra vá na direção oposta
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return false;
    }

    direction = newDirection;
    return true;
  }

  // Inicia o jogo
  void startGame() {
    if (!gameState.canStart) return;
    gameState = GameState.running;
    
    // Inicia rastreamento de estatísticas
    _gameStartTime = DateTime.now();
    _currentSessionFoodStats.clear();
  }

  // Reinicia o jogo
  void restartGame() {
    initializeGame();
  }

  // Pausa/despausa o jogo
  void togglePause() {
    if (gameState.canPause) {
      gameState = GameState.paused;
    } else if (gameState.canResume) {
      gameState = GameState.running;
    }
  }

  // Carrega o recorde
  Future<void> loadHighScore() async {
    highScore = await _persistenceService.getHighScore();
  }

  // Carrega configurações do usuário
  Future<void> loadUserSettings() async {
    difficulty = await _persistenceService.getPreferredDifficulty();
  }

  // Salva configurações do usuário
  Future<void> saveUserSettings() async {
    await _persistenceService.savePreferredDifficulty(difficulty);
  }

  // Salva o recorde se for maior que o atual
  Future<void> saveHighScore() async {
    if (score > highScore) {
      await _persistenceService.saveHighScore(score);
      highScore = score;
    }
  }

  // Salva estatísticas da partida atual
  Future<void> saveGameStatistics() async {
    if (_gameStartTime == null) return;
    
    final gameDuration = DateTime.now().difference(_gameStartTime!).inSeconds;
    final totalFoodConsumed = _currentSessionFoodStats.values.fold(0, (a, b) => a + b);
    
    // Atualiza estatísticas globais
    _currentStatistics = _currentStatistics.updateAfterGame(
      gameScore: score,
      gameDurationSeconds: gameDuration,
      foodConsumed: totalFoodConsumed,
      snakeLength: snake.length,
      foodTypesConsumed: _currentSessionFoodStats,
    );
    
    // Salva no persistence service
    await _persistenceService.saveDetailedGameStatistics(_currentStatistics);
  }

  // Verifica se uma posição contém a comida
  bool isFood(int x, int y) {
    return food.position == Position(x, y);
  }

  // Verifica se uma posição contém parte da cobra (otimizado com Set O(1))
  bool isSnake(int x, int y) {
    return _snakePositions.contains(Position(x, y));
  }

  // Verifica se uma posição é a cabeça da cobra
  bool isSnakeHead(int x, int y) {
    return snake.isNotEmpty && snake.first == Position(x, y);
  }

  // Aplica efeito da comida consumida
  void _applyFoodEffect(Food consumedFood) {
    // Atualiza estatísticas de tipos de comida
    final foodTypeName = consumedFood.type.label;
    _currentSessionFoodStats[foodTypeName] = 
        (_currentSessionFoodStats[foodTypeName] ?? 0) + 1;
    
    switch (consumedFood.type) {
      case FoodType.normal:
        // Nenhum efeito especial
        break;
      case FoodType.golden:
        // Efeito já aplicado no score (2 pontos)
        break;
      case FoodType.speed:
        _applySpeedEffect();
        break;
      case FoodType.shrink:
        _applyShrinkEffect();
        break;
    }
  }

  // Aplica efeito de velocidade temporário
  void _applySpeedEffect() {
    // Cancela efeito anterior se existir
    _speedEffectTimer?.cancel();
    
    _hasSpeedEffect = true;
    
    // Notifica mudança de velocidade
    onGameSpeedChanged?.call();
    
    // Remove efeito após duração
    _speedEffectTimer = Timer(FoodType.speed.effectDuration, () {
      _hasSpeedEffect = false;
      onGameSpeedChanged?.call();
    });
  }

  // Aplica efeito de encolhimento (remove segmento da cauda)
  void _applyShrinkEffect() {
    // Só aplica se a cobra tem mais de 1 segmento
    if (snake.length > 1) {
      final removedTail = snake.removeLast();
      _snakePositions.remove(removedTail);
    }
  }
  
  // Métodos para debug e validação de integridade dos dados
  
  /// Verifica se o Set de posições está sincronizado com a List
  bool _isDataIntegrityValid() {
    // Verifica se o tamanho é o mesmo
    if (snake.length != _snakePositions.length) return false;
    
    // Verifica se todas as posições da List estão no Set
    for (final position in snake) {
      if (!_snakePositions.contains(position)) return false;
    }
    
    return true;
  }
  
  
  /// Carrega configurações do jogo
  Future<void> loadGameSettings() async {
    difficulty = await _persistenceService.getPreferredDifficulty();
  }
  
  /// Salva configurações do jogo
  Future<void> saveGameSettings() async {
    await _persistenceService.savePreferredDifficulty(difficulty);
  }
  
  /// Incrementa estatísticas do jogo
  Future<void> updateGameStatistics() async {
    final stats = await _persistenceService.getGameStatistics();
    
    // Incrementa jogos jogados
    stats['totalGamesPlayed'] = (stats['totalGamesPlayed'] as int) + 1;
    
    // Incrementa comida consumida
    stats['totalFoodEaten'] = (stats['totalFoodEaten'] as int) + score;
    
    // Atualiza melhor score se necessário
    final currentBest = stats['bestScore'] as int;
    if (score > currentBest) {
      stats['bestScore'] = score;
    }
    
    // Calcula score médio
    final totalGames = stats['totalGamesPlayed'] as int;
    final totalFood = stats['totalFoodEaten'] as int;
    stats['averageScore'] = totalGames > 0 ? (totalFood / totalGames).toDouble() : 0.0;
    
    await _persistenceService.saveGameStatistics(stats);
  }
  
  /// Retorna estatísticas de performance
  Map<String, dynamic> getPerformanceStats() {
    return {
      'snakeLength': snake.length,
      'setSize': _snakePositions.length,
      'dataIntegrityValid': _isDataIntegrityValid(),
      'gridSize': gridSize,
      'score': score,
      'gameState': gameState.name,
    };
  }
  
  // Getters para compatibilidade com código existente
  bool get isGameOver => gameState == GameState.gameOver;
  bool get isGameStarted => gameState == GameState.running;
  bool get isPaused => gameState == GameState.paused;
  
  // Getter para velocidade atual considerando efeitos
  Duration get currentGameSpeed {
    if (_hasSpeedEffect) {
      // Acelera o jogo em 50%
      return Duration(milliseconds: (difficulty.gameSpeed.inMilliseconds * 0.5).round());
    }
    return difficulty.gameSpeed;
  }
  
  // Getter para tipo da comida atual
  FoodType get currentFoodType => food.type;
  
  // Getter para estatísticas atuais
  GameStatistics get currentStatistics => _currentStatistics;
  
  /// Callback para notificar mudanças que requerem atualização de timer
  Function()? onGameSpeedChanged;
  
  /// Atualiza a dificuldade e notifica sobre mudança de velocidade
  void updateDifficulty(GameDifficulty newDifficulty) {
    if (difficulty != newDifficulty) {
      difficulty = newDifficulty;
      
      // Salva a nova configuração
      saveUserSettings();
      
      // Notifica que a velocidade do jogo mudou
      onGameSpeedChanged?.call();
    }
  }
}
