import 'package:flutter/material.dart';

import '../../data/defensivos_agrupados_view_mode.dart';
import 'defensivo_agrupado_search_field_widget.dart';

/// Widget especializado de busca para Lista de Defensivos Agrupados
/// Wrapper do DefensivoAgrupadoSearchFieldWidget com lógica específica
class DefensivosAgrupadosSearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final bool isSearching;
  final DefensivosAgrupadosViewMode selectedViewMode;
  final String searchHint;
  final void Function(DefensivosAgrupadosViewMode) onToggleViewMode;
  final VoidCallback onClear;

  const DefensivosAgrupadosSearchWidget({
    super.key,
    required this.controller,
    required this.isDark,
    required this.isSearching,
    required this.selectedViewMode,
    required this.searchHint,
    required this.onToggleViewMode,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return DefensivoAgrupadoSearchFieldWidget(
      controller: controller,
      isDark: isDark,
      isSearching: isSearching,
      selectedViewMode: selectedViewMode,
      onToggleViewMode: onToggleViewMode,
      onClear: onClear,
      hintText: searchHint,
    );
  }
}
