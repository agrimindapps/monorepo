/// Controlador para o jogo da memória
/// 
/// Coordena ações entre a UI e o Provider, implementando
/// o padrão MVC para separação clara de responsabilidades.
library;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import '../providers/memory_game_provider.dart';
import 'package:app_minigames/services/memory_storage_service.dart';

/// Controlador principal do jogo da memória
class MemoryGameController {
  /// Provider do jogo
  final MemoryGameProvider _gameProvider;
  
  /// Serviço de armazenamento
  final MemoryStorageService _storageService;
  
  /// Construtor
  MemoryGameController(this._gameProvider, this._storageService);
  
  /// Getters para acesso ao estado
  MemoryGameProvider get gameProvider => _gameProvider;
  
  /// Inicializa o controlador
  Future<void> initialize() async {
    try {
      await _storageService.initialize();
      debugPrint('MemoryGameController inicializado');
    } catch (e) {
      debugPrint('Erro ao inicializar MemoryGameController: $e');
    }
  }
  
  /// Inicia um novo jogo
  Future<void> startNewGame() async {
    try {
      await _gameProvider.startGame();
      debugPrint('Novo jogo iniciado');
    } catch (e) {
      debugPrint('Erro ao iniciar novo jogo: $e');
    }
  }
  
  /// Processa clique em carta
  Future<void> handleCardTap(int index) async {
    try {
      await _gameProvider.onCardTap(index);
    } catch (e) {
      debugPrint('Erro ao processar clique na carta $index: $e');
    }
  }
  
  /// Pausa ou despausa o jogo
  void togglePause() {
    try {
      _gameProvider.togglePause();
      debugPrint('Jogo ${_gameProvider.isPaused ? 'pausado' : 'despausado'}');
    } catch (e) {
      debugPrint('Erro ao alternar pausa: $e');
    }
  }
  
  /// Reinicia o jogo
  Future<void> restartGame() async {
    try {
      await _gameProvider.restartGame();
      debugPrint('Jogo reiniciado');
    } catch (e) {
      debugPrint('Erro ao reiniciar jogo: $e');
    }
  }
  
  /// Muda a dificuldade do jogo
  Future<void> changeDifficulty(GameDifficulty newDifficulty) async {
    try {
      await _gameProvider.changeDifficulty(newDifficulty);
      await _saveGameConfig();
      debugPrint('Dificuldade alterada para ${newDifficulty.name}');
    } catch (e) {
      debugPrint('Erro ao alterar dificuldade: $e');
    }
  }
  
  /// Salva configurações do jogo
  Future<void> _saveGameConfig() async {
    try {
      final config = {
        'lastDifficulty': _gameProvider.difficulty.name,
        'soundEnabled': true, // Placeholder - seria obtido do provider
        'hapticsEnabled': true,
      };
      
      await _storageService.saveGameConfig(config);
    } catch (e) {
      debugPrint('Erro ao salvar configurações: $e');
    }
  }
  
  /// Carrega configurações do jogo
  Future<void> loadGameConfig() async {
    try {
      final config = await _storageService.loadGameConfig();
      
      // Aplica dificuldade salva
      final difficultyName = config['lastDifficulty'] as String?;
      if (difficultyName != null) {
        final difficulty = GameDifficulty.values
            .where((d) => d.name == difficultyName)
            .firstOrNull;
        
        if (difficulty != null && difficulty != _gameProvider.difficulty) {
          await _gameProvider.changeDifficulty(difficulty);
        }
      }
      
      debugPrint('Configurações carregadas');
    } catch (e) {
      debugPrint('Erro ao carregar configurações: $e');
    }
  }
  
  /// Obtém estatísticas do jogo
  Map<String, dynamic> getGameStatistics() {
    return _gameProvider.getGameStatistics();
  }
  
  /// Obtém estatísticas do jogador
  Future<Map<String, int>> getPlayerStatistics() async {
    try {
      return await _storageService.loadPlayerStatistics();
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas do jogador: $e');
      return {};
    }
  }
  
  /// Atualiza estatísticas após fim do jogo
  Future<void> updateGameStatistics() async {
    if (!_gameProvider.isGameOver) return;
    
    try {
      final moves = _gameProvider.moves;
      final timeInSeconds = _gameProvider.elapsedTimeInSeconds;
      final isPerfectGame = moves == _gameProvider.totalPairs; // Jogo perfeito = mínimo de movimentos
      
      await _storageService.updatePlayerStatistics(
        won: true, // Se chegou ao fim, sempre ganhou
        moves: moves,
        timeInSeconds: timeInSeconds,
        isPerfectGame: isPerfectGame,
      );
      
      debugPrint('Estatísticas atualizadas');
    } catch (e) {
      debugPrint('Erro ao atualizar estatísticas: $e');
    }
  }
  
  /// Valida integridade dos dados
  Future<Map<GameDifficulty, bool>> validateDataIntegrity() async {
    try {
      return await _storageService.validateDataIntegrity();
    } catch (e) {
      debugPrint('Erro ao validar integridade dos dados: $e');
      return {};
    }
  }
  
  /// Exporta dados do jogo
  Future<Map<String, dynamic>> exportGameData() async {
    try {
      return await _storageService.exportData();
    } catch (e) {
      debugPrint('Erro ao exportar dados: $e');
      return {};
    }
  }
  
  /// Importa dados do jogo
  Future<bool> importGameData(Map<String, dynamic> data) async {
    try {
      final success = await _storageService.importData(data);
      if (success) {
        // Recarrega configurações após importação
        await loadGameConfig();
      }
      return success;
    } catch (e) {
      debugPrint('Erro ao importar dados: $e');
      return false;
    }
  }
  
  /// Limpa todos os dados
  Future<bool> clearAllData() async {
    try {
      final success = await _storageService.clearAllData();
      if (success) {
        await _gameProvider.restartGame();
      }
      return success;
    } catch (e) {
      debugPrint('Erro ao limpar dados: $e');
      return false;
    }
  }
  
  /// Força atualização da UI
  void forceUIUpdate() {
    _gameProvider.forceUpdate();
  }
  
  /// Habilita interações
  void enableInteraction() {
    _gameProvider.enableInteraction();
  }
  
  /// Desabilita interações
  void disableInteraction() {
    _gameProvider.disableInteraction();
  }
  
  /// Verifica se pode interagir
  bool get canInteract => _gameProvider.canInteract;
  
  /// Verifica se está processando match
  bool get isProcessingMatch => _gameProvider.isProcessingMatch;
  
  /// Obtém melhor pontuação para dificuldade atual
  int get currentBestScore => _gameProvider.bestScore;
  
  /// Verifica se é novo recorde
  bool get isNewRecord => _gameProvider.isNewRecord();
  
  /// Dispose do controlador
  void dispose() {
    // O Provider será disposed pelo widget que o possui
    debugPrint('MemoryGameController disposed');
  }
}
