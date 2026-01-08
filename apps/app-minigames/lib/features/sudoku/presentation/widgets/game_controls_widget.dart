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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
            isDark: isDark,
          ),
          // Redo
          _buildControlButton(
            icon: Icons.redo,
            label: 'Refazer',
            onTap: canRedo ? onRedo : null,
            isActive: false,
            isDark: isDark,
          ),
          // Notes toggle
          _buildControlButton(
            icon: notesMode ? Icons.edit : Icons.edit_outlined,
            label: 'Notas',
            onTap: onNotesToggle,
            isActive: notesMode,
            isDark: isDark,
          ),
          // Hint
          _buildControlButton(
            icon: Icons.lightbulb_outline,
            label: 'Dica',
            onTap: canUseHint ? onHint : null,
            isActive: false,
            isDark: isDark,
          ),
          // Restart
          _buildControlButton(
            icon: Icons.refresh,
            label: 'Reiniciar',
            onTap: onRestart,
            isActive: false,
            isDark: isDark,
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
    required bool isDark,
  }) {
    final activeColor = isDark ? const Color(0xFF9C7CF2) : Colors.blue;
    final inactiveColor = isDark ? Colors.white70 : Colors.grey.shade700;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Opacity(
          opacity: onTap == null ? 0.4 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: isActive ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
