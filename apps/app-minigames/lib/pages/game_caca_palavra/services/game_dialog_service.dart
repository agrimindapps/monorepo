// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/widgets/dialogs/dialogs.dart';

/// Gerenciador de diálogos com controle centralizado de ciclo de vida
class DialogManager {
  static final Map<String, bool> _activeDialogs = {};
  static final Map<String, VoidCallback?> _pendingCallbacks = {};

  /// Registra um diálogo como ativo
  static void _registerDialog(String dialogId) {
    _activeDialogs[dialogId] = true;
  }

  /// Remove um diálogo da lista de ativos
  static void _unregisterDialog(String dialogId) {
    _activeDialogs.remove(dialogId);
    _pendingCallbacks.remove(dialogId);
  }

  /// Verifica se um diálogo específico está ativo
  static bool isDialogActive(String dialogId) {
    return _activeDialogs[dialogId] ?? false;
  }

  /// Verifica se há algum diálogo ativo
  static bool get hasActiveDialogs => _activeDialogs.isNotEmpty;

  /// Limpa todos os diálogos ativos
  static void clearAll() {
    _activeDialogs.clear();
    _pendingCallbacks.clear();
  }

  /// Exibe um diálogo de forma segura com controle de ciclo de vida
  static Future<T?> showManagedDialog<T>({
    required BuildContext context,
    required String dialogId,
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
    VoidCallback? onDismiss,
  }) async {
    if (!context.mounted || isDialogActive(dialogId)) return null;

    _registerDialog(dialogId);
    _pendingCallbacks[dialogId] = onDismiss;

    try {
      final result = await showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: builder,
      );

      // Executa callback de dismiss se definido
      _pendingCallbacks[dialogId]?.call();
      
      return result;
    } finally {
      _unregisterDialog(dialogId);
    }
  }
}

/// Serviço responsável por gerenciar a exibição de diálogos do jogo
/// Agora utiliza o DialogManager para controle centralizado do ciclo de vida
class GameDialogService {
  static const String _victoryDialogId = 'victory_dialog';
  static const String _instructionsDialogId = 'instructions_dialog';
  static const String _confirmDifficultyDialogId = 'confirm_difficulty_dialog';

  /// Exibe o diálogo de vitória de forma segura, evitando múltiplas exibições
  static Future<void> showVictoryDialog({
    required BuildContext context,
    required GameDifficulty difficulty,
    required int wordsFound,
    required VoidCallback onPlayAgain,
    required VoidCallback onExit,
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    if (!context.mounted || DialogManager.isDialogActive(_victoryDialogId)) return;

    // Aguarda um frame antes de exibir o diálogo para garantir que a UI esteja estável
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!context.mounted) return;

    await DialogManager.showManagedDialog(
      context: context,
      dialogId: _victoryDialogId,
      barrierDismissible: false,
      builder: (context) => VictoryDialog(
        difficulty: difficulty,
        wordsFound: wordsFound,
        onPlayAgain: onPlayAgain,
        onExit: onExit,
      ),
    );
  }

  /// Exibe o diálogo de instruções
  static Future<void> showInstructionsDialog(BuildContext context) async {
    if (!context.mounted || DialogManager.isDialogActive(_instructionsDialogId)) return;

    await DialogManager.showManagedDialog(
      context: context,
      dialogId: _instructionsDialogId,
      builder: (context) => const InstructionsDialog(),
    );
  }

  /// Exibe o diálogo de confirmação para mudança de dificuldade
  static Future<void> showConfirmDifficultyChangeDialog({
    required BuildContext context,
    required GameDifficulty newDifficulty,
    required VoidCallback onConfirm,
  }) async {
    if (!context.mounted || DialogManager.isDialogActive(_confirmDifficultyDialogId)) return;

    await DialogManager.showManagedDialog(
      context: context,
      dialogId: _confirmDifficultyDialogId,
      builder: (context) => ConfirmDifficultyChangeDialog(
        newDifficulty: newDifficulty,
        onConfirm: onConfirm,
      ),
    );
  }

  /// Força o reset de todos os diálogos (útil para limpeza em dispose ou restart)
  static void resetFlags() {
    DialogManager.clearAll();
  }

  /// Verifica se o diálogo de vitória está sendo exibido
  static bool get isVictoryDialogShowing => DialogManager.isDialogActive(_victoryDialogId);

  /// Verifica se há algum diálogo ativo
  static bool get hasActiveDialogs => DialogManager.hasActiveDialogs;
}
