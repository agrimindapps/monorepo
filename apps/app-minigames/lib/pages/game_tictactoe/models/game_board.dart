// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';

class GameBoard {
  // Tabuleiro 3x3 do jogo da velha
  late List<List<Player>> board;

  // Jogador atual
  Player currentPlayer = Player.x;

  // Modo de jogo e dificuldade para IA
  GameMode gameMode = GameMode.vsPlayer;
  Difficulty difficulty = Difficulty.medium;

  // Resultado do jogo
  GameResult result = GameResult.inProgress;

  // Linha vencedora para animação
  List<int>? winningLine;

  // Proteção contra múltiplas execuções da IA
  bool _isProcessingAIMove = false;
  
  // Cache para memoização de jogadas
  static final Map<String, List<int>?> _moveCache = {};
  static int _cacheHits = 0;
  static int _cacheMisses = 0;

  // Construtores
  GameBoard() {
    _initializeBoard();
  }

  // Inicializa o tabuleiro vazio
  void _initializeBoard() {
    board = List.generate(3, (_) => List.filled(3, Player.none));
    currentPlayer = Player.x;
    result = GameResult.inProgress;
    winningLine = null;
  }

  // Reinicia o jogo e reseta flags de segurança
  void restart() {
    _isProcessingAIMove = false;
    _initializeBoard();
    // Limpar cache ocasionalmente para evitar uso excessivo de memória
    if (_moveCache.length > 100) {
      _moveCache.clear();
    }
  }
  
  // Métodos para monitorar performance do cache
  static double get cacheHitRate {
    final total = _cacheHits + _cacheMisses;
    return total > 0 ? _cacheHits / total : 0.0;
  }
  
  // Método para debug (pode ser removido em produção)
  static void printCacheStats() {
    debugPrint('Cache Hit Rate: ${(cacheHitRate * 100).toStringAsFixed(1)}%');
    debugPrint('Cache Size: ${_moveCache.length}');
  }

  // Verifica se uma célula está vazia
  bool isCellEmpty(int row, int col) {
    return board[row][col] == Player.none;
  }

  // Faz uma jogada na célula especificada
  bool makeMove(int row, int col) {
    if (result != GameResult.inProgress || !isCellEmpty(row, col)) {
      return false;
    }

    // Realiza a jogada
    board[row][col] = currentPlayer;

    // Verifica se o jogo terminou
    _checkGameResult();

    // Se o jogo ainda estiver em andamento, muda para o próximo jogador
    if (result == GameResult.inProgress) {
      _nextPlayer();
    }

    return true;
  }

  // Alterna para o próximo jogador
  void _nextPlayer() {
    currentPlayer = currentPlayer.opponent;
  }

  // Verifica se o jogo terminou e atualiza o resultado
  void _checkGameResult() {
    // Verifica linhas, colunas e diagonais para vitória

    // Verifica linhas
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != Player.none &&
          board[i][0] == board[i][1] &&
          board[i][0] == board[i][2]) {
        winningLine = [i * 3, i * 3 + 1, i * 3 + 2];
        result = board[i][0] == Player.x ? GameResult.xWins : GameResult.oWins;
        return;
      }
    }

    // Verifica colunas
    for (int i = 0; i < 3; i++) {
      if (board[0][i] != Player.none &&
          board[0][i] == board[1][i] &&
          board[0][i] == board[2][i]) {
        winningLine = [i, i + 3, i + 6];
        result = board[0][i] == Player.x ? GameResult.xWins : GameResult.oWins;
        return;
      }
    }

    // Verifica diagonal principal
    if (board[0][0] != Player.none &&
        board[0][0] == board[1][1] &&
        board[0][0] == board[2][2]) {
      winningLine = [0, 4, 8];
      result = board[0][0] == Player.x ? GameResult.xWins : GameResult.oWins;
      return;
    }

    // Verifica diagonal secundária
    if (board[0][2] != Player.none &&
        board[0][2] == board[1][1] &&
        board[0][2] == board[2][0]) {
      winningLine = [2, 4, 6];
      result = board[0][2] == Player.x ? GameResult.xWins : GameResult.oWins;
      return;
    }

    // Verifica empate (tabuleiro completo sem vencedor)
    bool isBoardFull = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          isBoardFull = false;
          break;
        }
      }
    }

    if (isBoardFull) {
      result = GameResult.draw;
    }
  }

  // Jogada da IA com proteção contra múltiplas execuções
  void makeAIMove() {
    if (result != GameResult.inProgress || 
        gameMode != GameMode.vsComputer ||
        _isProcessingAIMove) {
      return;
    }

    _isProcessingAIMove = true;

    try {
      // Obtém melhor jogada com base na dificuldade
      final move = _getBestMove();
      if (move != null) {
        makeMove(move[0], move[1]);
      }
    } catch (e) {
      debugPrint('Erro na lógica da IA: $e');
    } finally {
      _isProcessingAIMove = false;
    }
  }

  // Obtém a melhor jogada com base na dificuldade
  List<int>? _getBestMove() {
    switch (difficulty) {
      case Difficulty.easy:
        return _getRandomMove();
      case Difficulty.medium:
        // 50% chance de jogada inteligente, 50% aleatória
        return Random().nextBool() ? _getSmartMove() : _getRandomMove();
      case Difficulty.hard:
        return _getSmartMove();
    }
  }

  // Retorna uma jogada aleatória
  List<int>? _getRandomMove() {
    final availableMoves = <List<int>>[];

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          availableMoves.add([i, j]);
        }
      }
    }

    if (availableMoves.isEmpty) {
      return null;
    }

    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  // Método para gerar chave única do estado do tabuleiro
  String _getBoardStateKey() {
    final buffer = StringBuffer();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        buffer.write(board[i][j].index);
      }
    }
    buffer.write(currentPlayer.index);
    return buffer.toString();
  }
  
  // Versão otimizada do _getSmartMove com memoização
  List<int>? _getSmartMove() {
    final stateKey = _getBoardStateKey();
    
    // Verificar cache primeiro
    if (_moveCache.containsKey(stateKey)) {
      _cacheHits++;
      return _moveCache[stateKey];
    }
    
    _cacheMisses++;
    List<int>? bestMove;
    
    // Primeiro, procura jogada vencedora
    bestMove = _findWinningMove();
    if (bestMove != null) {
      _moveCache[stateKey] = bestMove;
      return bestMove;
    }
    
    // Segundo, bloqueia jogada vencedora do adversário
    bestMove = _findBlockingMove();
    if (bestMove != null) {
      _moveCache[stateKey] = bestMove;
      return bestMove;
    }
    
    // Terceiro, tenta ocupar o centro
    if (board[1][1] == Player.none) {
      bestMove = [1, 1];
      _moveCache[stateKey] = bestMove;
      return bestMove;
    }
    
    // Por último, uma jogada aleatória
    bestMove = _getRandomMove();
    _moveCache[stateKey] = bestMove;
    return bestMove;
  }
  
  List<int>? _findWinningMove() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          board[i][j] = currentPlayer;
          _checkGameResult();

          final hasWon = result != GameResult.inProgress;

          // Desfaz a jogada de teste
          board[i][j] = Player.none;
          result = GameResult.inProgress;
          winningLine = null;

          if (hasWon) {
            return [i, j];
          }
        }
      }
    }
    return null;
  }
  
  List<int>? _findBlockingMove() {
    final opponent = currentPlayer.opponent;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == Player.none) {
          board[i][j] = opponent;
          _checkGameResult();

          final wouldLose = result != GameResult.inProgress;

          // Desfaz a jogada de teste
          board[i][j] = Player.none;
          result = GameResult.inProgress;
          winningLine = null;

          if (wouldLose) {
            return [i, j];
          }
        }
      }
    }
    return null;
  }
}
