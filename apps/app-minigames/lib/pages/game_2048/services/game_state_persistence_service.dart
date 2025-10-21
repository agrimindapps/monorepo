// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_board.dart';

/// Classe para representar dados do estado do jogo que podem ser salvos
class GameStateData {
  final List<List<int>> board;
  final int score;
  final int moveCount;
  final bool hasWon;
  final bool gameOver;
  final BoardSize boardSize;
  final DateTime saveTime;
  final Duration gameDuration;
  final Duration pausedDuration;
  final TileColorScheme colorScheme;

  const GameStateData({
    required this.board,
    required this.score,
    required this.moveCount,
    required this.hasWon,
    required this.gameOver,
    required this.boardSize,
    required this.saveTime,
    required this.gameDuration,
    required this.pausedDuration,
    required this.colorScheme,
  });

  /// Converte para JSON para persistência
  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'score': score,
      'moveCount': moveCount,
      'hasWon': hasWon,
      'gameOver': gameOver,
      'boardSize': boardSize.size,
      'saveTime': saveTime.millisecondsSinceEpoch,
      'gameDuration': gameDuration.inMilliseconds,
      'pausedDuration': pausedDuration.inMilliseconds,
      'colorScheme': colorScheme.name,
      'version': 1, // Para compatibilidade futura
    };
  }

  /// Cria instância a partir de JSON
  factory GameStateData.fromJson(Map<String, dynamic> json) {
    // Validar versão para compatibilidade
    final version = json['version'] ?? 1;
    if (version != 1) {
      throw FormatException('Versão de save não suportada: $version');
    }

    return GameStateData(
      board: (json['board'] as List)
          .map((row) => (row as List).cast<int>())
          .toList(),
      score: json['score'] as int,
      moveCount: json['moveCount'] as int,
      hasWon: json['hasWon'] as bool,
      gameOver: json['gameOver'] as bool,
      boardSize: BoardSize.values.firstWhere(
        (size) => size.size == json['boardSize'],
        orElse: () => BoardSize.size4x4,
      ),
      saveTime: DateTime.fromMillisecondsSinceEpoch(json['saveTime'] as int),
      gameDuration: Duration(milliseconds: json['gameDuration'] as int),
      pausedDuration: Duration(milliseconds: json['pausedDuration'] as int),
      colorScheme: TileColorScheme.values.firstWhere(
        (scheme) => scheme.name == json['colorScheme'],
        orElse: () => TileColorScheme.blue,
      ),
    );
  }

  /// Cria instância a partir de GameBoard
  factory GameStateData.fromGameBoard(
    GameBoard gameBoard,
    BoardSize boardSize,
    TileColorScheme colorScheme,
  ) {
    return GameStateData(
      board: List.generate(
        gameBoard.board.length,
        (i) => List.from(gameBoard.board[i]),
      ),
      score: gameBoard.score,
      moveCount: gameBoard.moveCount,
      hasWon: gameBoard.hasWon,
      gameOver: gameBoard.gameOver,
      boardSize: boardSize,
      saveTime: DateTime.now(),
      gameDuration: gameBoard.getGameDuration(),
      pausedDuration: gameBoard.pausedDuration,
      colorScheme: colorScheme,
    );
  }

  /// Cria uma cópia com valores modificados
  GameStateData copyWith({
    List<List<int>>? board,
    int? score,
    int? moveCount,
    bool? hasWon,
    bool? gameOver,
    BoardSize? boardSize,
    DateTime? saveTime,
    Duration? gameDuration,
    Duration? pausedDuration,
    TileColorScheme? colorScheme,
  }) {
    return GameStateData(
      board: board ?? this.board,
      score: score ?? this.score,
      moveCount: moveCount ?? this.moveCount,
      hasWon: hasWon ?? this.hasWon,
      gameOver: gameOver ?? this.gameOver,
      boardSize: boardSize ?? this.boardSize,
      saveTime: saveTime ?? this.saveTime,
      gameDuration: gameDuration ?? this.gameDuration,
      pausedDuration: pausedDuration ?? this.pausedDuration,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }
}

/// Configurações de autosave
class AutoSaveSettings {
  final bool autoSaveEnabled;
  final Duration autoSaveInterval;
  final bool saveOnAppPause;
  final bool saveOnMovement;
  final int movementSaveFrequency;
  final bool showRestoreDialog;
  final bool autoCleanOldSaves;

  const AutoSaveSettings({
    this.autoSaveEnabled = true,
    this.autoSaveInterval = const Duration(seconds: 30),
    this.saveOnAppPause = true,
    this.saveOnMovement = true,
    this.movementSaveFrequency = 5,
    this.showRestoreDialog = true,
    this.autoCleanOldSaves = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'autoSaveEnabled': autoSaveEnabled,
      'autoSaveInterval': autoSaveInterval.inSeconds,
      'saveOnAppPause': saveOnAppPause,
      'saveOnMovement': saveOnMovement,
      'movementSaveFrequency': movementSaveFrequency,
      'showRestoreDialog': showRestoreDialog,
      'autoCleanOldSaves': autoCleanOldSaves,
    };
  }

  factory AutoSaveSettings.fromJson(Map<String, dynamic> json) {
    return AutoSaveSettings(
      autoSaveEnabled: json['autoSaveEnabled'] ?? true,
      autoSaveInterval: Duration(seconds: json['autoSaveInterval'] ?? 30),
      saveOnAppPause: json['saveOnAppPause'] ?? true,
      saveOnMovement: json['saveOnMovement'] ?? true,
      movementSaveFrequency: json['movementSaveFrequency'] ?? 5,
      showRestoreDialog: json['showRestoreDialog'] ?? true,
      autoCleanOldSaves: json['autoCleanOldSaves'] ?? true,
    );
  }

  AutoSaveSettings copyWith({
    bool? autoSaveEnabled,
    Duration? autoSaveInterval,
    bool? saveOnAppPause,
    bool? saveOnMovement,
    int? movementSaveFrequency,
    bool? showRestoreDialog,
    bool? autoCleanOldSaves,
  }) {
    return AutoSaveSettings(
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      saveOnAppPause: saveOnAppPause ?? this.saveOnAppPause,
      saveOnMovement: saveOnMovement ?? this.saveOnMovement,
      movementSaveFrequency: movementSaveFrequency ?? this.movementSaveFrequency,
      showRestoreDialog: showRestoreDialog ?? this.showRestoreDialog,
      autoCleanOldSaves: autoCleanOldSaves ?? this.autoCleanOldSaves,
    );
  }
}

/// Serviço para persistência inteligente do estado do jogo
class GameStatePersistenceService {
  static const String _activeGameKey = 'game_2048_active_state';
  static const String _autosaveSettingsKey = 'game_2048_autosave_settings';
  static const String _lastAutosaveKey = 'game_2048_last_autosave';

  SharedPreferences? _prefs;
  Timer? _autosaveTimer;
  AutoSaveSettings _settings = const AutoSaveSettings();
  DateTime? _lastSaveTime;
  int _lastMoveCount = 0;

  /// Inicializa o serviço
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadAutoSaveSettings();
    _lastSaveTime = await _getLastAutosaveTime();
  }

  /// Salva o estado atual do jogo
  Future<bool> saveActiveGame(GameStateData gameState) async {
    if (_prefs == null) return false;

    try {
      final jsonString = jsonEncode(gameState.toJson());
      final success = await _prefs!.setString(_activeGameKey, jsonString);
      
      if (success) {
        await _updateLastAutosaveTime();
        _lastSaveTime = DateTime.now();
      }
      
      return success;
    } catch (e) {
      debugPrint('Erro ao salvar estado do jogo: $e');
      return false;
    }
  }

  /// Carrega o estado salvo do jogo
  Future<GameStateData?> loadActiveGame() async {
    if (_prefs == null) return null;

    try {
      final jsonString = _prefs!.getString(_activeGameKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameStateData.fromJson(json);
    } catch (e) {
      debugPrint('Erro ao carregar estado do jogo: $e');
      // Se houver erro, limpar save corrompido
      await clearSavedGame();
      return null;
    }
  }

  /// Verifica se existe um jogo salvo
  Future<bool> hasSavedGame() async {
    if (_prefs == null) return false;
    
    final gameState = await loadActiveGame();
    if (gameState == null) return false;
    
    // Verificar se o save não é muito antigo (mais de 7 dias)
    if (_settings.autoCleanOldSaves) {
      final daysSinceSave = DateTime.now().difference(gameState.saveTime).inDays;
      if (daysSinceSave > 7) {
        await clearSavedGame();
        return false;
      }
    }
    
    // Não considerar como save válido se o jogo já acabou
    return !gameState.gameOver;
  }

  /// Limpa o jogo salvo
  Future<bool> clearSavedGame() async {
    if (_prefs == null) return false;
    return await _prefs!.remove(_activeGameKey);
  }

  /// Inicia autosave baseado em timer
  void startAutoSave(Future<GameStateData?> Function() getGameState) {
    if (!_settings.autoSaveEnabled) return;
    
    _stopAutoSave(); // Parar timer anterior se existir
    
    _autosaveTimer = Timer.periodic(_settings.autoSaveInterval, (timer) async {
      final gameState = await getGameState();
      if (gameState != null && !gameState.gameOver) {
        // Apenas salvar se houve mudanças desde o último save
        if (_shouldAutoSave(gameState)) {
          await saveActiveGame(gameState);
        }
      }
    });
  }

  /// Para o autosave
  void _stopAutoSave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = null;
  }

  /// Verifica se deve fazer autosave baseado em movimento
  bool shouldSaveOnMovement(int currentMoveCount) {
    if (!_settings.saveOnMovement) return false;
    
    final movesSinceLastSave = currentMoveCount - _lastMoveCount;
    if (movesSinceLastSave >= _settings.movementSaveFrequency) {
      _lastMoveCount = currentMoveCount;
      return true;
    }
    
    return false;
  }

  /// Verifica se deve fazer autosave baseado em mudanças
  bool _shouldAutoSave(GameStateData gameState) {
    // Salvar se é o primeiro save
    if (_lastSaveTime == null) return true;
    
    // Salvar se houve mudança nos movimentos
    if (gameState.moveCount != _lastMoveCount) {
      _lastMoveCount = gameState.moveCount;
      return true;
    }
    
    // Salvar se passou tempo suficiente desde último save
    final timeSinceLastSave = DateTime.now().difference(_lastSaveTime!);
    return timeSinceLastSave >= _settings.autoSaveInterval;
  }

  /// Força autosave (para eventos de lifecycle)
  Future<bool> forceAutoSave(GameStateData gameState) async {
    if (!_settings.autoSaveEnabled) return false;
    return await saveActiveGame(gameState);
  }

  /// Carrega configurações de autosave
  Future<void> _loadAutoSaveSettings() async {
    if (_prefs == null) return;
    
    final jsonString = _prefs!.getString(_autosaveSettingsKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _settings = AutoSaveSettings.fromJson(json);
      } catch (e) {
        debugPrint('Erro ao carregar configurações de autosave: $e');
      }
    }
  }

  /// Salva configurações de autosave
  Future<bool> saveAutoSaveSettings(AutoSaveSettings settings) async {
    if (_prefs == null) return false;
    
    try {
      _settings = settings;
      final jsonString = jsonEncode(settings.toJson());
      return await _prefs!.setString(_autosaveSettingsKey, jsonString);
    } catch (e) {
      debugPrint('Erro ao salvar configurações de autosave: $e');
      return false;
    }
  }

  /// Obtém configurações atuais de autosave
  AutoSaveSettings get autoSaveSettings => _settings;

  /// Atualiza timestamp do último autosave
  Future<void> _updateLastAutosaveTime() async {
    if (_prefs == null) return;
    await _prefs!.setInt(_lastAutosaveKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Obtém timestamp do último autosave
  Future<DateTime?> _getLastAutosaveTime() async {
    if (_prefs == null) return null;
    
    final timestamp = _prefs!.getInt(_lastAutosaveKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Limpa recursos
  void dispose() {
    _stopAutoSave();
  }
}
