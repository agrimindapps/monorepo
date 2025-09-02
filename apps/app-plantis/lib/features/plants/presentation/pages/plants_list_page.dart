import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/widgets/responsive_layout.dart';
// import '../../../spaces/presentation/providers/spaces_provider.dart' as spaces;
import '../../domain/entities/plant.dart';
import '../providers/plant_form_provider.dart';
import '../providers/plants_provider.dart';
import '../selectors/plants_selectors.dart';
import '../widgets/empty_plants_widget.dart';
import '../widgets/plant_form_dialog.dart';
import '../widgets/plants_app_bar.dart';
import '../widgets/plants_error_widget.dart';
import '../widgets/plants_fab.dart';
import '../widgets/plants_grid_view.dart';
import '../widgets/plants_grouped_by_spaces_view.dart';
import '../widgets/plants_list_view.dart';
import '../widgets/plants_loading_widget.dart';

/// Plants List Page - Clean Architecture View Layer
/// 
/// RESPONSIBILITIES:
/// - Presentation logic only (UI rendering)
/// - User interaction handling (tap, scroll, etc.)
/// - Navigation routing
/// - Widget composition and layout
/// 
/// WHAT THIS VIEW DOES NOT DO:
/// - Business logic (all in PlantsProvider)
/// - Data operations (delegated to provider)
/// - State management (provider handles all state)
/// - API calls or data transformation
/// 
/// ARCHITECTURE PATTERN:
/// View → Provider → Use Cases → Repository → Data Sources

class PlantsListPage extends StatefulWidget {
  const PlantsListPage({super.key});

  @override
  State<PlantsListPage> createState() => _PlantsListPageState();
}

class _PlantsListPageState extends State<PlantsListPage> {
  // Provider injection - managed by DI container
  late PlantsProvider _plantsProvider;
  // late spaces.SpacesProvider _spacesProvider;
  
  // UI-only controller for scroll management
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _plantsProvider = di.sl<PlantsProvider>();
    // _spacesProvider = di.sl<spaces.SpacesProvider>();

    // Load data after a small delay to ensure auth is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _plantsProvider.loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Dispose of the injected provider to prevent memory leaks
    _plantsProvider.dispose();
    super.dispose();
  }

  // ===== VIEW EVENT HANDLERS =====
  // These methods only delegate to provider and handle UI interactions
  
  Future<void> _onRefresh() async {
    await _plantsProvider.refreshPlants();
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

  // ===== UI-ONLY INTERACTIONS =====
  // These methods handle pure UI interactions (scroll, navigation)
  
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _navigateToAddPlant(BuildContext context) async {
    // Criar um novo provider para a dialog
    final plantFormProvider = di.sl<PlantFormProvider>();
    
    // Mostrar dialog com o provider
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangeNotifierProvider.value(
        value: plantFormProvider,
        child: const PlantFormDialog(),
      ),
    );
    
    // Limpar o provider após fechar a dialog
    plantFormProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ARCHITECTURE: Provide the injected provider to the widget tree
    // All state management flows through PlantsProvider
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
        body: ResponsiveLayout(
          child: SafeArea(
            child: Column(
              children: [
                // ARCHITECTURE: App Bar uses granular selector for performance
                // Only rebuilds when relevant state changes (count, search, view mode)
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

                // ARCHITECTURE: Content uses multiple granular selectors for optimal performance
                // Each selector only listens to specific parts of provider state
                Expanded(child: _buildOptimizedPlantsContent()),
              ],
            ),
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

  /// ARCHITECTURE: Optimized content builder using granular selectors for performance
  /// Uses LoadingErrorState selector to minimize rebuilds - only rebuilds when
  /// loading state, error state, or hasPlants state actually changes
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
        // Estado de carregamento inicial (primeira carga)
        if (loadingErrorState.shouldShowLoading) {
          return const PlantsLoadingWidget();
        }

        // Estado de erro - apenas quando há um erro real e nenhuma planta carregada
        // Diferencia erro real de estado vazio (lista vazia após load bem-sucedido)
        if (loadingErrorState.shouldShowError) {
          return PlantsErrorWidget(
            error: loadingErrorState.error!,
            onRetry: () => _plantsProvider.loadInitialData(),
          );
        }

        // Content with plants or empty state (successful load)
        return _buildPlantsContent();
      },
    );
  }

  /// ARCHITECTURE: Build the actual plants content with PlantsDisplayData selector
  /// This selector optimizes by only rebuilding when plant list changes, search state changes,
  /// or search query changes. Uses efficient list comparison with _listsEqual()
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
            onAddPlant: () => _navigateToAddPlant(context),
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

  /// ARCHITECTURE: Build view based on current view mode with ViewMode selector
  /// Final selector layer that only rebuilds when view mode changes
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

  /// PERFORMANCE: Efficient list comparison to avoid unnecessary rebuilds
  /// Only compares plant IDs rather than full plant objects for better performance
  /// Uses hash-based comparison for better performance with large lists
  bool _listsEqual(List<Plant> list1, List<Plant> list2) {
    if (list1.length != list2.length) return false;

    // For small lists, direct ID comparison is faster
    if (list1.length < 50) {
      for (int i = 0; i < list1.length; i++) {
        if (list1[i].id != list2[i].id) return false;
      }
      return true;
    }

    // For larger lists, use hash-based comparison for better performance
    final hash1 = Object.hashAll(list1.map((plant) => plant.id));
    final hash2 = Object.hashAll(list2.map((plant) => plant.id));
    
    // If hashes are different, lists are definitely different
    if (hash1 != hash2) return false;
    
    // Hash collision check - fallback to ID comparison
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id) return false;
    }

    return true;
  }
}
