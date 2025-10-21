// Dart imports:
import 'dart:math';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'tile.dart';

/// Classe para representar um estado do jogo que pode ser salvo para undo
class GameState {
  final List<List<int>> board;
  final int score;
  final int moveCount;
  final bool hasWon;
  final DateTime timestamp;

  GameState({
    required this.board,
    required this.score,
    required this.moveCount,
    required this.hasWon,
    required this.timestamp,
  });

  /// Cria uma cópia profunda do estado
  GameState copyWith({
    List<List<int>>? board,
    int? score,
    int? moveCount,
    bool? hasWon,
    DateTime? timestamp,
  }) {
    return GameState(
      board: board ?? List.generate(this.board.length, 
        (i) => List.from(this.board[i])),
      score: score ?? this.score,
      moveCount: moveCount ?? this.moveCount,
      hasWon: hasWon ?? this.hasWon,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class GameBoard {
  late List<List<int>> board;
  int score = 0;
  bool gameOver = false;
  bool hasWon = false;
  final BoardSize size;
  List<TilePosition> tilePositions = [];
  List<TilePosition> mergedTiles = [];
  
  // Sistema de undo/redo
  List<GameState> stateHistory = [];
  List<GameState> redoHistory = [];
  static const int maxHistorySize = 10;

  // Propriedades para rastrear movimentos e duração
  int moveCount = 0;
  DateTime? startTime;
  DateTime? endTime;
  
  // Estado de pausa
  bool isPaused = false;
  Duration pausedDuration = Duration.zero;

  GameBoard(this.size) {
    startNewGame();
  }

  void startNewGame() {
    board = List.generate(size.size, (_) => List.filled(size.size, 0));
    score = 0;
    gameOver = false;
    hasWon = false;
    tilePositions = [];
    mergedTiles = [];
    
    // Limpar histórico de undo/redo
    stateHistory.clear();
    redoHistory.clear();

    // Reiniciar contagem de movimentos e tempo
    moveCount = 0;
    startTime = DateTime.now();
    endTime = null;

    addNewTile();
    addNewTile();
    
    // Salvar estado inicial
    _saveCurrentState();
  }

  void addNewTile() {
    List<Point> emptyTiles = [];
    for (int i = 0; i < size.size; i++) {
      for (int j = 0; j < size.size; j++) {
        if (board[i][j] == 0) {
          emptyTiles.add(Point(i, j));
        }
      }
    }

    if (emptyTiles.isEmpty) return;

    Point randomPoint = emptyTiles[Random().nextInt(emptyTiles.length)];
    int value = Random().nextInt(10) < 9 ? 2 : 4;
    board[randomPoint.x.toInt()][randomPoint.y.toInt()] = value;

    tilePositions.add(TilePosition(
      value,
      randomPoint.x.toInt(),
      randomPoint.y.toInt(),
      isNew: true,
    ));
  }

  bool canMove() {
    // Check for empty tiles
    for (int i = 0; i < size.size; i++) {
      for (int j = 0; j < size.size; j++) {
        if (board[i][j] == 0) return true;
      }
    }

    // Check for possible merges
    for (int i = 0; i < size.size; i++) {
      for (int j = 0; j < size.size - 1; j++) {
        if (board[i][j] == board[i][j + 1] || board[j][i] == board[j + 1][i]) {
          return true;
        }
      }
    }

    return false;
  }

  bool checkWin() {
    if (hasWon) return false; // Já ganhou uma vez

    for (int i = 0; i < size.size; i++) {
      for (int j = 0; j < size.size; j++) {
        if (board[i][j] == 2048) {
          hasWon = true;
          // Registrar horário de término ao ganhar
          endTime = DateTime.now();
          return true;
        }
      }
    }
    return false;
  }

  void moveLeft() {
    bool moved = false;
    mergedTiles.clear(); // Limpar tiles mesclados da jogada anterior
    
    for (int i = 0; i < size.size; i++) {
      List<int> row = board[i].where((x) => x != 0).toList();
      List<int> originalRow = List.from(board[i]);
      
      // Processo de merge com detecção
      for (int j = 0; j < row.length - 1; j++) {
        if (row[j] == row[j + 1]) {
          int mergedValue = row[j] * 2;
          row[j] = mergedValue;
          score += mergedValue;
          row.removeAt(j + 1);
          
          // Registrar tile que foi mesclado
          mergedTiles.add(TilePosition(
            mergedValue,
            i,
            j,
            isMerging: true,
          ));
          
          moved = true;
        }
      }
      
      // Preencher com zeros à direita
      row.addAll(List.filled(size.size - row.length, 0));
      
      // Verificar se a linha mudou
      if (originalRow.join() != row.join()) moved = true;
      board[i] = row;
    }
    
    if (moved) {
      _updateTilePositions();
      addNewTile();
    }
  }

  void moveRight() {
    for (int i = 0; i < size.size; i++) {
      board[i] = board[i].reversed.toList();
    }
    moveLeft();
    for (int i = 0; i < size.size; i++) {
      board[i] = board[i].reversed.toList();
    }
  }

  void moveUp() {
    List<List<int>> transposed = List.generate(
        size.size, (i) => List.generate(size.size, (j) => board[j][i]));
    board = transposed;
    moveLeft();
    transposed = List.generate(
        size.size, (i) => List.generate(size.size, (j) => board[j][i]));
    board = transposed;
  }

  void moveDown() {
    List<List<int>> transposed = List.generate(
        size.size, (i) => List.generate(size.size, (j) => board[j][i]));
    board = transposed;
    moveRight();
    transposed = List.generate(
        size.size, (i) => List.generate(size.size, (j) => board[j][i]));
    board = transposed;
  }

  bool move(Direction direction) {
    if (gameOver) return false;

    // Salvar estado atual antes do movimento para permitir undo
    _saveCurrentState();
    
    bool boardChanged = false;
    final oldBoard = List.generate(
        size.size, (i) => List.generate(size.size, (j) => board[i][j]));

    switch (direction) {
      case Direction.left:
        moveLeft();
        break;
      case Direction.right:
        moveRight();
        break;
      case Direction.up:
        moveUp();
        break;
      case Direction.down:
        moveDown();
        break;
    }

    // Check if the board changed
    for (int i = 0; i < size.size; i++) {
      for (int j = 0; j < size.size; j++) {
        if (oldBoard[i][j] != board[i][j]) {
          boardChanged = true;
          break;
        }
      }
      if (boardChanged) break;
    }

    if (boardChanged) {
      // Incrementar contador de movimentos
      moveCount++;
      
      // Limpar histórico de redo já que fizemos um novo movimento
      redoHistory.clear();

      // Verificar vitória primeiro, antes de verificar game over
      checkWin();

      if (!canMove()) {
        gameOver = true;
        // Registrar horário de término ao detectar game over
        endTime = DateTime.now();
      }
      return true;
    } else {
      // Se não houve mudança, remover o estado que salvamos desnecessariamente
      if (stateHistory.isNotEmpty) {
        stateHistory.removeLast();
      }
    }

    return false;
  }

  // Calcula a duração atual do jogo, considerando pausas
  Duration getGameDuration() {
    if (startTime == null) {
      return Duration.zero;
    }

    // Se o jogo terminou, usar o horário de término; caso contrário, usar horário atual
    final now = endTime ?? DateTime.now();
    final totalElapsed = now.difference(startTime!);
    
    // Subtrair tempo pausado da duração total
    return totalElapsed - pausedDuration;
  }
  
  // Pausa o jogo
  void pauseGame() {
    if (!isPaused && !gameOver) {
      isPaused = true;
    }
  }
  
  // Resume o jogo
  void resumeGame(Duration additionalPausedTime) {
    if (isPaused) {
      isPaused = false;
      pausedDuration += additionalPausedTime;
    }
  }

  // Atualiza a lista de posições dos tiles para incluir tiles mesclados
  void _updateTilePositions() {
    // A lista tilePositions já contém os novos tiles
    // Agora vamos adicionar os tiles mesclados à lista completa
    // Isso permite que a UI saiba quais tiles devem mostrar animação de merge
  }

  // Retorna todas as posições dos tiles, incluindo os que sofreram merge
  List<TilePosition> getAllTilePositions() {
    List<TilePosition> allPositions = [];
    
    // Adicionar todos os tiles normais do tabuleiro
    for (int i = 0; i < size.size; i++) {
      for (int j = 0; j < size.size; j++) {
        if (board[i][j] != 0) {
          // Verificar se este tile foi mesclado
          bool isMerged = mergedTiles.any((tile) => 
            tile.row == i && tile.col == j && tile.value == board[i][j]
          );
          
          // Verificar se é um tile novo
          bool isNewTile = tilePositions.any((tile) => 
            tile.row == i && tile.col == j && tile.isNew
          );
          
          allPositions.add(TilePosition(
            board[i][j],
            i,
            j,
            isNew: isNewTile,
            isMerging: isMerged,
          ));
        }
      }
    }
    
    return allPositions;
  }

  // Limpa flags de animação (para ser chamado após animações terminarem)
  void clearAnimationFlags() {
    mergedTiles.clear();
    // Limpar flags isNew dos tiles
    tilePositions = tilePositions.map((tile) => 
      tile.copyWith(isNew: false)
    ).toList();
  }

  // =========================================================================
  // SISTEMA DE UNDO/REDO
  // =========================================================================

  /// Salva o estado atual do jogo no histórico
  void _saveCurrentState() {
    final currentState = GameState(
      board: List.generate(size.size, (i) => List.from(board[i])),
      score: score,
      moveCount: moveCount,
      hasWon: hasWon,
      timestamp: DateTime.now(),
    );

    stateHistory.add(currentState);

    // Manter apenas os últimos N estados para não consumir muita memória
    if (stateHistory.length > maxHistorySize) {
      stateHistory.removeAt(0);
    }
  }

  /// Desfaz o último movimento
  bool undoLastMove() {
    if (!canUndo()) return false;

    // Salvar estado atual no histórico de redo
    final currentState = GameState(
      board: List.generate(size.size, (i) => List.from(board[i])),
      score: score,
      moveCount: moveCount,
      hasWon: hasWon,
      timestamp: DateTime.now(),
    );
    redoHistory.add(currentState);

    // Manter limite do histórico de redo
    if (redoHistory.length > maxHistorySize) {
      redoHistory.removeAt(0);
    }

    // Restaurar estado anterior
    final previousState = stateHistory.removeLast();
    _restoreState(previousState);

    return true;
  }

  /// Refaz o último movimento desfeito
  bool redoLastMove() {
    if (!canRedo()) return false;

    // Salvar estado atual para undo
    _saveCurrentState();

    // Restaurar estado do redo
    final nextState = redoHistory.removeLast();
    _restoreState(nextState);

    return true;
  }

  /// Verifica se é possível desfazer um movimento
  bool canUndo() {
    return stateHistory.isNotEmpty && !gameOver;
  }

  /// Verifica se é possível refazer um movimento
  bool canRedo() {
    return redoHistory.isNotEmpty && !gameOver;
  }

  /// Restaura o estado do jogo a partir de um GameState
  void _restoreState(GameState state) {
    board = List.generate(size.size, (i) => List.from(state.board[i]));
    score = state.score;
    moveCount = state.moveCount;
    hasWon = state.hasWon;
    
    // Resetar flags de jogo
    gameOver = false;
    endTime = null;
    
    // Limpar tiles de animação
    tilePositions.clear();
    mergedTiles.clear();
    
    // Verificar se ainda pode mover após restaurar
    if (!canMove()) {
      gameOver = true;
      endTime = DateTime.now();
    }
  }

  /// Retorna o número de movimentos que podem ser desfeitos
  int getUndoCount() {
    return stateHistory.length;
  }

  /// Retorna o número de movimentos que podem ser refeitos
  int getRedoCount() {
    return redoHistory.length;
  }
}
