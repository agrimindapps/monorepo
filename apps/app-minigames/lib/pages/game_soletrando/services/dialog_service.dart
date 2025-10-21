// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import '../l10n/soletrando_strings.dart';

/// Resultado dos diálogos
class DialogResult<T> {
  final bool confirmed;
  final T? data;
  
  const DialogResult({
    required this.confirmed,
    this.data,
  });
  
  static DialogResult<T> cancel<T>() => DialogResult<T>(confirmed: false);
  static DialogResult<T> confirm<T>([T? data]) => DialogResult<T>(confirmed: true, data: data);
}

/// Serviço centralizado para gerenciamento de diálogos
/// Desacopla a lógica de diálogos da UI principal
class DialogService {
  static DialogService? _instance;
  
  static DialogService get instance {
    _instance ??= DialogService._();
    return _instance!;
  }
  
  DialogService._();
  
  // Stack de contextos para gerenciar diálogos aninhados
  final List<BuildContext> _contextStack = [];
  
  /// Registra um contexto para uso nos diálogos
  void registerContext(BuildContext context) {
    _contextStack.add(context);
  }
  
  /// Remove um contexto quando não é mais necessário
  void unregisterContext(BuildContext context) {
    _contextStack.remove(context);
  }
  
  /// Obtém o contexto mais recente
  BuildContext? get _currentContext {
    return _contextStack.isNotEmpty ? _contextStack.last : null;
  }
  
  /// Exibe diálogo de fim de jogo
  Future<DialogResult<bool>> showGameOverDialog({
    required bool won,
    required String currentWord,
    required int score,
  }) async {
    final context = _currentContext;
    if (context == null) return DialogResult.cancel();
    
    return await showDialog<DialogResult<bool>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(won ? SoletrandoStrings.gameWon : SoletrandoStrings.gameOverTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(won
                ? 'Você acertou a palavra: $currentWord'
                : 'A palavra era: $currentWord'),
            const SizedBox(height: 8),
            Text('${SoletrandoStrings.gameOverMessage}$score'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text(SoletrandoStrings.newGameButton),
            onPressed: () {
              Navigator.of(context).pop(DialogResult.confirm(true));
            },
          ),
        ],
      ),
    ) ?? DialogResult.cancel();
  }
  
  /// Exibe diálogo de tempo esgotado
  Future<DialogResult<bool>> showTimeOutDialog({
    required String currentWord,
    required int lives,
  }) async {
    final context = _currentContext;
    if (context == null) return DialogResult.cancel();
    
    return await showDialog<DialogResult<bool>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(SoletrandoStrings.timeOutTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(SoletrandoStrings.timeOutMessage),
            const SizedBox(height: 8),
            Text('A palavra era: $currentWord'),
            const SizedBox(height: 16),
            Text(
              '${SoletrandoStrings.livesLabel}: $lives',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: lives == 1 ? Colors.red : null,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text(SoletrandoStrings.continueButton),
            onPressed: () {
              Navigator.of(context).pop(DialogResult.confirm(true));
            },
          ),
        ],
      ),
    ) ?? DialogResult.cancel();
  }
  
  /// Exibe diálogo de seleção de categoria
  Future<DialogResult<WordCategory>> showCategorySelectionDialog({
    required Map<WordCategory, int> categoryProgress,
    required Map<WordCategory, List<String>> wordCategories,
  }) async {
    final context = _currentContext;
    if (context == null) return DialogResult.cancel();
    
    return await showDialog<DialogResult<WordCategory>>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text(SoletrandoStrings.categorySelectionTitle),
        children: WordCategory.values.map((category) {
          final progress = categoryProgress[category] ?? 0;
          final total = wordCategories[category]?.length ?? 0;
          
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context, DialogResult.confirm(category));
            },
            child: ListTile(
              title: Text(category.label),
              trailing: Text('$progress/$total'),
              subtitle: LinearProgressIndicator(
                value: total > 0 ? progress / total : 0,
              ),
            ),
          );
        }).toList(),
      ),
    ) ?? DialogResult.cancel();
  }
  
  /// Exibe diálogo de configurações
  Future<DialogResult<Map<String, dynamic>>> showSettingsDialog({
    required Difficulty currentDifficulty,
    required bool enableAnimations,
    required bool enableSounds,
    required Function(Difficulty) onDifficultyChanged,
    required Function(bool) onAnimationsChanged,
    required Function(bool) onSoundsChanged,
    required VoidCallback onResetProgress,
  }) async {
    final context = _currentContext;
    if (context == null) return DialogResult.cancel();
    
    Difficulty tempDifficulty = currentDifficulty;
    bool tempAnimations = enableAnimations;
    bool tempSounds = enableSounds;
    
    return await showDialog<DialogResult<Map<String, dynamic>>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(SoletrandoStrings.settingsTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seleção de dificuldade
              ListTile(
                title: const Text(SoletrandoStrings.difficultyLevel),
                trailing: DropdownButton<Difficulty>(
                  value: tempDifficulty,
                  onChanged: (Difficulty? newValue) {
                    if (newValue != null) {
                      setDialogState(() {
                        tempDifficulty = newValue;
                      });
                      onDifficultyChanged(newValue);
                    }
                  },
                  items: Difficulty.values
                      .map<DropdownMenuItem<Difficulty>>((Difficulty value) {
                    return DropdownMenuItem<Difficulty>(
                      value: value,
                      child: Text(value.label),
                    );
                  }).toList(),
                ),
              ),
              
              // Configurações visuais
              SwitchListTile(
                title: const Text('Animações'),
                subtitle: const Text('Ativar animações visuais'),
                value: tempAnimations,
                onChanged: (bool value) {
                  setDialogState(() {
                    tempAnimations = value;
                  });
                  onAnimationsChanged(value);
                },
              ),
              
              // Configurações de som
              SwitchListTile(
                title: const Text(SoletrandoStrings.soundEnabled),
                subtitle: const Text('Ativar efeitos sonoros'),
                value: tempSounds,
                onChanged: (bool value) {
                  setDialogState(() {
                    tempSounds = value;
                  });
                  onSoundsChanged(value);
                },
              ),
              
              // Botão de reiniciar progresso
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text(SoletrandoStrings.resetButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _showResetConfirmationDialog(context, onResetProgress);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(SoletrandoStrings.exitButton),
              onPressed: () {
                Navigator.of(context).pop(DialogResult.confirm({
                  'difficulty': tempDifficulty,
                  'animations': tempAnimations,
                  'sounds': tempSounds,
                }));
              },
            ),
          ],
        ),
      ),
    ) ?? DialogResult.cancel();
  }
  
  /// Exibe diálogo de confirmação de reset
  Future<void> _showResetConfirmationDialog(
    BuildContext parentContext, 
    VoidCallback onConfirm,
  ) async {
    final result = await showDialog<bool>(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text(SoletrandoStrings.resetConfirmationTitle),
        content: const Text(SoletrandoStrings.resetConfirmationMessage),
        actions: [
          TextButton(
            child: const Text(SoletrandoStrings.cancelButton),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text(SoletrandoStrings.resetButton),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    
    if (result == true) {
      onConfirm();
      if (parentContext.mounted) {
        Navigator.of(parentContext).pop(); // Fecha o diálogo de configurações
      }
    }
  }
  
  /// Exibe diálogo de erro genérico
  Future<DialogResult<void>> showErrorDialog({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    final context = _currentContext;
    if (context == null) return DialogResult.cancel();
    
    return await showDialog<DialogResult<void>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onAction != null && actionText != null)
            TextButton(
              child: Text(actionText),
              onPressed: () {
                onAction();
                Navigator.of(context).pop(DialogResult.confirm());
              },
            ),
          TextButton(
            child: const Text(SoletrandoStrings.okButton),
            onPressed: () {
              Navigator.of(context).pop(DialogResult.confirm());
            },
          ),
        ],
      ),
    ) ?? DialogResult.cancel();
  }
  
  /// Exibe diálogo de confirmação genérico
  Future<DialogResult<bool>> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = SoletrandoStrings.yesButton,
    String cancelText = SoletrandoStrings.noButton,
  }) async {
    final context = _currentContext;
    if (context == null) return DialogResult.cancel();
    
    return await showDialog<DialogResult<bool>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text(cancelText),
            onPressed: () {
              Navigator.of(context).pop(DialogResult.cancel());
            },
          ),
          TextButton(
            child: Text(confirmText),
            onPressed: () {
              Navigator.of(context).pop(DialogResult.confirm(true));
            },
          ),
        ],
      ),
    ) ?? DialogResult.cancel();
  }
  
  /// Exibe loading dialog
  void showLoadingDialog({String? message}) {
    final context = _currentContext;
    if (context == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? 'Carregando...'),
          ],
        ),
      ),
    );
  }
  
  /// Fecha o diálogo mais recente
  void dismissDialog() {
    final context = _currentContext;
    if (context != null && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
  
  /// Fecha todos os diálogos
  void dismissAllDialogs() {
    for (final context in _contextStack.reversed) {
      while (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }
}

/// Widget helper para registrar automaticamente o contexto
class DialogContextProvider extends StatefulWidget {
  final Widget child;
  
  const DialogContextProvider({
    super.key,
    required this.child,
  });
  
  @override
  State<DialogContextProvider> createState() => _DialogContextProviderState();
}

class _DialogContextProviderState extends State<DialogContextProvider> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DialogService.instance.registerContext(context);
    });
  }
  
  @override
  void dispose() {
    DialogService.instance.unregisterContext(context);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
