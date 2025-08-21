import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../providers/plants_provider.dart';
import '../providers/plant_form_provider.dart';
import '../selectors/plants_selectors.dart';
// import '../../../spaces/presentation/providers/spaces_provider.dart' as spaces;
import '../../domain/entities/plant.dart';
import '../widgets/plants_app_bar.dart';
import '../widgets/plants_grid_view.dart';
import '../widgets/plants_list_view.dart';
import '../widgets/plants_grouped_by_spaces_view.dart';
import '../widgets/empty_plants_widget.dart';
import '../widgets/plants_loading_widget.dart';
import '../widgets/plants_error_widget.dart';
import '../widgets/plants_fab.dart';
import '../widgets/plant_form_modal.dart';

class PlantsListPage extends StatefulWidget {
  const PlantsListPage({super.key});

  @override
  State<PlantsListPage> createState() => _PlantsListPageState();
}

class _PlantsListPageState extends State<PlantsListPage> {
  late PlantsProvider _plantsProvider;
  // late spaces.SpacesProvider _spacesProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _plantsProvider = di.sl<PlantsProvider>();
    // _spacesProvider = di.sl<spaces.SpacesProvider>();

    // Load data after a small delay to ensure auth is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _plantsProvider.loadPlants(),
      // _spacesProvider.loadSpaces(),
    ]);
  }

  Future<void> _onRefresh() async {
    _plantsProvider.clearError();
    await _loadInitialData();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      _plantsProvider.clearSearch();
    } else {
      _plantsProvider.searchPlants(query);
    }
  }

  void _onViewModeChanged(ViewMode mode) {
    _plantsProvider.setViewMode(mode);
  }

  // ignore: unused_element
  void _onSortChanged(SortBy sort) {
    _plantsProvider.setSortBy(sort);
  }

  // ignore: unused_element
  void _onSpaceFilterChanged(String? spaceId) {
    _plantsProvider.setSpaceFilter(spaceId);
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showAddPlantModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ChangeNotifierProvider(
            create: (_) => di.sl<PlantFormProvider>(),
            child: const PlantFormModal(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _plantsProvider),
        // ChangeNotifierProvider.value(value: _spacesProvider),
      ],
      child: Scaffold(
        backgroundColor:
            theme.brightness == Brightness.dark
                ? const Color(0xFF1C1C1E)
                : theme.colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Optimized App Bar with granular selector
              Selector<PlantsProvider, AppBarData>(
                selector:
                    (_, provider) => AppBarData(
                      plantsCount: provider.plantsCount,
                      searchQuery: provider.searchQuery,
                      viewMode: provider.viewMode,
                    ),
                shouldRebuild: (previous, next) {
                  return previous.plantsCount != next.plantsCount ||
                      previous.searchQuery != next.searchQuery ||
                      previous.viewMode != next.viewMode;
                },
                builder: (context, appBarData, child) {
                  return PlantsAppBar(
                    plantsCount: appBarData.plantsCount,
                    searchQuery: appBarData.searchQuery,
                    onSearchChanged: _onSearchChanged,
                    viewMode: appBarData.viewMode,
                    onViewModeChanged: _onViewModeChanged,
                  );
                },
              ),

              // Optimized lista with multiple granular selectors
              Expanded(child: _buildOptimizedPlantsContent()),
            ],
          ),
        ),

        // FAB para adicionar planta
        floatingActionButton: PlantsFab(
          onScrollToTop: _scrollToTop,
          scrollController: _scrollController,
        ),
      ),
    );
  }

  /// Optimized content builder using granular selectors
  Widget _buildOptimizedPlantsContent() {
    return Selector<PlantsProvider, LoadingErrorState>(
      selector:
          (_, provider) => LoadingErrorState(
            isLoading: provider.isLoading,
            error: provider.error,
            hasPlants: provider.plants.isNotEmpty,
          ),
      shouldRebuild: (previous, next) {
        return previous.isLoading != next.isLoading ||
            previous.error != next.error ||
            previous.hasPlants != next.hasPlants;
      },
      builder: (context, loadingErrorState, child) {
        // Estado de carregamento
        if (loadingErrorState.isLoading && !loadingErrorState.hasPlants) {
          return const PlantsLoadingWidget();
        }

        // Estado de erro
        if (loadingErrorState.error != null && !loadingErrorState.hasPlants) {
          return PlantsErrorWidget(
            error: loadingErrorState.error!,
            onRetry: _loadInitialData,
          );
        }

        // Content with plants
        return _buildPlantsContent();
      },
    );
  }

  /// Build the actual plants content (list/grid)
  Widget _buildPlantsContent() {
    return Selector<PlantsProvider, PlantsDisplayData>(
      selector:
          (_, provider) => PlantsDisplayData(
            plants:
                provider.searchQuery.isNotEmpty
                    ? provider.searchResults
                    : provider.plants,
            isSearching: provider.searchQuery.isNotEmpty,
            searchQuery: provider.searchQuery,
          ),
      shouldRebuild: (previous, next) {
        return previous.plants.length != next.plants.length ||
            previous.isSearching != next.isSearching ||
            previous.searchQuery != next.searchQuery ||
            !_listsEqual(previous.plants, next.plants);
      },
      builder: (context, displayData, child) {
        // Estado vazio
        if (displayData.plants.isEmpty) {
          return EmptyPlantsWidget(
            isSearching: displayData.isSearching,
            searchQuery: displayData.searchQuery,
            onClearSearch: () => _onSearchChanged(''),
            onAddPlant: () => _showAddPlantModal(context),
          );
        }

        // View mode selector for grid/list/grouped display
        return Selector<PlantsProvider, ViewMode>(
          selector: (_, provider) => provider.viewMode,
          builder: (context, viewMode, child) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: _buildViewForMode(viewMode, displayData),
            );
          },
        );
      },
    );
  }

  /// Build view based on current view mode
  Widget _buildViewForMode(ViewMode viewMode, PlantsDisplayData displayData) {
    switch (viewMode) {
      case ViewMode.groupedBySpaces:
        return Consumer<PlantsProvider>(
          builder: (context, plantsProvider, child) {
            final groupedPlants = plantsProvider.plantsGroupedBySpaces;
            return PlantsGroupedBySpacesView(
              groupedPlants: groupedPlants,
              scrollController: _scrollController,
            );
          },
        );
      case ViewMode.grid:
        return PlantsGridView(
          plants: displayData.plants,
          scrollController: _scrollController,
        );
      case ViewMode.list:
        return PlantsListView(
          plants: displayData.plants,
          scrollController: _scrollController,
        );
    }
  }

  /// Efficient list comparison to avoid unnecessary rebuilds
  bool _listsEqual(List<Plant> list1, List<Plant> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }

    return true;
  }
}
