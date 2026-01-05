import 'package:core/core.dart' hide SortBy, Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/plants_providers.dart' show ViewMode, SortBy, PlantsState;
import '../../../../core/providers/plants_providers.dart' as riverpod_plants;
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/plant.dart';
import '../managers/plants_managers_providers.dart';
import '../widgets/empty_plants_widget.dart';
import '../widgets/plants_app_bar.dart';
import '../widgets/plants_error_widget.dart';
import '../widgets/plants_fab.dart';
import '../widgets/plants_grid_view.dart';
import '../widgets/plants_grouped_by_spaces_view.dart';
import '../widgets/plants_list_view.dart';
import '../widgets/plants_loading_widget.dart';

/// Plants List Page - Clean Architecture View Layer
///
/// REFACTORED: Reduced from 8 Consumer widgets to 1 main ConsumerStatefulWidget
/// to fix the `_dependents.isEmpty is not true` assertion error.
///
/// The error was caused by too many nested Consumer widgets competing for
/// InheritedWidget dependencies during widget tree rebuilds.
class PlantsListPage extends ConsumerStatefulWidget {
  const PlantsListPage({super.key});

  @override
  ConsumerState<PlantsListPage> createState() => _PlantsListPageState();
}

class _PlantsListPageState extends ConsumerState<PlantsListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasAttemptedInitialLoad = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryStartAutoSync();
    });
  }

  void _tryStartAutoSync() {
    final authState = ref.read(authProvider);
    if (authState.hasValue &&
        authState.value!.isAuthenticated &&
        !authState.value!.isAnonymous) {
      // Background sync is handled by PlantsNotifier
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref
        .read(riverpod_plants.plantsNotifierProvider.notifier)
        .refreshPlants();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      ref.read(riverpod_plants.plantsNotifierProvider.notifier).clearSearch();
    } else {
      ref
          .read(riverpod_plants.plantsNotifierProvider.notifier)
          .searchPlants(query);
    }
  }

  void _onViewModeChanged(ViewMode mode) {
    ref.read(riverpod_plants.plantsNotifierProvider.notifier).setViewMode(mode);
  }

  void _onSortChanged(SortBy sort) {
    ref.read(riverpod_plants.plantsNotifierProvider.notifier).setSortBy(sort);
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Single watch point for the entire plants state
    final plantsAsync = ref.watch(riverpod_plants.plantsNotifierProvider);
    
    // Trigger initial load if needed
    _checkAndTriggerInitialLoad(plantsAsync);

    return BasePageScaffold(
      body: ResponsiveLayout(
        child: Column(
          children: [
            _buildHeader(plantsAsync),
            _buildAppBar(plantsAsync),
            Expanded(child: _buildContent(plantsAsync)),
          ],
        ),
      ),
      floatingActionButton: PlantsFab(
        onScrollToTop: _scrollToTop,
        scrollController: _scrollController,
      ),
    );
  }
  
  void _checkAndTriggerInitialLoad(AsyncValue<PlantsState> plantsAsync) {
    plantsAsync.whenData((state) {
      if (state.allPlants.isEmpty &&
          !state.isLoading &&
          state.error == null &&
          !_hasAttemptedInitialLoad) {
        _hasAttemptedInitialLoad = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref
                .read(riverpod_plants.plantsNotifierProvider.notifier)
                .loadInitialData();
          }
        });
      }
    });
  }

  Widget _buildHeader(AsyncValue<PlantsState> plantsAsync) {
    return plantsAsync.when(
      data: (state) => PlantisHeader(
        title: 'Minhas Plantas',
        subtitle: '${state.allPlants.length} plantas no jardim',
        leading: Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.eco, color: Colors.white, size: 24),
        ),
        actions: [
          _buildSortButton(state),
          _buildGroupButton(state),
        ],
      ),
      loading: () => PlantisHeader(
        title: 'Minhas Plantas',
        subtitle: 'Carregando suas plantas...',
        leading: Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
      error: (error, _) => PlantisHeader(
        title: 'Minhas Plantas',
        subtitle: 'Toque para tentar novamente',
        leading: GestureDetector(
          onTap: () => ref
              .read(riverpod_plants.plantsNotifierProvider.notifier)
              .refreshPlants(),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(AsyncValue<PlantsState> plantsAsync) {
    final appBarData = plantsAsync.when(
      data: (state) => (
        plantsCount: state.allPlants.length,
        searchQuery: state.searchQuery,
        viewMode: state.viewMode,
      ),
      loading: () => (
        plantsCount: 0,
        searchQuery: '',
        viewMode: ViewMode.list,
      ),
      error: (_, __) => (
        plantsCount: 0,
        searchQuery: '',
        viewMode: ViewMode.list,
      ),
    );
    
    return PlantsAppBar(
      plantsCount: appBarData.plantsCount,
      searchQuery: appBarData.searchQuery,
      onSearchChanged: _onSearchChanged,
      viewMode: appBarData.viewMode,
      onViewModeChanged: _onViewModeChanged,
    );
  }

  Widget _buildContent(AsyncValue<PlantsState> plantsAsync) {
    return plantsAsync.when(
      loading: () => const PlantsLoadingWidget(),
      error: (error, _) => PlantsErrorWidget(
        error: error.toString(),
        onRetry: () => ref
            .read(riverpod_plants.plantsNotifierProvider.notifier)
            .loadInitialData(),
      ),
      data: (state) {
        // Show loading overlay if loading with existing data
        if (state.isLoading && state.allPlants.isEmpty) {
          return const PlantsLoadingWidget();
        }
        
        if (state.isLoading && state.allPlants.isNotEmpty) {
          return Stack(
            children: [
              _buildPlantsView(state),
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }
        
        if (state.error != null) {
          return PlantsErrorWidget(
            error: state.error!,
            onRetry: () => ref
                .read(riverpod_plants.plantsNotifierProvider.notifier)
                .loadInitialData(),
          );
        }
        
        return _buildPlantsView(state);
      },
    );
  }

  Widget _buildPlantsView(PlantsState state) {
    // Determine which plants to display
    final List<Plant> displayPlants;
    final bool isSearching = state.searchQuery.isNotEmpty;
    
    if (isSearching) {
      displayPlants = state.searchResults;
    } else if (state.filterBySpace != null) {
      displayPlants = state.filteredPlants;
    } else {
      displayPlants = state.allPlants;
    }

    if (kDebugMode) {
      debugPrint('🔍 PlantsListPage: Displaying ${displayPlants.length} plants');
    }

    if (displayPlants.isEmpty) {
      return EmptyPlantsWidget(
        isSearching: isSearching,
        searchQuery: state.searchQuery,
        onClearSearch: () => _onSearchChanged(''),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _buildViewForMode(state.viewMode, displayPlants, state),
    );
  }

  Widget _buildViewForMode(ViewMode viewMode, List<Plant> plants, PlantsState state) {
    switch (viewMode) {
      case ViewMode.groupedBySpaces:
      case ViewMode.groupedBySpacesGrid:
      case ViewMode.groupedBySpacesList:
        final useGridLayout = viewMode == ViewMode.groupedBySpacesGrid ||
            viewMode == ViewMode.groupedBySpaces;
        return PlantsGroupedBySpacesView(
          groupedPlants: state.plantsGroupedBySpaces,
          scrollController: _scrollController,
          useGridLayout: useGridLayout,
        );
      case ViewMode.grid:
        return PlantsGridView(
          plants: plants,
          scrollController: _scrollController,
        );
      case ViewMode.list:
        return PlantsListView(
          plants: plants,
          scrollController: _scrollController,
        );
    }
  }

  Widget _buildSortButton(PlantsState state) {
    final sortManager = ref.read(plantsSortManagerProvider);
    
    return PopupMenuButton<SortBy>(
      tooltip: 'Ordenar por',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: _onSortChanged,
      itemBuilder: (context) => SortBy.values.map((sort) {
        final isSelected = state.sortBy == sort;
        return PopupMenuItem<SortBy>(
          value: sort,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  sortManager.getSortTitle(sort),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: const Icon(Icons.sort, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildGroupButton(PlantsState state) {
    final viewModeManager = ref.read(plantsViewModeManagerProvider);
    final isGrouped = viewModeManager.isGroupedBySpaces(state.viewMode);

    return GestureDetector(
      onTap: () {
        final newMode = viewModeManager.toggleGrouping(state.viewMode);
        _onViewModeChanged(newMode);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isGrouped
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: const Icon(Icons.category, color: Colors.white, size: 18),
      ),
    );
  }
}
