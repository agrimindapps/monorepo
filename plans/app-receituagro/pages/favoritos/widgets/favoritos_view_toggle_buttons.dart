// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/view_mode.dart';

class FavoritosViewToggleButtons extends StatelessWidget {
  final ViewMode selectedMode;
  final Function(ViewMode) onToggle;
  final bool isDark;
  final Color? accentColor;

  const FavoritosViewToggleButtons({
    super.key,
    required this.selectedMode,
    required this.onToggle,
    required this.isDark,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleButton(
          icon: Icons.list,
          mode: ViewMode.list,
          isSelected: selectedMode == ViewMode.list,
        ),
        const SizedBox(width: 4),
        _buildToggleButton(
          icon: Icons.grid_view,
          mode: ViewMode.grid,
          isSelected: selectedMode == ViewMode.grid,
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required ViewMode mode,
    required bool isSelected,
  }) {
    final color = accentColor ?? (isDark ? Colors.green.shade300 : Colors.green.shade700);
    
    return GestureDetector(
      onTap: () => onToggle(mode),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? color
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
      ),
    );
  }
}
