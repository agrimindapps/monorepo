// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/generic_search_field_widget.dart';
import '../models/view_mode.dart';
import 'favoritos_view_toggle_buttons.dart';

class FavoritosSearchFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onClear;
  final String hintText;
  final ViewMode selectedViewMode;
  final Function(ViewMode) onToggleViewMode;
  final Function(String)? onChanged;
  final Color? accentColor;
  final bool isSearching;

  const FavoritosSearchFieldWidget({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onClear,
    required this.selectedViewMode,
    required this.onToggleViewMode,
    this.hintText = 'Pesquisar...',
    this.onChanged,
    this.accentColor,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    return GenericSearchFieldWidget(
      controller: controller,
      isDark: isDark,
      onClear: onClear,
      hintText: hintText,
      onChanged: onChanged,
      selectedViewMode: _mapToGenericViewMode(selectedViewMode),
      onToggleViewMode: (mode) =>
          onToggleViewMode(_mapFromGenericViewMode(mode)),
      viewToggleBuilder: (selectedMode, isDark, onModeChanged) =>
          FavoritosViewToggleButtons(
        selectedMode: _mapFromGenericViewMode(selectedMode),
        onToggle: (mode) => onModeChanged(_mapToGenericViewMode(mode)),
        isDark: isDark,
        accentColor: accentColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 12.0,
      backgroundColor: isDark ? const Color(0xFF1E1E22) : Colors.white,
      borderColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
      iconColor: accentColor ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
      textColor: isDark ? Colors.white : Colors.black87,
      hintColor: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
      iconSize: 20.0,
      isSearching: isSearching,
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
