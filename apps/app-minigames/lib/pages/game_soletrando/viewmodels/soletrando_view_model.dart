// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import '../l10n/soletrando_strings.dart';
import 'package:app_minigames/models/soletrando_game.dart';
import 'package:app_minigames/services/storage_service.dart';
import 'package:app_minigames/services/timer_service.dart';

/// ViewModel para o jogo Soletrando seguindo padrão MVVM
/// Encapsula toda a lógica de negócio e gerenciamento de estado
class SoletrandoViewModel extends ChangeNotifier {
  // Dependências injetadas
  late final SoletrandoGame _game;
  late final TimerService _timerService;
  late final StorageService _storageService;

  // Estado do jogo
  Difficulty _difficulty = Difficulty.normal;
  int _timeRemaining = 0;
  int _hintCount = 0;
  bool _showHint = false;

  // Estado da UI
  final Map<String, Color> _letterColors = {};
  bool _enableAnimations = true;
  bool _enableSounds = true;
  final Map<WordCategory, int> _categoryProgress = {};

  // Estado de carregamento e erros
  bool _isLoading = false;
  String? _error;

  // Estado de pause/lifecycle
  bool _isPaused = false;
  bool _wasRunningBeforePause = false;

  // Autosave e telemetria
  Timer? _autoSaveTimer;
  final List<String> _errorLogs = [];
  DateTime? _lastStateChange;

  // Construtor com injeção de dependências
  SoletrandoViewModel({
    SoletrandoGame? game,
    TimerService? timerService,
    StorageService? storageService,
  }) {
    _game = game ?? SoletrandoGame();
    _timerService = timerService ?? TimerService();
    _storageService = storageService ?? StorageService.instance;
    _initializeGame();
    _startAutoSave();
  }

  // Getters públicos para a UI
  SoletrandoGame get game => _game;
  Difficulty get difficulty => _difficulty;
  int get timeRemaining => _timeRemaining;
  int get hintCount => _hintCount;
  bool get showHint => _showHint;
  Map<String, Color> get letterColors => Map.unmodifiable(_letterColors);
  bool get enableAnimations => _enableAnimations;
  bool get enableSounds => _enableSounds;
  Map<WordCategory, int> get categoryProgress =>
      Map.unmodifiable(_categoryProgress);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPaused => _isPaused;

  // Getters derivados
  bool get hasError => _error != null;
  bool get isGameActive =>
      !_game.isGameOver() && _timeRemaining > 0 && !_isPaused;
  bool get isCriticalTime => _timeRemaining <= 10 && !_isPaused;
  bool get canUseHint => _hintCount > 0 && isGameActive;

  // Inicialização do jogo
  void _initializeGame() {
    _resetGameSettings();
    _startTimer();
  }

  void _resetGameSettings() {
    _timeRemaining = _difficulty.timeInSeconds;
    _hintCount = _difficulty.hints;
    _showHint = false;
    _letterColors.clear();
    _isPaused = false;
    _wasRunningBeforePause = false;
    _clearError();
  }

  // Gerenciamento de timer
  void _startTimer() {
    _timerService.start(
      durationInSeconds: _difficulty.timeInSeconds,
      onTick: _onTimerTick,
      onExpired: _onTimerExpired,
      onCriticalTime: _onCriticalTime,
      onHalfTime: _onHalfTime,
    );
    _timeRemaining = _difficulty.timeInSeconds;
    notifyListeners();
  }

  void _onTimerTick() {
    _timeRemaining = _timerService.remainingTime;
    notifyListeners();
  }

  void _onTimerExpired() {
    _game.timeOut();
    if (_game.result == GameResult.failure) {
      _onGameOver(false);
    } else {
      _onTimeOut();
    }
  }

  void _onCriticalTime() {
    if (_enableAnimations) {
      // Implementar feedback visual para tempo crítico
      debugPrint('Critical time reached!');
    }
  }

  void _onHalfTime() {
    if (_enableSounds) {
      // Implementar feedback sonoro para metade do tempo
      debugPrint('Half time reached!');
    }
  }

  // Controle de pause/resume do jogo
  void pauseGame() {
    if (!isGameActive || _isPaused) return;

    _wasRunningBeforePause = _timerService.isRunning;
    if (_wasRunningBeforePause) {
      _timerService.pause();
    }

    _isPaused = true;
    notifyListeners();
  }

  void resumeGame() {
    if (!_isPaused) return;

    if (_wasRunningBeforePause && !_game.isGameOver()) {
      _timerService.resume();
    }

    _isPaused = false;
    _wasRunningBeforePause = false;
    notifyListeners();
  }

  // Ações do jogo
  Future<void> checkLetter(String letter) async {
    if (!isGameActive || _isPaused) return;

    try {
      // Feedback tátil
      if (_enableSounds) {
        HapticFeedback.selectionClick();
      }

      final found = _game.checkLetter(letter);

      // Feedback visual
      _letterColors[letter] =
          found ? const Color(0xFF10B981) : const Color(0xFFEF4444);

      // Penalidade de tempo para erros
      if (!found) {
        _timerService.removeTime(5);
        _timeRemaining = _timerService.remainingTime;
      }

      // Verifica resultado do jogo
      if (_game.result == GameResult.success) {
        _onWordCompleted();
      } else if (_game.result == GameResult.failure) {
        _onGameOver(false);
      }

      // Remove feedback visual após delay
      Future.delayed(const Duration(milliseconds: 300), () {
        _letterColors[letter] = const Color(0xFF6B7280); // Grey
        notifyListeners();
      });

      notifyListeners();
    } catch (e) {
      _logError('Erro ao verificar letra: $e');
      _setError('Erro ao verificar letra: $e');
    }
  }

  void _onWordCompleted() {
    _timerService.stop();

    // Cálculo de pontuação com bônus de tempo
    final timeBonus = _timeRemaining * 2;
    _game.score += (10 + timeBonus) * _difficulty.scoreMultiplier;

    // Atualiza progresso da categoria
    _updateCategoryProgress(_game.currentCategory);

    // Salva progresso imediatamente
    _saveGameProgress();

    _onGameOver(true);
  }

  void _updateCategoryProgress(WordCategory category) {
    _categoryProgress[category] = (_categoryProgress[category] ?? 0) + 1;
  }

  void useHint() {
    if (!canUseHint || _isPaused) return;

    _showHint = true;
    _hintCount--;
    notifyListeners();
  }

  // Controle do jogo
  Future<void> startNewGame() async {
    try {
      _setLoading(true);
      _timerService.stop();

      _game.startNewGame();
      _resetGameSettings();
      _startTimer();

      // Salva novo estado do jogo
      await _saveGameProgress();
    } catch (e, stackTrace) {
      _logError('Erro ao iniciar novo jogo: $e', stackTrace);
      _setError('Erro ao iniciar novo jogo: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changeCategory(WordCategory category) async {
    try {
      _setLoading(true);
      _timerService.stop();

      _game.changeCategory(category);
      _resetGameSettings();
      _startTimer();

      // Salva nova categoria
      await _saveGameProgress();
    } catch (e, stackTrace) {
      _logError('Erro ao mudar categoria: $e', stackTrace);
      _setError('Erro ao mudar categoria: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changeDifficulty(Difficulty newDifficulty) async {
    try {
      _setLoading(true);
      _difficulty = newDifficulty;
      _resetGameSettings();
      _startTimer();
      notifyListeners();
    } catch (e, stackTrace) {
      _logError('Erro ao mudar dificuldade: $e', stackTrace);
      _setError('Erro ao mudar dificuldade: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetProgress() async {
    try {
      _setLoading(true);
      _game.score = 0;
      _categoryProgress.clear();
      notifyListeners();
    } catch (e, stackTrace) {
      _logError('Erro ao resetar progresso: $e', stackTrace);
      _setError('Erro ao resetar progresso: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Configurações
  void toggleAnimations() {
    _enableAnimations = !_enableAnimations;
    notifyListeners();
  }

  void toggleSounds() {
    _enableSounds = !_enableSounds;
    notifyListeners();
  }

  void setAnimations(bool enabled) {
    _enableAnimations = enabled;
    notifyListeners();
  }

  void setSounds(bool enabled) {
    _enableSounds = enabled;
    notifyListeners();
  }

  // Callbacks para a UI (eventos)
  Function(bool won)? onGameOver;
  VoidCallback? onTimeOut;

  void _onGameOver(bool won) {
    onGameOver?.call(won);
  }

  void _onTimeOut() {
    onTimeOut?.call();
  }

  // Gerenciamento de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    _updateLastStateChange();
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _updateLastStateChange();
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    _updateLastStateChange();
    notifyListeners();
  }

  // Gerenciamento de estado e telemetria
  void _updateLastStateChange() {
    _lastStateChange = DateTime.now();
  }

  void _logError(String error, [StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $error';
    _errorLogs.add(logEntry);

    // Manter apenas os últimos 50 logs
    if (_errorLogs.length > 50) {
      _errorLogs.removeAt(0);
    }

    debugPrint('SoletrandoViewModel Error: $logEntry');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  // Sistema de auto-save
  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _autoSaveGameState();
    });
  }

  void _autoSaveGameState() async {
    if (_isLoading || hasError) return;

    try {
      // Inicializa o storage se necessário
      await _storageService.initialize();

      // Salva estado do jogo
      final gameState = _game.toJson();
      final success = await _storageService.saveGameState(gameState);

      if (success) {
        _game.markAsSaved();
        debugPrint('Game state auto-saved successfully');
      } else {
        _logError('Failed to auto-save game state');
      }

      // Salva estatísticas
      await _saveStatistics();
    } catch (e, stackTrace) {
      _logError('Auto-save failed: $e', stackTrace);
    }
  }

  // Salva estatísticas do jogo
  Future<void> _saveStatistics() async {
    try {
      final statistics = {
        'totalGamesPlayed': 1, // Seria incrementado
        'totalScore': _game.score,
        'categoryProgress': Map<String, int>.from(_categoryProgress),
        'lastPlayed': DateTime.now().toIso8601String(),
        'difficulty': _difficulty.name,
      };

      await _storageService.saveStatistics(statistics);
    } catch (e, stackTrace) {
      _logError('Failed to save statistics: $e', stackTrace);
    }
  }

  // Salva progresso do jogo em pontos estratégicos
  Future<void> _saveGameProgress() async {
    try {
      await _storageService.initialize();

      final gameState = _game.toJson();
      final success = await _storageService.saveGameState(gameState);

      if (success) {
        _game.markAsSaved();
        debugPrint('Game progress saved at strategic point');
      }

      await _saveStatistics();
    } catch (e, stackTrace) {
      _logError('Failed to save game progress: $e', stackTrace);
    }
  }

  // Método para retry em caso de erro
  Future<void> retry() async {
    _clearError();
    await startNewGame();
  }

  // Métodos utilitários para a UI
  String formatTimeRemaining() {
    final minutes = _timeRemaining ~/ 60;
    final seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String getCategoryDisplayName() {
    return SoletrandoStrings.getCategoryName(_game.currentCategory.name);
  }

  String getGameResultMessage() {
    return SoletrandoStrings.getGameResultMessage(_game.result.name);
  }

  Color getTimerColor() {
    if (isCriticalTime) return const Color(0xFFEF4444); // Red
    if (_timeRemaining <= 30) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFF10B981); // Green
  }

  double getTimerProgress() {
    final maxTime = _difficulty.timeInSeconds;
    return maxTime > 0 ? _timeRemaining / maxTime : 0.0;
  }

  // Estatísticas do jogo
  Map<String, dynamic> getGameStatistics() {
    return {
      'currentScore': _game.score,
      'currentLives': _game.lives,
      'timeRemaining': _timeRemaining,
      'hintCount': _hintCount,
      'categoryProgress': Map<String, int>.from(_categoryProgress),
      'difficulty': _difficulty.name,
      'isGameActive': isGameActive,
    };
  }

  // Informações de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'gameState': _game.result.name,
      'currentWord': _game.currentWord,
      'displayWord': _game.displayWord,
      'timerInfo': _timerService.getDebugInfo(),
      'viewModelState': {
        'isLoading': _isLoading,
        'hasError': hasError,
        'error': _error,
        'difficulty': _difficulty.name,
        'enableAnimations': _enableAnimations,
        'enableSounds': _enableSounds,
      },
    };
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _timerService.dispose();
    super.dispose();
  }

  // Métodos de telemetria e diagnóstico
  List<String> get errorLogs => List.unmodifiable(_errorLogs);

  DateTime? get lastStateChange => _lastStateChange;

  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'lastStateChange': _lastStateChange?.toIso8601String(),
      'errorCount': _errorLogs.length,
      'recentErrors': _errorLogs.take(5).toList(),
      'memoryUsage': {
        'timerActive': _timerService.isRunning,
        'autoSaveActive': _autoSaveTimer?.isActive ?? false,
        'listenersCount': hasListeners ? 'yes' : 'no',
      },
    };
  }
}

/// Extensão para facilitar acesso a propriedades específicas
extension SoletrandoViewModelExtensions on SoletrandoViewModel {
  bool get isWordCompleted => !game.displayWord.contains('_');
  bool get hasLives => game.lives > 0;
  int get currentWordLength => game.currentWord.length;
  List<String> get availableLetters => game.availableLetters;
  List<String> get displayWord => game.displayWord;
  String get currentWord => game.currentWord;
  int get score => game.score;
  int get lives => game.lives;
  WordCategory get currentCategory => game.currentCategory;
}
