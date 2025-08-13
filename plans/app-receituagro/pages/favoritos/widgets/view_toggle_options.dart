// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../constants/favoritos_design_tokens.dart';
import '../models/view_mode.dart';

class ViewToggleOptions extends StatelessWidget {
  final ViewMode currentMode;
  final Function(ViewMode) onModeChanged;
  final Color activeColor;

  const ViewToggleOptions({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(FavoritosDesignTokens.defaultBorderRadius),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            icon: FontAwesome.list_solid,
            mode: ViewMode.list,
            tooltip: 'Visualização em lista',
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 32,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          _buildToggleButton(
            icon: Icons.grid_view,
            mode: ViewMode.grid,
            tooltip: 'Visualização em grade',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required ViewMode mode,
    required String tooltip,
    required bool isDark,
  }) {
    final isActive = currentMode == mode;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onModeChanged(mode),
          borderRadius:
              BorderRadius.circular(FavoritosDesignTokens.defaultBorderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(
              horizontal: FavoritosDesignTokens.mediumSpacing,
              vertical: FavoritosDesignTokens.defaultSpacing,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                  FavoritosDesignTokens.defaultBorderRadius),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                icon,
                key: ValueKey('$mode-$isActive'),
                size: FavoritosDesignTokens.defaultIconSize,
                color: isActive
                    ? activeColor
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
