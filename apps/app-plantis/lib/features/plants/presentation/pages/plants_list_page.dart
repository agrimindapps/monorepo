import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_providers.dart';
// Plants providers now imported from Riverpod - using plants_providers.dart
import '../../../../core/providers/plants_providers.dart'
    show ViewMode, SortBy;
import '../../../../core/providers/plants_providers.dart'
    as riverpod_plants;
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../../../../shared/widgets/responsive_layout.dart';
// import '../../../spaces/presentation/providers/spaces_provider.dart' as spaces;
import '../../domain/entities/plant.dart';
import '../widgets/empty_plants_widget.dart';
import '../widgets/plants_app_bar.dart';
import '../widgets/plants_error_widget.dart';
import '../widgets/plants_fab.dart';
import '../widgets/plants_grid_view.dart';
import '../widgets/plants_grouped_by_spaces_view.dart';
import '../widgets/plants_list_view.dart';
import '../widgets/plants_loading_widget.dart';

/// Simple data class for app bar
class AppBarData {
  final int plantsCount;
  final String searchQuery;
  final ViewMode viewMode;

  const AppBarData({
    required this.plantsCount,
    required this.searchQuery,
    required this.viewMode,
  });
}

/// Data class for plants display
class PlantsDisplayData {
  final List<Plant> plants;
  final bool isSearching;
  final String searchQuery;

  const PlantsDisplayData({
    required this.plants,
    required this.isSearching,
    required this.searchQuery,
  });
}

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

class PlantsListPage extends ConsumerStatefulWidget {
  // Remove dependency injection - now using Riverpod providers

  const PlantsListPage({super.key});

  @override
  ConsumerState<PlantsListPage> createState() => _PlantsListPageState();
}

class _PlantsListPageState extends ConsumerState<PlantsListPage>
    with RouteAware {
  // Riverpod providers - accessed via ref

  // UI-only controller for scroll management
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<void>? _syncStatusSubscription;

  @override
  void initState() {
    super.initState();

    // Load data after a small delay to ensure auth is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger initial data load via Riverpod provider
      // This will be handled by the provider automatically

      // Iniciar sincronização automática se usuário não anônimo
      _tryStartAutoSync();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // TODO: Route observer functionality disabled during NavigationService migration
    // Consider using GoRouter navigation events instead
    // final routeObserver = NavigationService.instance.routeObserver;
    // final modalRoute = ModalRoute.of(context);
    // if (modalRoute is PageRoute) {
    //   routeObserver.subscribe(this, modalRoute);
    // }
  }

  /// Inicia sincronização em background sem bloquear UI
  void _tryStartAutoSync() {
    // Sincronização será gerenciada pelos providers Riverpod
    // Por enquanto, apenas verificamos se está autenticado
    final authState = ref.read(authProvider);
    if (authState.hasValue &&
        authState.value!.isAuthenticated &&
        !authState.value!.isAnonymous) {
      // Background sync will be handled by providers
    }

    // Monitorar progresso de sync para atualizar dados quando necessário
    _monitorBackgroundSync();
  }

  /// Monitora sincronização em background de forma mais eficiente
  void _monitorBackgroundSync() {
    // TODO: Implement background sync monitoring with Riverpod
    // Using less frequent refresh to avoid battery drain
    Timer.periodic(const Duration(minutes: 15), (timer) {
      if (mounted) {
        // Only refresh if app is visible and user is authenticated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final authState = ref.read(authProvider);
            if (authState.hasValue &&
                authState.value!.isAuthenticated &&
                !authState.value!.isAnonymous) {
              ref.read(riverpod_plants.plantsProvider.notifier).refreshPlants();
            }
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _syncStatusSubscription?.cancel();

    // TODO: Route observer functionality disabled during NavigationService migration
    // final routeObserver = NavigationService.instance.routeObserver;
    // routeObserver.unsubscribe(this);

    super.dispose();
  }

  // RouteAware callbacks - called when user navigates back to this page
  @override
  void didPopNext() {
    // Called when a route has been popped off, and the current route shows up.
    // This means user returned from plant details or other screen
    if (mounted) {
      ref.read(riverpod_plants.plantsProvider.notifier).refreshPlants();
    }
  }

  @override
  void didPush() {
    // Called when the current route has been pushed.
  }

  @override
  void didPop() {
    // Called when the current route has been popped off.
  }

  @override
  void didPushNext() {
    // Called when a new route has been pushed, and the current route is no longer visible.
  }

  // ===== VIEW EVENT HANDLERS =====
  // These methods only delegate to provider and handle UI interactions

  Future<void> _onRefresh() async {
    await ref.read(riverpod_plants.plantsProvider.notifier).refreshPlants();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      ref.read(riverpod_plants.plantsProvider.notifier).clearSearch();
    } else {
      ref.read(riverpod_plants.plantsProvider.notifier).searchPlants(query);
    }
  }

  void _onViewModeChanged(ViewMode mode) {
    ref.read(riverpod_plants.plantsProvider.notifier).setViewMode(mode);
  }

  void _onSortChanged(SortBy sort) {
    ref.read(riverpod_plants.plantsProvider.notifier).setSortBy(sort);
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder:
          (context) => Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? _) {
              final plantsAsync = ref.watch(riverpod_plants.plantsProvider);
              return plantsAsync.when(
                data:
                    (state) => Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ordenar por',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...SortBy.values.map(
                            (sort) => ListTile(
                              title: Text(_getSortTitle(sort)),
                              trailing:
                                  state.sortBy == sort
                                      ? const Icon(Icons.check)
                                      : null,
                              onTap: () {
                                _onSortChanged(sort);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              );
            },
          ),
    );
  }

  String _getSortTitle(SortBy sort) {
    switch (sort) {
      case SortBy.name:
        return 'Nome';
      case SortBy.newest:
        return 'Mais recentes';
      case SortBy.oldest:
        return 'Mais antigas';
      case SortBy.species:
        return 'Espécie';
    }
  }

  // ===== UI-ONLY INTERACTIONS =====
  // These methods handle pure UI interactions (scroll, navigation)

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
    // Build UI without blocking for sync - sync happens in background
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? _) {
        // Simple auth state monitoring without complex sync logic for now
        // Auth state monitoring and plant data display

        // ARCHITECTURE: Now using Riverpod providers directly
        // All state management flows through Riverpod
        return BasePageScaffold(
          body: ResponsiveLayout(
            child: Column(
              children: [
                // Header with optional sync indicator
                _buildHeaderWithSyncIndicator(context),

                // Search and filters section
                Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    final plantsState = ref.watch(
                      riverpod_plants.plantsProvider,
                    );
                    final appBarData = plantsState.when(
                      data:
                          (state) => AppBarData(
                            plantsCount: state.allPlants.length,
                            searchQuery: state.searchQuery,
                            viewMode: state.viewMode,
                          ),
                      loading:
                          () => const AppBarData(
                            plantsCount: 0,
                            searchQuery: '',
                            viewMode: ViewMode.list,
                          ),
                      error:
                          (_, __) => const AppBarData(
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
                  },
                ),

                // ARCHITECTURE: Content uses multiple granular selectors for optimal performance
                // Each selector only listens to specific parts of provider state
                Expanded(child: _buildOptimizedPlantsContent()),
              ],
            ),
          ),
          // FAB para adicionar planta
          floatingActionButton: PlantsFab(
            onScrollToTop: _scrollToTop,
            scrollController: _scrollController,
          ),
        );
      },
    );
  }

  Widget _buildHeaderWithSyncIndicator(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? _) {
        final plantsAsync = ref.watch(riverpod_plants.plantsProvider);

        return plantsAsync.when(
          data:
              (plantsState) => Column(
                children: [
                  PlantisHeader(
                    title: 'Minhas Plantas',
                    subtitle:
                        '${plantsState.allPlants.length} plantas no jardim',
                    leading: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    actions: [
                      // Sort button
                      GestureDetector(
                        onTap: () => _showSortOptions(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(
                            Icons.sort,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      // Grouped by spaces toggle button
                      GestureDetector(
                        onTap: () {
                          final currentMode = plantsState.viewMode;
                          ViewMode newMode;

                          // Se já está agrupado, volta para o modo anterior (grid ou list)
                          if (currentMode == ViewMode.groupedBySpaces ||
                              currentMode == ViewMode.groupedBySpacesGrid ||
                              currentMode == ViewMode.groupedBySpacesList) {
                            // Volta para list como padrão
                            newMode = ViewMode.list;
                          } else {
                            // Aplica agrupamento mantendo o modo atual (grid ou list)
                            if (currentMode == ViewMode.grid) {
                              newMode = ViewMode.groupedBySpacesGrid;
                            } else {
                              newMode = ViewMode.groupedBySpacesList;
                            }
                          }

                          _onViewModeChanged(newMode);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                _isGroupedBySpaces(plantsState.viewMode)
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(
                            Icons.category,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // TODO: Add sync indicator when background sync is migrated to Riverpod
                ],
              ),
          loading:
              () => PlantisHeader(
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
          error:
              (error, _) => PlantisHeader(
                title: 'Minhas Plantas',
                subtitle: 'Toque para tentar novamente',
                leading: GestureDetector(
                  onTap:
                      () =>
                          ref
                              .read(riverpod_plants.plantsProvider.notifier)
                              .refreshPlants(),
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }

  /// ARCHITECTURE: Optimized content builder using granular selectors for performance
  /// Uses LoadingErrorState selector to minimize rebuilds - only rebuilds when
  /// loading state, error state, or hasPlants state actually changes
  Widget _buildOptimizedPlantsContent() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final plantsState = ref.watch(riverpod_plants.plantsProvider);

        return plantsState.when(
          loading: () => const PlantsLoadingWidget(),
          error:
              (error, _) => PlantsErrorWidget(
                error: error.toString(),
                onRetry:
                    () =>
                        ref
                            .read(riverpod_plants.plantsProvider.notifier)
                            .loadInitialData(),
              ),
          data: (state) {
            // Handle loading state within data with better UX
            if (state.isLoading && state.allPlants.isEmpty) {
              // First load - show full loading widget
              return const PlantsLoadingWidget();
            } else if (state.isLoading && state.allPlants.isNotEmpty) {
              // Refreshing with existing data - show shimmer overlay
              return Stack(
                children: [
                  _buildPlantsContent(), // Show existing data
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.1),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            // Handle error state
            if (state.error != null) {
              return PlantsErrorWidget(
                error: state.error!,
                onRetry:
                    () =>
                        ref
                            .read(riverpod_plants.plantsProvider.notifier)
                            .loadInitialData(),
              );
            }

            // Content with plants or empty state (successful load)
            return _buildPlantsContent();
          },
        );
      },
    );
  }

  /// ARCHITECTURE: Build the actual plants content with Riverpod Consumer
  /// This uses Riverpod watch to rebuild only when necessary data changes
  Widget _buildPlantsContent() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final plantsAsync = ref.watch(riverpod_plants.plantsProvider);

        return plantsAsync.when(
          data: (plantsState) {
            final displayData = PlantsDisplayData(
              plants:
                  plantsState.searchQuery.isNotEmpty
                      ? plantsState.searchResults
                      : (plantsState.filterBySpace != null
                          ? plantsState.filteredPlants
                          : plantsState.allPlants),
              isSearching: plantsState.searchQuery.isNotEmpty,
              searchQuery: plantsState.searchQuery,
            );

            // Estado vazio
            if (displayData.plants.isEmpty) {
              return EmptyPlantsWidget(
                isSearching: displayData.isSearching,
                searchQuery: displayData.searchQuery,
                onClearSearch: () => _onSearchChanged(''),
                // onAddPlant removido - botão não será exibido
              );
            }

            // Content with view mode
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: _buildViewForMode(plantsState.viewMode, displayData),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erro: $error')),
        );
      },
    );
  }

  /// ARCHITECTURE: Build view based on current view mode
  /// Uses Riverpod ViewMode enum for proper type safety
  Widget _buildViewForMode(ViewMode viewMode, PlantsDisplayData displayData) {
    switch (viewMode) {
      case ViewMode.groupedBySpaces:
      case ViewMode.groupedBySpacesGrid:
      case ViewMode.groupedBySpacesList:
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final plantsAsync = ref.watch(riverpod_plants.plantsProvider);
            return plantsAsync.when(
              data: (plantsState) {
                final useGridLayout =
                    viewMode == ViewMode.groupedBySpacesGrid ||
                    viewMode ==
                        ViewMode
                            .groupedBySpaces; // Default to grid for groupedBySpaces
                return PlantsGroupedBySpacesView(
                  groupedPlants: plantsState.plantsGroupedBySpaces,
                  scrollController: _scrollController,
                  useGridLayout: useGridLayout,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erro: $error')),
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

  /// Check if current view mode is grouped by spaces
  bool _isGroupedBySpaces(ViewMode viewMode) {
    return viewMode == ViewMode.groupedBySpaces ||
        viewMode == ViewMode.groupedBySpacesGrid ||
        viewMode == ViewMode.groupedBySpacesList;
  }
}
