// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/view_mode.dart';

class ViewToggleButtons extends StatelessWidget {
  final ViewMode selectedMode;
  final bool isDark;
  final Function(ViewMode) onModeChanged;

  const ViewToggleButtons({
    super.key,
    required this.selectedMode,
    required this.isDark,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleButton(ViewMode.grid, Icons.grid_view_rounded),
        _buildToggleButton(ViewMode.list, Icons.view_list_rounded),
      ],
    );
  }

  Widget _buildToggleButton(ViewMode mode, IconData icon) {
    final bool isSelected = selectedMode == mode;
    final bool isFirstButton = mode == ViewMode.grid;
    
    return InkWell(
      onTap: () => onModeChanged(mode),
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(mode == ViewMode.grid ? 20 : 0),
        right: Radius.circular(mode != ViewMode.grid ? 20 : 0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.green.shade50)
              : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isFirstButton ? 20 : 0),
            right: Radius.circular(!isFirstButton ? 20 : 0),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
      ),
    );
  }
}
