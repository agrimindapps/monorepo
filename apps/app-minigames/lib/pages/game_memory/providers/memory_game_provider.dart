/// Provider para gerenciamento de estado do jogo da memória
/// 
/// Centraliza todo o estado do jogo e notifica a UI sobre mudanças,
/// seguindo o padrão Provider para arquitetura reativa.
library;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_logic.dart';
import 'package:app_minigames/services/memory_audio_service.dart';
import 'package:app_minigames/services/memory_storage_service.dart';
import 'package:app_minigames/services/memory_timer_service.dart';

/// Provider principal para o estado do jogo da memória
class MemoryGameProvider extends ChangeNotifier {
  /// Lógica de negócio do jogo
  late MemoryGameLogic _gameLogic;
  
  /// Serviços auxiliares
  late MemoryTimerService _timerService;
  late MemoryAudioService _audioService;
  late MemoryStorageService _storageService;
  
  /// Estado de interação
  bool _isProcessingMatch = false;
  bool _canInteract = true;
  
  /// Construtor
  MemoryGameProvider({
    GameDifficulty initialDifficulty = GameDifficulty.medium,
  }) {
    _gameLogic = MemoryGameLogic(difficulty: initialDifficulty);
    _timerService = MemoryTimerService();
    _audioService = MemoryAudioService();
    _storageService = MemoryStorageService();
    
    _initializeGame();
  }
  
  /// Getters para acesso ao estado
  MemoryGameLogic get gameLogic => _gameLogic;
  bool get isProcessingMatch => _isProcessingMatch;
  bool get canInteract => _canInteract && !_isProcessingMatch;
  
  /// Getters delegados para estado do jogo
  bool get isGameStarted => _gameLogic.isGameStarted;
  bool get isGameOver => _gameLogic.isGameOver;
  bool get isPaused => _gameLogic.isPaused;
  GameDifficulty get difficulty => _gameLogic.difficulty;
  List<dynamic> get cards => _gameLogic.cards;
  int get moves => _gameLogic.moves;
  int get matchedPairs => _gameLogic.matchedPairs;
  int get totalPairs => _gameLogic.totalPairs;
  int get elapsedTimeInSeconds => _gameLogic.elapsedTimeInSeconds;
  int get bestScore => _gameLogic.bestScore;
  int? get firstCardIndex => _gameLogic.firstCardIndex;
  int? get secondCardIndex => _gameLogic.secondCardIndex;
  
  /// Inicializa o jogo
  Future<void> _initializeGame() async {
    _gameLogic.initializeGame();
    await _loadBestScore();
    notifyListeners();
  }
  
  /// Carrega a melhor pontuação
  Future<void> _loadBestScore() async {
    try {
      final score = await _storageService.loadBestScore(difficulty);
      _gameLogic.bestScore = score;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar melhor pontuação: $e');
    }
  }
  
  /// Inicia o jogo
  Future<void> startGame() async {
    _gameLogic.startGame();
    _startGameTimer();
    await _audioService.playGameStartSound();
    notifyListeners();
  }
  
  /// Inicia o timer do jogo
  void _startGameTimer() {
    _timerService.startGameTimer(
      onTick: () {
        if (!isPaused && !isGameOver) {
          _gameLogic.elapsedTimeInSeconds++;
          notifyListeners();
        }
      },
    );
  }
  
  /// Processa o toque em uma carta
  Future<void> onCardTap(int index) async {
    // Verifica se pode interagir
    if (!canInteract || isPaused || isGameOver) {
      return;
    }
    
    // Inicia o jogo se necessário
    if (!isGameStarted) {
      await startGame();
    }
    
    // Tenta virar a carta
    final wasValidMove = _gameLogic.flipCard(index);
    if (!wasValidMove) {
      return;
    }
    
    // Toca som de card flip
    await _audioService.playCardFlipSound();
    
    // Feedback tátil
    HapticFeedback.lightImpact();
    
    notifyListeners();
    
    // Se duas cartas estão viradas, processa a tentativa de match
    if (firstCardIndex != null && secondCardIndex != null) {
      await _processMatchAttempt();
    }
  }
  
  /// Processa a tentativa de match entre duas cartas
  Future<void> _processMatchAttempt() async {
    _isProcessingMatch = true;
    _canInteract = false;
    notifyListeners();
    
    // Espera um tempo para mostrar as cartas
    await Future.delayed(Duration(milliseconds: difficulty.matchTime));
    
    // Verifica se as cartas fazem match
    final card1 = _gameLogic.cards[firstCardIndex!];
    final card2 = _gameLogic.cards[secondCardIndex!];
    
    if (card1.matches(card2)) {
      // Match encontrado
      await _audioService.playMatchFoundSound();
      HapticFeedback.mediumImpact();
      
      // Verifica se o jogo terminou
      if (isGameOver) {
        await _handleGameOver();
      }
    } else {
      // Não foi match
      await _audioService.playMatchMissedSound();
      HapticFeedback.lightImpact();
      _gameLogic.resetSelectedCards();
    }
    
    _isProcessingMatch = false;
    _canInteract = true;
    notifyListeners();
  }
  
  /// Lida com o fim do jogo
  Future<void> _handleGameOver() async {
    _timerService.stopGameTimer();
    
    // Toca som de vitória
    await _audioService.playGameWinSound();
    HapticFeedback.heavyImpact();
    
    // Salva a pontuação se for um novo recorde
    try {
      final currentScore = _gameLogic.calculateScore();
      if (currentScore > bestScore) {
        await _storageService.saveBestScore(difficulty, currentScore);
        _gameLogic.bestScore = currentScore;
      }
    } catch (e) {
      debugPrint('Erro ao salvar pontuação: $e');
    }
    
    notifyListeners();
  }
  
  /// Pausa ou despausa o jogo
  void togglePause() {
    _gameLogic.togglePause();
    
    if (isPaused) {
      _timerService.pauseGameTimer();
      _canInteract = false;
    } else {
      _timerService.resumeGameTimer();
      _canInteract = true;
    }
    
    notifyListeners();
  }
  
  /// Reinicia o jogo
  Future<void> restartGame() async {
    _timerService.stopGameTimer();
    _isProcessingMatch = false;
    _canInteract = true;
    
    await _initializeGame();
    await _audioService.playGameStartSound();
  }
  
  /// Muda a dificuldade do jogo
  Future<void> changeDifficulty(GameDifficulty newDifficulty) async {
    if (newDifficulty == difficulty) return;
    
    _gameLogic.difficulty = newDifficulty;
    await restartGame();
  }
  
  /// Calcula a pontuação atual
  int calculateCurrentScore() => _gameLogic.calculateScore();
  
  /// Verifica se a pontuação atual é um novo recorde
  bool isNewRecord() {
    final currentScore = calculateCurrentScore();
    return currentScore > bestScore;
  }
  
  /// Obtém estatísticas do jogo
  Map<String, dynamic> getGameStatistics() {
    return {
      'moves': moves,
      'elapsedTime': elapsedTimeInSeconds,
      'matchedPairs': matchedPairs,
      'totalPairs': totalPairs,
      'score': calculateCurrentScore(),
      'bestScore': bestScore,
      'difficulty': difficulty.name,
      'isNewRecord': isNewRecord(),
      'efficiency': totalPairs > 0 ? '${(matchedPairs / totalPairs * 100).toStringAsFixed(1)}%' : '0%',
    };
  }
  
  /// Habilita interações
  void enableInteraction() {
    _canInteract = true;
    notifyListeners();
  }
  
  /// Desabilita interações
  void disableInteraction() {
    _canInteract = false;
    notifyListeners();
  }
  
  /// Força atualização da UI
  void forceUpdate() {
    notifyListeners();
  }
  
  @override
  void dispose() {
    _timerService.dispose();
    _audioService.dispose();
    super.dispose();
  }
}
