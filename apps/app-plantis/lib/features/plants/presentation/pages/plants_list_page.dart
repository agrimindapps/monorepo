import 'package:core/core.dart' hide SortBy, Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/plants_providers.dart' show ViewMode, SortBy;
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
      // Background sync monitoring is handled by the sync service
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

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? _) {
          final sortManager = ref.watch(plantsSortManagerProvider);
          final plantsAsync = ref.watch(riverpod_plants.plantsNotifierProvider);
          return plantsAsync.when(
            data: (state) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ordenar por',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...SortBy.values.map(
                    (sort) => ListTile(
                      title: Text(sortManager.getSortTitle(sort)),
                      trailing: state.sortBy == sort
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
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? _) {
        // Garante que os dados sejam carregados quando a página é construída
        final plantsAsync = ref.watch(riverpod_plants.plantsNotifierProvider);
        plantsAsync.when(
          data: (state) {
            // Se não há plantas carregadas e não está carregando, força o carregamento
            if (state.allPlants.isEmpty &&
                !state.isLoading &&
                state.error == null &&
                !_hasAttemptedInitialLoad) {
              _hasAttemptedInitialLoad = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(riverpod_plants.plantsNotifierProvider.notifier)
                    .loadInitialData();
              });
            }
          },
          loading: () {
            // Já está carregando, não faz nada
          },
          error: (_, __) {
            // Se houve erro e não há plantas, tenta recarregar uma vez
            final state = plantsAsync.valueOrNull;
            if (state != null &&
                state.allPlants.isEmpty &&
                !state.isLoading &&
                !_hasAttemptedInitialLoad) {
              _hasAttemptedInitialLoad = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(riverpod_plants.plantsNotifierProvider.notifier)
                    .loadInitialData();
              });
            }
          },
        );

        return BasePageScaffold(
          body: ResponsiveLayout(
            child: Column(
              children: [
                _buildHeaderWithSyncIndicator(context),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                        final plantsState = ref.watch(
                          riverpod_plants.plantsNotifierProvider,
                        );
                        final appBarData = plantsState.when(
                          data: (state) => AppBarData(
                            plantsCount: state.allPlants.length,
                            searchQuery: state.searchQuery,
                            viewMode: state.viewMode,
                          ),
                          loading: () => const AppBarData(
                            plantsCount: 0,
                            searchQuery: '',
                            viewMode: ViewMode.list,
                          ),
                          error: (_, __) => const AppBarData(
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
                Expanded(child: _buildOptimizedPlantsContent()),
              ],
            ),
          ),
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
        final plantsAsync = ref.watch(riverpod_plants.plantsNotifierProvider);

        return plantsAsync.when(
          data: (plantsState) => Column(
            children: [
              PlantisHeader(
                title: 'Minhas Plantas',
                subtitle: '${plantsState.allPlants.length} plantas no jardim',
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
                  _buildSortButton(context),
                  _buildGroupButton(plantsState),
                ],
              ),
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
      },
    );
  }

  /// ARCHITECTURE: Optimized content builder using granular selectors for performance
  /// Uses LoadingErrorState selector to minimize rebuilds - only rebuilds when
  /// loading state, error state, or hasPlants state actually changes
  Widget _buildOptimizedPlantsContent() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final plantsState = ref.watch(riverpod_plants.plantsNotifierProvider);

        return plantsState.when(
          loading: () => const PlantsLoadingWidget(),
          error: (error, _) => PlantsErrorWidget(
            error: error.toString(),
            onRetry: () => ref
                .read(riverpod_plants.plantsNotifierProvider.notifier)
                .loadInitialData(),
          ),
          data: (state) {
            if (state.isLoading && state.allPlants.isEmpty) {
              return const PlantsLoadingWidget();
            } else if (state.isLoading && state.allPlants.isNotEmpty) {
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
            if (state.error != null) {
              return PlantsErrorWidget(
                error: state.error!,
                onRetry: () => ref
                    .read(riverpod_plants.plantsNotifierProvider.notifier)
                    .loadInitialData(),
              );
            }
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
        final plantsAsync = ref.watch(riverpod_plants.plantsNotifierProvider);

        return plantsAsync.when(
          data: (plantsState) {
            // DEBUG: Log state to identify the issue
            debugPrint('🔍 PlantsListPage Debug:');
            debugPrint('  - allPlants: ${plantsState.allPlants.length}');
            debugPrint(
              '  - filteredPlants: ${plantsState.filteredPlants.length}',
            );
            debugPrint(
              '  - searchResults: ${plantsState.searchResults.length}',
            );
            debugPrint('  - searchQuery: "${plantsState.searchQuery}"');
            debugPrint('  - filterBySpace: ${plantsState.filterBySpace}');

            final displayData = PlantsDisplayData(
              plants: plantsState.searchQuery.isNotEmpty
                  ? plantsState.searchResults
                  : (plantsState.filterBySpace != null
                        ? plantsState.filteredPlants
                        : plantsState.allPlants),
              isSearching: plantsState.searchQuery.isNotEmpty,
              searchQuery: plantsState.searchQuery,
            );

            debugPrint('  - displayData.plants: ${displayData.plants.length}');

            if (displayData.plants.isEmpty) {
              return EmptyPlantsWidget(
                isSearching: displayData.isSearching,
                searchQuery: displayData.searchQuery,
                onClearSearch: () => _onSearchChanged(''),
              );
            }
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
            final plantsAsync = ref.watch(
              riverpod_plants.plantsNotifierProvider,
            );
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

  Widget _buildSortButton(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return GestureDetector(
          onTap: () => _showSortOptions(context),
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
      },
    );
  }

  Widget _buildGroupButton(riverpod_plants.PlantsState plantsState) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final viewModeManager = ref.watch(plantsViewModeManagerProvider);
        final isGrouped = viewModeManager.isGroupedBySpaces(
          plantsState.viewMode,
        );

        return GestureDetector(
          onTap: () {
            final newMode = viewModeManager.toggleGrouping(
              plantsState.viewMode,
            );
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
      },
    );
  }
}
