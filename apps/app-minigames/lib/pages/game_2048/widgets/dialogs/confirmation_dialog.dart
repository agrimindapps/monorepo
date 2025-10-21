// Flutter imports:
import 'package:flutter/material.dart';

enum ConfirmationType {
  newGame,
  changeBoardSize,
  exitGame,
}

class ProgressInfo {
  final int score;
  final int moveCount;
  final String duration;
  final bool isHighScore;

  const ProgressInfo({
    required this.score,
    required this.moveCount,
    required this.duration,
    this.isHighScore = false,
  });
}

class ConfirmationDialog extends StatelessWidget {
  final ConfirmationType type;
  final ProgressInfo progressInfo;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String? customMessage;

  const ConfirmationDialog({
    super.key,
    required this.type,
    required this.progressInfo,
    required this.onConfirm,
    this.onCancel,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            _getIcon(),
            color: theme.colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getTitle(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customMessage ?? _getMessage(),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _buildProgressSummary(context),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: Text(_getConfirmButtonText()),
        ),
      ],
    );
  }

  IconData _getIcon() {
    switch (type) {
      case ConfirmationType.newGame:
        return Icons.refresh;
      case ConfirmationType.changeBoardSize:
        return Icons.grid_view;
      case ConfirmationType.exitGame:
        return Icons.exit_to_app;
    }
  }

  String _getTitle() {
    switch (type) {
      case ConfirmationType.newGame:
        return 'Iniciar Novo Jogo?';
      case ConfirmationType.changeBoardSize:
        return 'Alterar Tamanho do Tabuleiro?';
      case ConfirmationType.exitGame:
        return 'Sair do Jogo?';
    }
  }

  String _getMessage() {
    switch (type) {
      case ConfirmationType.newGame:
        return 'Você perderá todo o progresso atual. Tem certeza que deseja iniciar um novo jogo?';
      case ConfirmationType.changeBoardSize:
        return 'Alterar o tamanho do tabuleiro irá iniciar um novo jogo e você perderá todo o progresso atual.';
      case ConfirmationType.exitGame:
        return 'Você tem progresso não salvo. Tem certeza que deseja sair?';
    }
  }

  String _getConfirmButtonText() {
    switch (type) {
      case ConfirmationType.newGame:
        return 'Novo Jogo';
      case ConfirmationType.changeBoardSize:
        return 'Alterar';
      case ConfirmationType.exitGame:
        return 'Sair';
    }
  }

  Widget _buildProgressSummary(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progresso Atual:',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressItem(
                context,
                'Pontuação',
                progressInfo.score.toString(),
                progressInfo.isHighScore,
              ),
              _buildProgressItem(
                context,
                'Movimentos',
                progressInfo.moveCount.toString(),
                false,
              ),
              _buildProgressItem(
                context,
                'Tempo',
                progressInfo.duration,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String label,
    String value,
    bool isHighlighted,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isHighlighted
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
            if (isHighlighted) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.star,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required ConfirmationType type,
    required ProgressInfo progressInfo,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String? customMessage,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        type: type,
        progressInfo: progressInfo,
        onConfirm: onConfirm,
        onCancel: onCancel,
        customMessage: customMessage,
      ),
    );
  }
}
