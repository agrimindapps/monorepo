// Dart imports:
import 'dart:math';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/game_constants.dart';
import 'package:app_minigames/services/logger_service.dart';
import 'cell.dart';

/// Core game logic for Minesweeper
class MinefieldLogic {
  GameConfig _config;
  GameState _gameState;
  GameDifficulty _difficulty;
  
  List<List<Cell>> _grid = [];
  int _revealedCells = 0;
  int _flaggedCells = 0;
  int _timeSeconds = 0;
  bool _firstClick = true;
  
  // Statistics
  int _bestTime = 0;
  int _totalGames = 0;
  int _totalWins = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;

  MinefieldLogic({
    GameDifficulty difficulty = GameDifficulty.beginner,
    GameConfig? customConfig,
  }) : _difficulty = difficulty,
       _config = customConfig ?? difficulty.config,
       _gameState = GameState.ready {
    _initializeGrid();
    _loadStatistics();
  }

  // Getters
  GameConfig get config => _config;
  GameState get gameState => _gameState;
  GameDifficulty get difficulty => _difficulty;
  List<List<Cell>> get grid => _grid;
  int get rows => _config.rows;
  int get cols => _config.cols;
  int get totalMines => _config.mines;
  int get revealedCells => _revealedCells;
  int get flaggedCells => _flaggedCells;
  int get remainingMines => _config.mines - _flaggedCells;
  int get timeSeconds => _timeSeconds;
  bool get isFirstClick => _firstClick;
  bool get isGameActive => _gameState == GameState.playing;
  bool get isGameWon => _gameState == GameState.won;
  bool get isGameLost => _gameState == GameState.lost;
  bool get isGameOver => isGameWon || isGameLost;
  
  // Statistics getters
  int get bestTime => _bestTime;
  int get totalGames => _totalGames;
  int get totalWins => _totalWins;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  double get winRate => _totalGames > 0 ? _totalWins / _totalGames : 0.0;

  /// Initializes empty grid
  void _initializeGrid() {
    _grid = List.generate(
      _config.rows,
      (row) => List.generate(
        _config.cols,
        (col) => Cell(row: row, col: col),
      ),
    );
    _revealedCells = 0;
    _flaggedCells = 0;
    _timeSeconds = 0;
    _firstClick = true;
    _gameState = GameState.ready;
  }

  /// Places mines randomly, avoiding the first clicked cell
  void _placeMines(int excludeRow, int excludeCol) {
    final random = Random();
    final excludePositions = _getNeighborPositions(excludeRow, excludeCol);
    excludePositions.add([excludeRow, excludeCol]);
    
    int minesPlaced = 0;
    int attempts = 0;
    final maxAttempts = _config.totalCells * 10;
    
    while (minesPlaced < _config.mines && attempts < maxAttempts) {
      final row = random.nextInt(_config.rows);
      final col = random.nextInt(_config.cols);
      
      attempts++;
      
      // Skip if position should be excluded or already has mine
      if (excludePositions.any((pos) => pos[0] == row && pos[1] == col) ||
          _grid[row][col].isMine) {
        continue;
      }
      
      _grid[row][col].setMine(true);
      minesPlaced++;
    }
    
    if (minesPlaced < _config.mines) {
      LoggerService.warning('Could not place all mines. Placed: $minesPlaced/${_config.mines}');
    }
    
    _calculateNeighborCounts();
  }

  /// Calculates neighbor mine counts for all cells
  void _calculateNeighborCounts() {
    for (int row = 0; row < _config.rows; row++) {
      for (int col = 0; col < _config.cols; col++) {
        if (!_grid[row][col].isMine) {
          final count = _countNeighborMines(row, col);
          _grid[row][col].setNeighborMines(count);
        }
      }
    }
  }

  /// Counts mines in neighboring cells
  int _countNeighborMines(int row, int col) {
    int count = 0;
    final neighbors = _getNeighborPositions(row, col);
    
    for (final pos in neighbors) {
      if (_grid[pos[0]][pos[1]].isMine) {
        count++;
      }
    }
    
    return count;
  }

  /// Gets valid neighbor positions
  List<List<int>> _getNeighborPositions(int row, int col) {
    final neighbors = <List<int>>[];
    
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        
        final newRow = row + dr;
        final newCol = col + dc;
        
        if (_isValidPosition(newRow, newCol)) {
          neighbors.add([newRow, newCol]);
        }
      }
    }
    
    return neighbors;
  }

  /// Checks if position is valid
  bool _isValidPosition(int row, int col) {
    return row >= 0 && row < _config.rows && col >= 0 && col < _config.cols;
  }

  /// Handles cell reveal
  bool revealCell(int row, int col) {
    if (!_isValidPosition(row, col) || isGameOver) {
      return false;
    }
    
    final cell = _grid[row][col];
    
    if (cell.isFlagged || cell.isRevealed) {
      return false;
    }
    
    // First click: place mines and start game
    if (_firstClick) {
      _placeMines(row, col);
      _firstClick = false;
      _gameState = GameState.playing;
    }
    
    if (!cell.reveal()) {
      return false;
    }
    
    _revealedCells++;
    
    // Check if mine was hit
    if (cell.isMine) {
      _gameState = GameState.lost;
      _revealAllMines();
      _updateStatistics(false);
      return true;
    }
    
    // Auto-reveal empty neighbors
    if (cell.isEmpty) {
      _autoRevealNeighbors(row, col);
    }
    
    // Check win condition
    if (_revealedCells >= _config.safeCells) {
      _gameState = GameState.won;
      _autoFlagRemainingMines();
      _updateStatistics(true);
    }
    
    return true;
  }

  /// Reveals empty neighboring cells recursively
  void _autoRevealNeighbors(int row, int col) {
    final neighbors = _getNeighborPositions(row, col);
    
    for (final pos in neighbors) {
      final neighborCell = _grid[pos[0]][pos[1]];
      
      if (!neighborCell.isRevealed && !neighborCell.isFlagged && !neighborCell.isMine) {
        if (neighborCell.reveal()) {
          _revealedCells++;
          
          if (neighborCell.isEmpty) {
            _autoRevealNeighbors(pos[0], pos[1]);
          }
        }
      }
    }
  }

  /// Reveals all mines when game is lost
  void _revealAllMines() {
    for (int row = 0; row < _config.rows; row++) {
      for (int col = 0; col < _config.cols; col++) {
        final cell = _grid[row][col];
        if (cell.isMine && !cell.isRevealed) {
          cell.reveal();
        }
      }
    }
  }

  /// Auto-flags remaining mines when game is won
  void _autoFlagRemainingMines() {
    for (int row = 0; row < _config.rows; row++) {
      for (int col = 0; col < _config.cols; col++) {
        final cell = _grid[row][col];
        if (cell.isMine && !cell.isFlagged) {
          cell.setFlag(true);
          _flaggedCells++;
        }
      }
    }
  }

  /// Toggles flag on cell
  bool toggleFlag(int row, int col) {
    if (!_isValidPosition(row, col) || isGameOver) {
      return false;
    }
    
    final cell = _grid[row][col];
    if (cell.isRevealed) {
      return false;
    }
    
    final wasFlagged = cell.isFlagged;
    cell.toggleFlag();
    
    if (wasFlagged && !cell.isFlagged) {
      _flaggedCells--;
    } else if (!wasFlagged && cell.isFlagged) {
      _flaggedCells++;
    }
    
    return true;
  }

  /// Chord click: reveals neighbors if flag count matches mine count
  bool chordClick(int row, int col) {
    if (!_isValidPosition(row, col) || isGameOver) {
      return false;
    }
    
    final cell = _grid[row][col];
    if (!cell.isRevealed || cell.neighborMines == 0) {
      return false;
    }
    
    final neighbors = _getNeighborPositions(row, col);
    int flaggedNeighbors = 0;
    
    // Count flagged neighbors
    for (final pos in neighbors) {
      if (_grid[pos[0]][pos[1]].isFlagged) {
        flaggedNeighbors++;
      }
    }
    
    // If flagged count matches mine count, reveal unflagged neighbors
    if (flaggedNeighbors == cell.neighborMines) {
      bool revealedAny = false;
      for (final pos in neighbors) {
        final neighbor = _grid[pos[0]][pos[1]];
        if (!neighbor.isRevealed && !neighbor.isFlagged) {
          if (revealCell(pos[0], pos[1])) {
            revealedAny = true;
          }
        }
      }
      return revealedAny;
    }
    
    return false;
  }

  /// Updates game timer
  void updateTimer() {
    if (_gameState == GameState.playing && _timeSeconds < GameLogic.maxTime) {
      _timeSeconds++;
    }
  }

  /// Restarts the game with same configuration
  void restart() {
    _initializeGrid();
    LoggerService.info('Game restarted with ${_difficulty.label} difficulty');
  }

  /// Changes game difficulty and restarts
  void changeDifficulty(GameDifficulty newDifficulty, {GameConfig? customConfig}) {
    _difficulty = newDifficulty;
    _config = customConfig ?? newDifficulty.config;
    _initializeGrid();
    LoggerService.info('Difficulty changed to ${newDifficulty.label}');
  }

  /// Updates game statistics
  void _updateStatistics(bool won) {
    _totalGames++;
    
    if (won) {
      _totalWins++;
      _currentStreak++;
      
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
      }
      
      // Update best time for this difficulty
      if (_bestTime == 0 || _timeSeconds < _bestTime) {
        _bestTime = _timeSeconds;
      }
    } else {
      _currentStreak = 0;
    }
    
    _saveStatistics();
  }

  /// Loads statistics from persistent storage
  Future<void> _loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final bestTimeKey = _getBestTimeKey();
      _bestTime = prefs.getInt(bestTimeKey) ?? 0;
      _totalGames = prefs.getInt(StorageKeys.totalGamesPlayed) ?? 0;
      _totalWins = prefs.getInt(StorageKeys.totalGamesWon) ?? 0;
      _currentStreak = prefs.getInt(StorageKeys.currentStreak) ?? 0;
      _bestStreak = prefs.getInt(StorageKeys.bestStreak) ?? 0;
      
      LoggerService.info('Statistics loaded for ${_difficulty.label}');
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to load statistics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Saves statistics to persistent storage
  Future<void> _saveStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final bestTimeKey = _getBestTimeKey();
      await prefs.setInt(bestTimeKey, _bestTime);
      await prefs.setInt(StorageKeys.totalGamesPlayed, _totalGames);
      await prefs.setInt(StorageKeys.totalGamesWon, _totalWins);
      await prefs.setInt(StorageKeys.currentStreak, _currentStreak);
      await prefs.setInt(StorageKeys.bestStreak, _bestStreak);
      
      LoggerService.info('Statistics saved');
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to save statistics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the storage key for best time based on difficulty
  String _getBestTimeKey() {
    switch (_difficulty) {
      case GameDifficulty.beginner:
        return StorageKeys.beginnerBestTime;
      case GameDifficulty.intermediate:
        return StorageKeys.intermediateBestTime;
      case GameDifficulty.expert:
        return StorageKeys.expertBestTime;
      case GameDifficulty.custom:
        return 'minesweeper_custom_best_time_${_config.rows}x${_config.cols}_${_config.mines}';
    }
  }

  /// Gets cell at position
  Cell? getCellAt(int row, int col) {
    if (!_isValidPosition(row, col)) return null;
    return _grid[row][col];
  }

  /// Formats time as MM:SS
  String get formattedTime {
    final minutes = _timeSeconds ~/ 60;
    final seconds = _timeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats best time as MM:SS
  String get formattedBestTime {
    if (_bestTime == 0) return '--:--';
    final minutes = _bestTime ~/ 60;
    final seconds = _bestTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
