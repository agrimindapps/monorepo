// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/view_mode.dart';
import '../../utils/praga_cultura_constants.dart';

class ViewToggleButtons extends StatelessWidget {
  final ViewMode selectedMode;
  final Function(ViewMode) onToggle;
  final bool isDark;

  const ViewToggleButtons({
    super.key,
    required this.selectedMode,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ViewToggleButton(
          mode: ViewMode.grid,
          selectedMode: selectedMode,
          icon: Icons.grid_view_rounded,
          isFirstButton: true,
          onToggle: onToggle,
          isDark: isDark,
        ),
        ViewToggleButton(
          mode: ViewMode.list,
          selectedMode: selectedMode,
          icon: Icons.view_list_rounded,
          isFirstButton: false,
          onToggle: onToggle,
          isDark: isDark,
        ),
      ],
    );
  }
}

class ViewToggleButton extends StatelessWidget {
  final ViewMode mode;
  final ViewMode selectedMode;
  final IconData icon;
  final bool isFirstButton;
  final Function(ViewMode) onToggle;
  final bool isDark;

  const ViewToggleButton({
    super.key,
    required this.mode,
    required this.selectedMode,
    required this.icon,
    required this.isFirstButton,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedMode == mode;
    final borderRadius = _getBorderRadius();

    return GestureDetector(
      onTap: () => onToggle(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PragaCulturaConstants.smallPadding,
          vertical: PragaCulturaConstants.smallPadding,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor(isSelected),
          borderRadius: borderRadius,
        ),
        child: Icon(
          icon,
          size: PragaCulturaConstants.toggleButtonIconSize,
          color: _getIconColor(isSelected),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    return BorderRadius.horizontal(
      left: Radius.circular(isFirstButton ? PragaCulturaConstants.toggleButtonBorderRadius : 0),
      right: Radius.circular(!isFirstButton ? PragaCulturaConstants.toggleButtonBorderRadius : 0),
    );
  }

  Color _getBackgroundColor(bool isSelected) {
    if (isSelected) {
      return isDark
          ? Colors.green.withValues(alpha: PragaCulturaConstants.overlayOpacity)
          : Colors.green.shade50;
    }
    return Colors.transparent;
  }

  Color _getIconColor(bool isSelected) {
    if (isSelected) {
      return isDark ? Colors.green.shade300 : Colors.green.shade700;
    }
    return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  }
}
