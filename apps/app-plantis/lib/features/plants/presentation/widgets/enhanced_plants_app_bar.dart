import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

/// Enhanced App Bar siguiendo principios SOLID
/// S - Responsabilidad única: Solo maneja la barra superior
/// O - Abierto/cerrado: Extensible para nuevas funcionalidades
/// L - Liskov: Puede ser sustituido por cualquier Widget
/// I - Segregación de interfaces: Interfaces específicas para cada función
/// D - Inversión de dependencias: Depende de abstracciones, no implementaciones

abstract class ISearchDelegate {
  void onSearchChanged(String query);
  void onClearSearch();
}

abstract class IViewModeDelegate {
  void onViewModeChanged(AppBarViewMode mode);
}

enum AppBarViewMode { list, grid }

class EnhancedPlantsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int plantsCount;
  final String searchQuery;
  final AppBarViewMode viewMode;
  final ISearchDelegate searchDelegate;
  final IViewModeDelegate viewModeDelegate;
  final bool showSearchBar;

  const EnhancedPlantsAppBar({
    super.key,
    required this.plantsCount,
    required this.searchQuery,
    required this.viewMode,
    required this.searchDelegate,
    required this.viewModeDelegate,
    this.showSearchBar = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(showSearchBar ? 120 : 80);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _HeaderSection(
              plantsCount: plantsCount,
              theme: theme,
            ),
            if (showSearchBar && plantsCount > 0)
              _SearchSection(
                searchQuery: searchQuery,
                viewMode: viewMode,
                searchDelegate: searchDelegate,
                viewModeDelegate: viewModeDelegate,
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final int plantsCount;
  final ThemeData theme;

  const _HeaderSection({
    required this.plantsCount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Minhas Plantas',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (plantsCount > 0)
            _PlantsCountBadge(
              count: plantsCount,
              theme: theme,
            ),
        ],
      ),
    );
  }
}

class _PlantsCountBadge extends StatelessWidget {
  final int count;
  final ThemeData theme;

  const _PlantsCountBadge({
    required this.count,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: PlantisColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PlantisColors.primary,
          width: 1,
        ),
      ),
      child: Text(
        '$count ${count == 1 ? 'planta' : 'plantas'}',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: PlantisColors.primary,
        ),
      ),
    );
  }
}

class _SearchSection extends StatefulWidget {
  final String searchQuery;
  final AppBarViewMode viewMode;
  final ISearchDelegate searchDelegate;
  final IViewModeDelegate viewModeDelegate;
  final ThemeData theme;

  const _SearchSection({
    required this.searchQuery,
    required this.viewMode,
    required this.searchDelegate,
    required this.viewModeDelegate,
    required this.theme,
  });

  @override
  State<_SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<_SearchSection> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _EnhancedSearchBar(
              controller: _searchController,
              focusNode: _focusNode,
              searchQuery: widget.searchQuery,
              searchDelegate: widget.searchDelegate,
              theme: widget.theme,
            ),
          ),
          const SizedBox(width: 12),
          _ViewModeToggle(
            viewMode: widget.viewMode,
            viewModeDelegate: widget.viewModeDelegate,
            theme: widget.theme,
          ),
        ],
      ),
    );
  }
}

class _EnhancedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String searchQuery;
  final ISearchDelegate searchDelegate;
  final ThemeData theme;

  const _EnhancedSearchBar({
    required this.controller,
    required this.focusNode,
    required this.searchQuery,
    required this.searchDelegate,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: focusNode.hasFocus
            ? Border.all(color: PlantisColors.primary, width: 2)
            : Border.all(color: Colors.transparent),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: searchDelegate.onSearchChanged,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Buscar plantas...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    controller.clear();
                    searchDelegate.onClearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  final AppBarViewMode viewMode;
  final IViewModeDelegate viewModeDelegate;
  final ThemeData theme;

  const _ViewModeToggle({
    required this.viewMode,
    required this.viewModeDelegate,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {
          final newMode = viewMode == AppBarViewMode.list ? AppBarViewMode.grid : AppBarViewMode.list;
          viewModeDelegate.onViewModeChanged(newMode);
        },
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            viewMode == AppBarViewMode.list ? Icons.grid_view : Icons.list,
            key: ValueKey(viewMode),
            color: PlantisColors.primary,
          ),
        ),
        tooltip: viewMode == AppBarViewMode.list
            ? 'Visualizar em grade'
            : 'Visualizar em lista',
      ),
    );
  }
}