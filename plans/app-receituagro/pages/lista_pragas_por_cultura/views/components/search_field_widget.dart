// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../widgets/generic_search_field_widget.dart';
import '../../models/view_mode.dart';
import '../../utils/praga_cultura_constants.dart';
import '../widgets/view_toggle_buttons.dart';

class SearchFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onClear;
  final String hintText;
  final ViewMode selectedViewMode;
  final Function(ViewMode) onToggleViewMode;
  final Function(String)? onChanged;

  const SearchFieldWidget({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onClear,
    required this.selectedViewMode,
    required this.onToggleViewMode,
    this.hintText = PragaCulturaConstants.searchHintText,
    this.onChanged,
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
          ViewToggleButtons(
        selectedMode: _mapFromGenericViewMode(selectedMode),
        onToggle: (mode) => onModeChanged(_mapToGenericViewMode(mode)),
        isDark: isDark,
      ),
      padding: EdgeInsets.zero,
      borderRadius: PragaCulturaConstants.searchFieldRadius,
      backgroundColor:
          isDark ? PragaCulturaConstants.darkCardColor : Colors.white,
      borderColor: Colors.transparent,
      iconColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      textColor: isDark ? Colors.white : Colors.black87,
      hintColor: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
      iconSize: PragaCulturaConstants.searchIconSize,
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
