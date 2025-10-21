// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_minigames/constants/enums.dart';
import 'package:app_minigames/utils/format_utils.dart';

/// Widget responsável por gerenciar os controles do jogo 2048
/// Inclui dropdowns para esquema de cores, tamanho do tabuleiro e botão de novo jogo
class GameControlsWidget extends StatelessWidget {
  final int currentScore;
  final int highScore;
  final TileColorScheme currentColorScheme;
  final BoardSize currentBoardSize;
  final bool enabled;
  final int moveCount;
  final Duration gameDuration;
  final Function(TileColorScheme) onColorSchemeChanged;
  final Function(BoardSize) onBoardSizeChanged;
  final VoidCallback onNewGame;
  final VoidCallback? onTogglePause;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onShowSettings;
  final bool isPaused;
  final bool canUndo;
  final bool canRedo;

  const GameControlsWidget({
    super.key,
    required this.currentScore,
    required this.highScore,
    required this.currentColorScheme,
    required this.currentBoardSize,
    this.enabled = true,
    required this.moveCount,
    required this.gameDuration,
    required this.onColorSchemeChanged,
    required this.onBoardSizeChanged,
    required this.onNewGame,
    this.onTogglePause,
    this.onUndo,
    this.onRedo,
    this.onShowSettings,
    this.isPaused = false,
    this.canUndo = false,
    this.canRedo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Score Display
            _buildScoreDisplay(),
            const SizedBox(height: 16),
            // Controls Row
            _buildControlsRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.stars,
          color: Colors.amber,
          size: 28,
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            Text(
              'Pontuação: $currentScore',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Recorde: $highScore',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.swipe, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Movimentos: $moveCount',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.timer, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Tempo: ${FormatUtils.formatDuration(gameDuration)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlsRow(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildColorSchemeDropdown(),
        _buildBoardSizeDropdown(),
        _buildNewGameButton(),
        if (onTogglePause != null) _buildPauseButton(),
        _buildUndoRedoButtons(context),
        if (onShowSettings != null) _buildSettingsButton(),
      ],
    );
  }

  Widget _buildColorSchemeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.palette, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          DropdownButton<TileColorScheme>(
            value: currentColorScheme,
            underline: const SizedBox(),
            items: TileColorScheme.values.map((scheme) {
              return DropdownMenuItem(
                value: scheme,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: scheme.baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(scheme.label),
                  ],
                ),
              );
            }).toList(),
            onChanged: enabled
                ? (newScheme) {
                    if (newScheme != null) {
                      onColorSchemeChanged(newScheme);
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBoardSizeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.grid_view, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          DropdownButton<BoardSize>(
            value: currentBoardSize,
            underline: const SizedBox(),
            items: BoardSize.values.map((size) {
              return DropdownMenuItem(
                value: size,
                child: Text(size.label),
              );
            }).toList(),
            onChanged: enabled
                ? (newSize) {
                    if (newSize != null) {
                      onBoardSizeChanged(newSize);
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNewGameButton() {
    return ElevatedButton.icon(
      onPressed: enabled ? onNewGame : null,
      icon: const Icon(Icons.refresh),
      label: const Text('Novo Jogo'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPauseButton() {
    return ElevatedButton.icon(
      onPressed: enabled ? onTogglePause : null,
      icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
      label: Text(isPaused ? 'Continuar' : 'Pausar'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: isPaused ? Colors.green : Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildUndoRedoButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botão Undo
        IconButton(
          onPressed: enabled && canUndo && onUndo != null ? onUndo : null,
          icon: const Icon(Icons.undo),
          tooltip: 'Desfazer movimento',
          style: IconButton.styleFrom(
            backgroundColor: canUndo 
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.grey.shade200,
            foregroundColor: canUndo 
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Colors.grey.shade500,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Botão Redo
        IconButton(
          onPressed: enabled && canRedo && onRedo != null ? onRedo : null,
          icon: const Icon(Icons.redo),
          tooltip: 'Refazer movimento',
          style: IconButton.styleFrom(
            backgroundColor: canRedo 
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.grey.shade200,
            foregroundColor: canRedo 
                ? Theme.of(context).colorScheme.onSecondaryContainer
                : Colors.grey.shade500,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsButton() {
    return IconButton(
      onPressed: enabled ? onShowSettings : null,
      icon: const Icon(Icons.settings),
      tooltip: 'Configurações',
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.grey.shade700,
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
