// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/models/game_logic.dart';
import 'package:app_minigames/models/word.dart';

class GameProvider extends ChangeNotifier {
  late CacaPalavrasLogic gameLogic;
  bool showInstructions = false;

  // Estado do diálogo de vitória simplificado
  bool _showVictoryDialog = false;

  // Debounce para toques nas células
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 100);

  GameProvider() {
    gameLogic = CacaPalavrasLogic();
  }

  // Manipula o toque em uma célula do grid com debounce
  void handleCellTap(int row, int col) {
    // Cancela o timer anterior se existir
    _debounceTimer?.cancel();

    // Cria um novo timer para executar o toque após o delay
    _debounceTimer = Timer(_debounceDuration, () {
      _executeCellTap(row, col);
    });
  }

  // Executa o toque na célula (método privado)
  void _executeCellTap(int row, int col) {
    if (gameLogic.isGameOver) return;

    HapticFeedback.selectionClick();

    gameLogic.selectPosition(row, col);

    // Verifica se uma palavra foi encontrada apenas se houver posições selecionadas
    if (gameLogic.selectedPositions.length > 1) {
      final foundWordBefore = gameLogic.foundWords;
      gameLogic.checkSelection();

      // Verifica se encontrou uma nova palavra
      if (gameLogic.foundWords > foundWordBefore) {
        HapticFeedback
            .mediumImpact(); // Feedback tátil ao encontrar uma palavra
      }
    }

    // Verifica se o jogo terminou para ativar o diálogo de vitória
    if (gameLogic.isGameOver && !_showVictoryDialog) {
      _showVictoryDialog = true;
    }

    notifyListeners();
  }

  // Manipula o toque em uma palavra da lista
  void handleWordTap(int index) {
    // Atualiza todas as palavras primeiro para remover outros destaques
    for (int i = 0; i < gameLogic.words.length; i++) {
      gameLogic.words[i] = gameLogic.words[i].copyWith(
        isHighlighted: false,
      );
    }

    // Destaca a palavra selecionada se ela ainda não foi encontrada
    final word = gameLogic.words[index];
    if (!word.isFound) {
      gameLogic.words[index] = word.copyWith(
        isHighlighted: !word.isHighlighted,
      );
    }

    notifyListeners();
  }

  // Reinicia o jogo
  void restartGame({GameDifficulty? newDifficulty}) {
    _debounceTimer?.cancel(); // Cancela qualquer timer pendente
    gameLogic.restartGame(newDifficulty: newDifficulty);
    _resetVictoryDialogState();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // Limpa o timer ao descartar o provider
    super.dispose();
  }

  // ========== Gerenciamento do estado do diálogo de vitória ==========

  /// Reseta o estado do diálogo de vitória
  ///
  /// Método privado chamado automaticamente quando o jogo é reiniciado
  void _resetVictoryDialogState() {
    _showVictoryDialog = false;
  }

  /// Força o reset do estado do diálogo (útil para limpeza)
  ///
  /// Este método pode ser chamado externamente quando necessário
  /// resetar manualmente o estado dos diálogos
  void resetVictoryDialogState() {
    _resetVictoryDialogState();
    notifyListeners();
  }

  // ========== Getters para estado do jogo ==========

  // Verificações de estado do jogo
  bool get isGameOver => gameLogic.isGameOver;
  int get foundWords => gameLogic.foundWords;
  List<Word> get words => gameLogic.words;
  GameDifficulty get difficulty => gameLogic.difficulty;
  double get progress => gameLogic.progress;

  // Estado do diálogo de vitória

  /// Determina se o diálogo de vitória deve ser exibido
  ///
  /// Retorna true quando o jogo terminou e o diálogo ainda não foi marcado para exibição
  bool get shouldShowVictoryDialog => _showVictoryDialog;

  /// Marca que o diálogo foi exibido e reseta o estado
  void markVictoryDialogShown() {
    _showVictoryDialog = false;
  }
}
