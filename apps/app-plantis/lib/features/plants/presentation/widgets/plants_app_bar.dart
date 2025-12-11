import 'package:flutter/material.dart';
import '../../../../core/providers/plants_providers.dart' show ViewMode;

class PlantsAppBar extends StatefulWidget {
  final int plantsCount;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;

  const PlantsAppBar({
    super.key,
    required this.plantsCount,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  State<PlantsAppBar> createState() => _PlantsAppBarState();
}

class _PlantsAppBarState extends State<PlantsAppBar> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _searchFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant PlantsAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the controller when the incoming query actually differs
    // from the controller text. Avoid overwriting while the user is typing
    // (i.e. when the field has focus) because that can select/replace
    // the current content and cause a new keystroke to erase it.
    if (oldWidget.searchQuery != widget.searchQuery) {
      final incoming = widget.searchQuery;
      if (_searchController.text != incoming) {
        // If the field doesn't have focus, safely update the text and
        // place the caret at the end.
        if (!_searchFocusNode.hasFocus) {
          _searchController.value = TextEditingValue(
            text: incoming,
            selection: TextSelection.collapsed(offset: incoming.length),
          );
        } else {
          // If the field has focus, only update when clearing the text.
          // This covers programmatic clears (user pressed clear button)
          // while avoiding interference during user typing.
          if (incoming.isEmpty) {
            _searchController.clear();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark
          ? const Color(0xFF1C1C1E)
          : Colors
                .transparent, // Transparente para usar o fundo do BasePageScaffold
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFFFFFFF), // Branco puro
                    borderRadius: BorderRadius.circular(12),
                    border: isDark
                        ? Border.all(color: Colors.grey.withValues(alpha: 0.1))
                        : Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: isDark ? 6 : 8,
                        offset: const Offset(0, 2),
                        spreadRadius: isDark ? 0 : 1,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: widget.onSearchChanged,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Buscar plantas...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 16,
                      ),
                      prefixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.local_florist,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            size: 20,
                          ),
                        ],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  ViewMode newMode;
                  if (widget.viewMode == ViewMode.groupedBySpaces ||
                      widget.viewMode == ViewMode.groupedBySpacesGrid) {
                    newMode = ViewMode.groupedBySpacesList;
                  } else if (widget.viewMode == ViewMode.groupedBySpacesList) {
                    newMode = ViewMode.groupedBySpacesGrid;
                  } else {
                    newMode = widget.viewMode == ViewMode.grid
                        ? ViewMode.list
                        : ViewMode.grid;
                  }

                  widget.onViewModeChanged(newMode);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFFFFFFF), // Branco puro
                    borderRadius: BorderRadius.circular(12),
                    border: isDark
                        ? Border.all(color: Colors.grey.withValues(alpha: 0.1))
                        : Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.3,
                            ),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: isDark ? 6 : 8,
                        offset: const Offset(0, 2),
                        spreadRadius: isDark ? 0 : 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getToggleIcon(widget.viewMode),
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Retorna o ícone apropriado baseado no modo atual
  IconData _getToggleIcon(ViewMode currentMode) {
    switch (currentMode) {
      case ViewMode.grid:
      case ViewMode.groupedBySpacesGrid:
      case ViewMode.groupedBySpaces: // groupedBySpaces padrão é grid
        return Icons.view_list; // Mostra lista para alternar para lista
      case ViewMode.list:
      case ViewMode.groupedBySpacesList:
        return Icons.grid_view; // Mostra grid para alternar para grid
    }
  }
}
