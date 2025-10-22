import 'package:flutter/material.dart';

class GameControlsWidget extends StatelessWidget {
  final bool notesMode;
  final bool canUseHint;
  final VoidCallback onNotesToggle;
  final VoidCallback onHint;
  final VoidCallback onRestart;

  const GameControlsWidget({
    super.key,
    required this.notesMode,
    required this.canUseHint,
    required this.onNotesToggle,
    required this.onHint,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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
              size: 32,
              color: isActive ? Colors.blue : Colors.grey.shade700,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.blue : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
