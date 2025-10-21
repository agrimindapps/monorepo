// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/constants/game_config.dart';
import 'package:app_minigames/models/game_board.dart';
import 'package:app_minigames/services/game_service.dart';
import 'package:app_minigames/services/game_state_persistence_service.dart';

/// Classe para representar estatísticas do jogo
class GameStatistics {
  final int highScore;
  final int gamesPlayed;
  final int gamesWon;
  final int totalScore;
  final double winRate;
  final double averageScore;
  final List<GameHistoryEntry> history;

  GameStatistics({
    required this.highScore,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.totalScore,
    required this.winRate,
    required this.averageScore,
    required this.history,
  });

  factory GameStatistics.fromService(GameService service) {
    return GameStatistics(
      highScore: service.getHighScore(),
      gamesPlayed: service.getGamesPlayed(),
      gamesWon: service.getGamesWon(),
      totalScore: service.getTotalScore(),
      winRate: service.getWinRate(),
      averageScore: service.getAverageScore(),
      history: service.getGameHistory(),
    );
  }
}

/// Controller principal do jogo 2048 seguindo padrão MVC
/// Gerencia o estado do jogo e a comunicação entre Model e View
class Game2048Controller extends ChangeNotifier {
  // =================================================================
  // PROPRIEDADES PRIVADAS
  // =================================================================

  late GameBoard _gameBoard;
  late GameService _gameService;
  late GameStatePersistenceService _autosaveService;

  TileColorScheme _currentColorScheme = Game2048Config.defaultColorScheme;
  BoardSize _currentBoardSize = Game2048Config.defaultBoardSize;

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasUnsavedChanges = false;
  DateTime? _pauseStartTime;

  // =================================================================
  // GETTERS PÚBLICOS
  // =================================================================

  /// Tabuleiro atual do jogo
  GameBoard get gameBoard => _gameBoard;

  /// Serviço de persistência e estatísticas
  GameService get gameService => _gameService;

  /// Esquema de cores atual
  TileColorScheme get currentColorScheme => _currentColorScheme;

  /// Tamanho atual do tabuleiro
  BoardSize get currentBoardSize => _currentBoardSize;

  /// Estado de carregamento
  bool get isLoading => _isLoading;

  /// Mensagem de erro atual (se houver)
  String? get errorMessage => _errorMessage;

  /// Indica se há mudanças não salvas
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  
  /// Indica se o jogo está pausado
  bool get isPaused => _gameBoard.isPaused;

  /// Pontuação atual
  int get currentScore => _gameBoard.score;

  /// Contagem de movimentos
  int get moveCount => _gameBoard.moveCount;

  /// Duração do jogo atual
  Duration get gameDuration => _gameBoard.getGameDuration();

  /// Estado do jogo (game over, vitória, etc.)
  bool get isGameOver => _gameBoard.gameOver;

  /// Indica se o jogador ganhou
  bool get hasWon => _gameBoard.hasWon;

  /// Estatísticas do jogo
  GameStatistics get statistics => GameStatistics.fromService(_gameService);

  /// Configurações do jogo
  GameSettings get settings => _gameService.getSettings();

  /// Som habilitado
  bool get soundEnabled => _gameService.getSettings().soundEnabled;

  /// Vibração habilitada
  bool get vibrationEnabled => _gameService.getSettings().vibrationEnabled;

  /// Verifica se é possível desfazer um movimento
  bool get canUndo => _gameBoard.canUndo();

  /// Verifica se é possível refazer um movimento
  bool get canRedo => _gameBoard.canRedo();

  /// Retorna o número de movimentos que podem ser desfeitos
  int get undoCount => _gameBoard.getUndoCount();

  /// Retorna o número de movimentos que podem ser refeitos
  int get redoCount => _gameBoard.getRedoCount();

  /// Verifica se existe um jogo salvo para recuperar
  Future<bool> get hasSavedGame => _autosaveService.hasSavedGame();

  /// Configurações de autosave
  AutoSaveSettings get autoSaveSettings => _autosaveService.autoSaveSettings;

  // =================================================================
  // CONSTRUTOR E INICIALIZAÇÃO
  // =================================================================

  Game2048Controller() {
    // Inicialização síncrona básica
    _gameService = GameService();
    _autosaveService = GameStatePersistenceService();
    _gameBoard = GameBoard(_currentBoardSize);

    // Inicialização assíncrona dos dados persistidos
    _initialize();
  }

  /// Inicializa o controller de forma assíncrona
  Future<void> _initialize() async {
    _setLoading(true);
    _clearError();

    try {
      // Inicializar serviços
      await _gameService.initialize();
      await _autosaveService.initialize();

      // Carregar configurações salvas
      final savedSettings = _gameService.getSettings();
      _currentColorScheme = savedSettings.colorScheme;

      // Se o tamanho do tabuleiro mudou, reiniciar o jogo
      if (_currentBoardSize != savedSettings.defaultBoardSize) {
        _currentBoardSize = savedSettings.defaultBoardSize;
        _gameBoard = GameBoard(_currentBoardSize);
      }

      // Inicializar autosave
      await _initializeAutoSave();

      debugPrint('Game2048Controller: Inicialização concluída');
    } catch (error) {
      _setError('Erro ao inicializar o jogo: $error');
      debugPrint('Game2048Controller: Erro na inicialização: $error');
    } finally {
      _setLoading(false);
    }
  }

  // =================================================================
  // MÉTODOS DE CONTROLE DO JOGO
  // =================================================================

  /// Inicia um novo jogo
  Future<void> startNewGame() async {
    try {
      _clearError();

      // Salvar jogo anterior se necessário
      if (_hasUnsavedChanges && !_gameBoard.gameOver) {
        await _saveCurrentGame();
      }

      // Criar novo tabuleiro
      _gameBoard = GameBoard(_currentBoardSize);
      _hasUnsavedChanges = false;

      // Notificar listeners
      notifyListeners();

      debugPrint('Game2048Controller: Novo jogo iniciado');
    } catch (error) {
      _setError('Erro ao iniciar novo jogo: $error');
    }
  }

  /// Executa movimento no tabuleiro
  Future<void> makeMove(Direction direction) async {
    if (_gameBoard.gameOver || _isLoading || _gameBoard.isPaused) return;

    try {
      _clearError();

      // Executar movimento
      final bool moved = _gameBoard.move(direction);

      if (moved) {
        _hasUnsavedChanges = true;

        // Verificar vitória
        if (_gameBoard.hasWon && !_gameBoard.gameOver) {
          await _handleVictory();
        }

        // Verificar game over
        if (_gameBoard.gameOver) {
          await _handleGameOver();
        }

        // Feedback háptico
        if (_gameService.getSettings().vibrationEnabled) {
          HapticFeedback.lightImpact();
        }

        // Notificar listeners
        notifyListeners();

        // Autosave baseado em movimento
        if (_autosaveService.shouldSaveOnMovement(_gameBoard.moveCount)) {
          _performAutoSave();
        }

        // Limpar flags de animação após um tempo para permitir que as animações sejam exibidas
        Future.delayed(const Duration(milliseconds: 300), () {
          _gameBoard.clearAnimationFlags();
          notifyListeners();
        });
      }
    } catch (error) {
      _setError('Erro ao executar movimento: $error');
    }
  }

  /// Desfaz o último movimento
  Future<void> undoLastMove() async {
    if (!_gameBoard.canUndo()) return;

    try {
      _clearError();
      
      final success = _gameBoard.undoLastMove();
      if (success) {
        _hasUnsavedChanges = true;
        
        // Feedback háptico
        if (_gameService.getSettings().vibrationEnabled) {
          HapticFeedback.selectionClick();
        }
        
        notifyListeners();
        debugPrint('Game2048Controller: Movimento desfeito');
      }
    } catch (error) {
      _setError('Erro ao desfazer movimento: $error');
    }
  }

  /// Refaz o último movimento desfeito
  Future<void> redoLastMove() async {
    if (!_gameBoard.canRedo()) return;

    try {
      _clearError();
      
      final success = _gameBoard.redoLastMove();
      if (success) {
        _hasUnsavedChanges = true;
        
        // Feedback háptico
        if (_gameService.getSettings().vibrationEnabled) {
          HapticFeedback.selectionClick();
        }
        
        notifyListeners();
        debugPrint('Game2048Controller: Movimento refeito');
      }
    } catch (error) {
      _setError('Erro ao refazer movimento: $error');
    }
  }

  /// Pausa/Resume o jogo
  void togglePause() {
    try {
      if (_gameBoard.gameOver) return;
      
      if (_gameBoard.isPaused) {
        // Resumir o jogo
        final pauseDuration = _pauseStartTime != null 
            ? DateTime.now().difference(_pauseStartTime!)
            : Duration.zero;
        _gameBoard.resumeGame(pauseDuration);
        _pauseStartTime = null;
        debugPrint('Game2048Controller: Jogo resumido');
      } else {
        // Pausar o jogo
        _gameBoard.pauseGame();
        _pauseStartTime = DateTime.now();
        debugPrint('Game2048Controller: Jogo pausado');
      }
      
      notifyListeners();
    } catch (error) {
      _setError('Erro ao pausar/resumir jogo: $error');
    }
  }

  // =================================================================
  // MÉTODOS DE CONFIGURAÇÃO
  // =================================================================

  /// Altera o esquema de cores
  Future<void> changeColorScheme(TileColorScheme newScheme) async {
    if (_currentColorScheme == newScheme) return;

    try {
      _clearError();
      _currentColorScheme = newScheme;

      // Salvar configuração
      final updatedSettings = _gameService.getSettings().copyWith(
            colorScheme: newScheme,
          );
      await _gameService.saveSettings(updatedSettings);

      notifyListeners();
      debugPrint(
          'Game2048Controller: Esquema de cores alterado para $newScheme');
    } catch (error) {
      _setError('Erro ao alterar esquema de cores: $error');
    }
  }

  /// Altera o tamanho do tabuleiro
  Future<void> changeBoardSize(BoardSize newSize) async {
    if (_currentBoardSize == newSize) return;

    try {
      _clearError();

      // Confirmar se o usuário quer perder o progresso atual
      if (_hasUnsavedChanges && !_gameBoard.gameOver) {
        // TODO: Mostrar dialog de confirmação na UI
        await _saveCurrentGame();
      }

      _currentBoardSize = newSize;

      // Salvar configuração
      final updatedSettings = _gameService.getSettings().copyWith(
            defaultBoardSize: newSize,
          );
      await _gameService.saveSettings(updatedSettings);

      // Reiniciar jogo com novo tamanho
      await startNewGame();

      debugPrint(
          'Game2048Controller: Tamanho do tabuleiro alterado para $newSize');
    } catch (error) {
      _setError('Erro ao alterar tamanho do tabuleiro: $error');
    }
  }

  /// Altera configuração de som
  Future<void> toggleSound() async {
    try {
      final currentSettings = _gameService.getSettings();
      final updatedSettings = currentSettings.copyWith(
        soundEnabled: !currentSettings.soundEnabled,
      );
      await _gameService.saveSettings(updatedSettings);

      notifyListeners();
    } catch (error) {
      _setError('Erro ao alterar configuração de som: $error');
    }
  }

  /// Altera configuração de vibração
  Future<void> toggleVibration() async {
    try {
      final currentSettings = _gameService.getSettings();
      final updatedSettings = currentSettings.copyWith(
        vibrationEnabled: !currentSettings.vibrationEnabled,
      );
      await _gameService.saveSettings(updatedSettings);

      notifyListeners();
    } catch (error) {
      _setError('Erro ao alterar configuração de vibração: $error');
    }
  }

  // =================================================================
  // MÉTODOS DE PERSISTÊNCIA
  // =================================================================

  /// Salva o jogo atual
  Future<void> saveGame() async {
    if (!_hasUnsavedChanges) return;

    try {
      _setLoading(true);
      await _saveCurrentGame();
      _hasUnsavedChanges = false;
      notifyListeners();
    } catch (error) {
      _setError('Erro ao salvar jogo: $error');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega estatísticas mais recentes
  Future<void> refreshStatistics() async {
    try {
      _setLoading(true);
      // As estatísticas são carregadas dinamicamente via getters
      notifyListeners();
    } catch (error) {
      _setError('Erro ao carregar estatísticas: $error');
    } finally {
      _setLoading(false);
    }
  }

  /// Limpa dados salvos
  Future<void> clearGameData() async {
    try {
      _setLoading(true);
      await _gameService.resetAllData();
      await startNewGame();
      notifyListeners();
    } catch (error) {
      _setError('Erro ao limpar dados: $error');
    } finally {
      _setLoading(false);
    }
  }

  // =================================================================
  // MÉTODOS PRIVADOS
  // =================================================================

  /// Salva o jogo atual no histórico
  Future<void> _saveCurrentGame() async {
    await _gameService.recordGameEnd(
      finalScore: _gameBoard.score,
      hasWon: _gameBoard.hasWon,
      boardSize: _currentBoardSize,
      moves: _gameBoard.moveCount,
      gameDuration: _gameBoard.getGameDuration(),
    );
  }

  /// Manipula vitória do jogador
  Future<void> _handleVictory() async {
    if (_gameService.getSettings().vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }

    await _saveCurrentGame();

    // TODO: Emitir evento de vitória para a UI
    debugPrint('Game2048Controller: Jogador venceu!');
  }

  /// Manipula game over
  Future<void> _handleGameOver() async {
    if (_gameService.getSettings().vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }

    await _saveCurrentGame();
    _hasUnsavedChanges = false;

    // TODO: Emitir evento de game over para a UI
    debugPrint('Game2048Controller: Game Over');
  }

  /// Define estado de carregamento
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Define mensagem de erro
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
    debugPrint('Game2048Controller: Erro: $error');
  }

  /// Limpa mensagem de erro
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // =================================================================
  // LIMPEZA DE RECURSOS
  // =================================================================

  // =================================================================
  // SISTEMA DE AUTOSAVE INTELIGENTE
  // =================================================================

  /// Inicializa o sistema de autosave
  Future<void> _initializeAutoSave() async {
    // Iniciar timer de autosave
    _autosaveService.startAutoSave(() async {
      if (_gameBoard.gameOver) return null;
      return _createGameStateData();
    });
  }

  /// Cria dados do estado atual do jogo
  GameStateData _createGameStateData() {
    return GameStateData.fromGameBoard(
      _gameBoard,
      _currentBoardSize,
      _currentColorScheme,
    );
  }

  /// Executa autosave de forma assíncrona
  Future<void> _performAutoSave() async {
    try {
      if (_gameBoard.gameOver) return;
      
      final gameState = _createGameStateData();
      await _autosaveService.saveActiveGame(gameState);
      
      debugPrint('Game2048Controller: Autosave realizado');
    } catch (error) {
      debugPrint('Game2048Controller: Erro no autosave: $error');
    }
  }

  /// Força autosave (para eventos de lifecycle)
  Future<void> forceAutoSave() async {
    try {
      if (_gameBoard.gameOver) return;
      
      final gameState = _createGameStateData();
      await _autosaveService.forceAutoSave(gameState);
      
      debugPrint('Game2048Controller: Autosave forçado realizado');
    } catch (error) {
      debugPrint('Game2048Controller: Erro no autosave forçado: $error');
    }
  }

  /// Restaura jogo salvo
  Future<bool> restoreSavedGame() async {
    try {
      _setLoading(true);
      
      final savedGame = await _autosaveService.loadActiveGame();
      if (savedGame == null) return false;

      // Criar novo GameBoard com o estado salvo
      _gameBoard = GameBoard(savedGame.boardSize);
      
      // Restaurar estado
      _gameBoard.board = List.generate(
        savedGame.board.length,
        (i) => List.from(savedGame.board[i]),
      );
      _gameBoard.score = savedGame.score;
      _gameBoard.moveCount = savedGame.moveCount;
      _gameBoard.hasWon = savedGame.hasWon;
      _gameBoard.gameOver = savedGame.gameOver;
      _gameBoard.pausedDuration = savedGame.pausedDuration;
      
      // Restaurar configurações
      _currentBoardSize = savedGame.boardSize;
      _currentColorScheme = savedGame.colorScheme;
      
      // Limpar save após restaurar
      await _autosaveService.clearSavedGame();
      
      _hasUnsavedChanges = false;
      notifyListeners();
      
      debugPrint('Game2048Controller: Jogo restaurado do autosave');
      return true;
    } catch (error) {
      _setError('Erro ao restaurar jogo salvo: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Limpa jogo salvo
  Future<void> clearSavedGame() async {
    try {
      await _autosaveService.clearSavedGame();
      debugPrint('Game2048Controller: Save limpo');
    } catch (error) {
      debugPrint('Game2048Controller: Erro ao limpar save: $error');
    }
  }

  /// Atualiza configurações de autosave
  Future<void> updateAutoSaveSettings(AutoSaveSettings settings) async {
    try {
      await _autosaveService.saveAutoSaveSettings(settings);
      
      // Reinicializar autosave com novas configurações
      await _initializeAutoSave();
      
      debugPrint('Game2048Controller: Configurações de autosave atualizadas');
    } catch (error) {
      _setError('Erro ao atualizar configurações de autosave: $error');
    }
  }

  @override
  void dispose() {
    // Salvar jogo atual se houver mudanças
    if (_hasUnsavedChanges && !_gameBoard.gameOver) {
      _saveCurrentGame().catchError((error) {
        debugPrint('Game2048Controller: Erro ao salvar na finalização: $error');
      });
    }

    // Limpar recursos do autosave
    _autosaveService.dispose();

    super.dispose();
  }
}
