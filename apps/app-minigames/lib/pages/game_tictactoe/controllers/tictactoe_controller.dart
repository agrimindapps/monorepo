// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_analytics.dart';
import 'package:app_minigames/models/game_board.dart';
import 'package:app_minigames/services/game_storage_service.dart';

class TicTacToeController extends ChangeNotifier {
  late GameBoard _gameBoard;
  Timer? _aiTimer;
  bool _isDisposed = false;
  
  // Estatísticas de jogo
  int _xWins = 0;
  int _oWins = 0;
  int _draws = 0;
  
  // Análise de jogadas
  final GameAnalytics analytics = GameAnalytics();
  DateTime? _gameStartTime;
  DateTime? _lastMoveTime;
  final List<GameMove> _currentGameMoves = [];
  
  // Getters
  GameBoard get gameBoard => _gameBoard;
  int get xWins => _xWins;
  int get oWins => _oWins;
  int get draws => _draws;
  
  TicTacToeController() {
    _gameBoard = GameBoard();
    _initialize();
  }
  
  Future<void> _initialize() async {
    try {
      // Carregar estatísticas salvas
      final stats = await GameStorageService.loadStats();
      _xWins = stats['xWins']!;
      _oWins = stats['oWins']!;
      _draws = stats['draws']!;
      
      // Carregar configurações
      final settings = await GameStorageService.loadGameSettings();
      _gameBoard.gameMode = settings['gameMode'];
      _gameBoard.difficulty = settings['difficulty'];
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar dados salvos: $e');
    }
  }
  
  void makeMove(int row, int col) {
    if (_isDisposed) return;
    
    final now = DateTime.now();
    final thinkingTime = _lastMoveTime != null 
      ? now.difference(_lastMoveTime!) 
      : Duration.zero;
    
    // Registrar jogada
    _currentGameMoves.add(GameMove(
      row: row,
      col: col,
      player: _gameBoard.currentPlayer,
      timestamp: now,
      thinkingTime: thinkingTime,
    ));
    
    final moveSuccess = _gameBoard.makeMove(row, col);
    
    if (moveSuccess) {
      _lastMoveTime = now;
      
      // Anunciar jogada
      _announceMove(row, col, _gameBoard.currentPlayer.opponent);
      
      notifyListeners();
      
      if (_gameBoard.result != GameResult.inProgress) {
        _endGameAnalysis();
        _announceGameResult();
      } else if (_gameBoard.gameMode == GameMode.vsComputer) {
        _scheduleAIMove();
      }
    }
  }
  
  void _scheduleAIMove() {
    _cancelAITimer();
    
    _aiTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isDisposed) return;
      
      try {
        _gameBoard.makeAIMove();
        if (_gameBoard.result != GameResult.inProgress) {
          _updateGameStats();
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Erro na jogada da IA: $e');
      }
    });
  }
  
  void _cancelAITimer() {
    _aiTimer?.cancel();
    _aiTimer = null;
  }
  
  void _updateGameStats() {
    switch (_gameBoard.result) {
      case GameResult.xWins:
        _xWins++;
        break;
      case GameResult.oWins:
        _oWins++;
        break;
      case GameResult.draw:
        _draws++;
        break;
      default:
        break;
    }
    
    // Salvar estatísticas atualizadas
    GameStorageService.saveStats(_xWins, _oWins, _draws);
    
    // Notifica que o jogo terminou
    notifyListeners();
  }
  
  void restartGame() {
    _cancelAITimer();
    _startNewGame();
    _gameBoard.restart();
    
    // Se o computador começa, faz a primeira jogada
    if (_gameBoard.gameMode == GameMode.vsComputer &&
        _gameBoard.currentPlayer == Player.x) {
      _scheduleAIMove();
    }
    notifyListeners();
  }
  
  void _startNewGame() {
    _gameStartTime = DateTime.now();
    _lastMoveTime = DateTime.now();
    _currentGameMoves.clear();
  }
  
  void _endGameAnalysis() {
    if (_gameStartTime != null) {
      final session = GameSession(
        moves: List.from(_currentGameMoves),
        result: _gameBoard.result,
        mode: _gameBoard.gameMode,
        difficulty: _gameBoard.difficulty,
        startTime: _gameStartTime!,
        endTime: DateTime.now(),
      );
      
      analytics.sessions.add(session);
      _updateGameStats();
    }
  }
  
  void changeGameMode(GameMode mode) {
    _cancelAITimer();
    _gameBoard.gameMode = mode;
    GameStorageService.saveGameSettings(mode, _gameBoard.difficulty);
    restartGame();
  }
  
  void changeDifficulty(Difficulty difficulty) {
    _cancelAITimer();
    _gameBoard.difficulty = difficulty;
    GameStorageService.saveGameSettings(_gameBoard.gameMode, difficulty);
    restartGame();
  }
  
  Future<void> resetAllStats() async {
    await GameStorageService.resetStats();
    _xWins = 0;
    _oWins = 0;
    _draws = 0;
    notifyListeners();
  }
  
  List<String> getGameTips() => analytics.getGameTips();
  
  Map<String, dynamic> getDetailedStats() => {
    'winRate': (analytics.winRate * 100).toStringAsFixed(1),
    'averageGameDuration': '${analytics.averageGameDuration.inSeconds}s',
    'totalGames': analytics.sessions.length,
    'preferredPositions': analytics.preferredPositions,
  };
  
  void _announceMove(int row, int col, Player player) {
    final rowNames = ['primeira linha', 'segunda linha', 'terceira linha'];
    final colNames = ['primeira coluna', 'segunda coluna', 'terceira coluna'];
    final message = '${player.symbol} jogou na ${rowNames[row]}, ${colNames[col]}';
    
    SemanticsService.announce(message, TextDirection.ltr);
  }
  
  void _announceGameResult() {
    String message;
    switch (_gameBoard.result) {
      case GameResult.xWins:
        message = 'X venceu a partida!';
        break;
      case GameResult.oWins:
        message = 'O venceu a partida!';
        break;
      case GameResult.draw:
        message = 'A partida terminou em empate!';
        break;
      default:
        message = '';
    }
    
    if (message.isNotEmpty) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    _cancelAITimer();
    super.dispose();
  }
}
