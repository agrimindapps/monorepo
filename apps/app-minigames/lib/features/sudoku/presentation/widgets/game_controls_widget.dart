import 'package:flutter/material.dart';

class GameControlsWidget extends StatelessWidget {
  final bool notesMode;
  final bool canUseHint;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onNotesToggle;
  final VoidCallback onHint;
  final VoidCallback onRestart;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  const GameControlsWidget({
    super.key,
    required this.notesMode,
    required this.canUseHint,
    this.canUndo = false,
    this.canRedo = false,
    required this.onNotesToggle,
    required this.onHint,
    required this.onRestart,
    this.onUndo,
    this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo
          _buildControlButton(
            icon: Icons.undo,
            label: 'Desfazer',
            onTap: canUndo ? onUndo : null,
            isActive: false,
          ),
          // Redo
          _buildControlButton(
            icon: Icons.redo,
            label: 'Refazer',
            onTap: canRedo ? onRedo : null,
            isActive: false,
          ),
          // Notes toggle
          _buildControlButton(
            icon: notesMode ? Icons.edit : Icons.edit_outlined,
            label: 'Notas',
            onTap: onNotesToggle,
            isActive: notesMode,
          ),
          // Hint
          _buildControlButton(
            icon: Icons.lightbulb_outline,
            label: 'Dica',
            onTap: canUseHint ? onHint : null,
            isActive: false,
          ),
          // Restart
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Reiniciar',
            onTap: onRestart,
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isActive,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isActive ? Colors.blue : Colors.grey.shade700,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.blue : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
