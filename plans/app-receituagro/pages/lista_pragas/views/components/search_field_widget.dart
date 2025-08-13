// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../widgets/generic_search_field_widget.dart';
import '../../models/view_mode.dart';
import '../../utils/praga_constants.dart';
import '../../utils/praga_utils.dart';
import '../widgets/view_toggle_buttons.dart';

class SearchFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String pragaType;
  final bool isDark;
  final ViewMode viewMode;
  final Function(ViewMode) onViewModeChanged;
  final VoidCallback onClear;
  final Function(String)? onChanged;

  const SearchFieldWidget({
    super.key,
    required this.controller,
    required this.pragaType,
    required this.isDark,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onClear,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GenericSearchFieldWidget(
      controller: controller,
      isDark: isDark,
      onClear: onClear,
      onChanged: onChanged,
      hintText: PragaUtils.getSearchHint(pragaType),
      selectedViewMode: _mapToGenericViewMode(viewMode),
      onToggleViewMode: (mode) =>
          onViewModeChanged(_mapFromGenericViewMode(mode)),
      viewToggleBuilder: (selectedMode, isDark, onModeChanged) =>
          ViewToggleButtons(
        selectedMode: _mapFromGenericViewMode(selectedMode),
        isDark: isDark,
        onModeChanged: (mode) => onModeChanged(_mapToGenericViewMode(mode)),
      ),
      padding: PragaConstants.searchFieldPadding,
      borderRadius: PragaConstants.searchFieldRadius,
      backgroundColor: isDark ? PragaConstants.darkCardColor : Colors.white,
      borderColor: isDark ? Colors.grey.shade800 : Colors.green.shade200,
      iconColor: isDark ? Colors.green.shade300 : Colors.green.shade700,
      textColor: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
      hintColor: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
      iconSize: PragaConstants.mediumIconSize,
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
