// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/generic_search_field_widget.dart';
import '../models/view_mode.dart';

class FavoritosSearchFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onClear;
  final String hintText;
  final ViewMode selectedViewMode;
  final Function(ViewMode) onToggleViewMode;
  final Function(String)? onChanged;
  final Color? accentColor;

  const FavoritosSearchFieldWidget({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onClear,
    required this.selectedViewMode,
    required this.onToggleViewMode,
    this.hintText = 'Localizar...',
    this.onChanged,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: GenericSearchFieldWidget(
        controller: controller,
        isDark: isDark,
        onClear: onClear,
        hintText: hintText,
        onChanged: onChanged,
        selectedViewMode: _mapToGenericViewMode(selectedViewMode),
        onToggleViewMode: (mode) =>
            onToggleViewMode(_mapFromGenericViewMode(mode)),
        padding: EdgeInsets.zero,
        borderRadius: 12.0,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        borderColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        iconColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        textColor: isDark ? Colors.white : Colors.black87,
        hintColor: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
        iconSize: 20.0,
        viewToggleBuilder: (selectedMode, isDark, onModeChanged) =>
            _buildViewToggleButtons(selectedMode, isDark, onModeChanged),
      ),
    );
  }

  Widget _buildViewToggleButtons(SearchViewMode selectedMode, bool isDark, Function(SearchViewMode) onModeChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleButton(SearchViewMode.grid, Icons.grid_view_rounded, selectedMode, isDark, onModeChanged),
        _buildToggleButton(SearchViewMode.list, Icons.view_list_rounded, selectedMode, isDark, onModeChanged),
      ],
    );
  }

  Widget _buildToggleButton(SearchViewMode mode, IconData icon, SearchViewMode selectedMode, bool isDark, Function(SearchViewMode) onModeChanged) {
    final bool isSelected = selectedMode == mode;
    final bool isFirstButton = mode == SearchViewMode.grid;
    
    return InkWell(
      onTap: () => onModeChanged(mode),
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(mode == SearchViewMode.grid ? 20 : 0),
        right: Radius.circular(mode != SearchViewMode.grid ? 20 : 0),
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

  SearchViewMode _mapToGenericViewMode(ViewMode mode) {
    switch (mode) {
      case ViewMode.grid:
        return SearchViewMode.grid;
      case ViewMode.list:
        return SearchViewMode.list;
    }
  }

  ViewMode _mapFromGenericViewMode(SearchViewMode mode) {
    switch (mode) {
      case SearchViewMode.grid:
        return ViewMode.grid;
      case SearchViewMode.list:
        return ViewMode.list;
    }
  }
}
