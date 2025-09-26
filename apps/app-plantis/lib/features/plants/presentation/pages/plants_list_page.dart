import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/background_sync_provider.dart';
import 'package:core/core.dart' as core;
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../core/riverpod_providers/auth_providers.dart';
import '../../../../core/riverpod_providers/plants_providers.dart' as riverpod_plants;
import '../../../../core/riverpod_providers/auth_providers.dart' as providers;
// import '../../../spaces/presentation/providers/spaces_provider.dart' as spaces;
import '../../domain/entities/plant.dart';
import '../providers/plant_form_provider.dart';
// Plants providers now imported from Riverpod - using plants_providers.dart
import '../selectors/plants_selectors.dart';
import '../../../../core/riverpod_providers/plants_providers.dart' show SortBy;
import '../../../../core/riverpod_providers/plants_providers.dart' as riverpod_plants_types;
import '../providers/plants_provider.dart' show ViewMode;
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

class PlantsListPage extends ConsumerStatefulWidget {
  // Remove dependency injection - now using Riverpod providers
  
  const PlantsListPage({super.key});

  @override
  ConsumerState<PlantsListPage> createState() => _PlantsListPageState();
}

class _PlantsListPageState extends ConsumerState<PlantsListPage> with RouteAware {
  // Riverpod providers - accessed via ref
  
  // UI-only controller for scroll management
  final ScrollController _scrollController = ScrollController();
  
  // Background sync monitoring
  bool _wasSyncInProgress = false;
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
    if (authState.hasValue && authState.value!.isAuthenticated && !authState.value!.isAnonymous) {
      // Background sync will be handled by providers
    }

    // Monitorar progresso de sync para atualizar dados quando necessário
    _monitorBackgroundSync();
  }

  /// Monitora sincronização em background e atualiza dados quando necessário
  void _monitorBackgroundSync() {
    final syncProvider = context.read<BackgroundSyncProvider?>();
    if (syncProvider == null) return;

    // Escutar mudanças no status de sync
    _syncStatusSubscription?.cancel();
    _syncStatusSubscription = syncProvider.syncStatusStream.listen((status) {
      if (mounted && status.toString().contains('completed')) {
        // Sync completado - recarregar dados das plantas
        ref.read(riverpod_plants.plantsProvider.notifier).refreshPlants();
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
    final riverpodMode = _convertToRiverpodViewMode(mode);
    ref.read(riverpod_plants.plantsProvider.notifier).setViewMode(riverpodMode);
  }

  // Helper function to convert between ViewMode enums
  riverpod_plants_types.ViewMode _convertToRiverpodViewMode(ViewMode mode) {
    switch (mode) {
      case ViewMode.grid:
        return riverpod_plants_types.ViewMode.grid;
      case ViewMode.list:
        return riverpod_plants_types.ViewMode.list;
      case ViewMode.groupedBySpaces:
        return riverpod_plants_types.ViewMode.groupedBySpaces;
      case ViewMode.groupedBySpacesGrid:
        return riverpod_plants_types.ViewMode.groupedBySpacesGrid;
      case ViewMode.groupedBySpacesList:
        return riverpod_plants_types.ViewMode.groupedBySpacesList;
    }
  }

  // Helper function to convert from Riverpod ViewMode to widget ViewMode
  ViewMode _convertFromRiverpodViewMode(riverpod_plants_types.ViewMode mode) {
    switch (mode) {
      case riverpod_plants_types.ViewMode.grid:
        return ViewMode.grid;
      case riverpod_plants_types.ViewMode.list:
        return ViewMode.list;
      case riverpod_plants_types.ViewMode.groupedBySpaces:
        return ViewMode.groupedBySpaces;
      case riverpod_plants_types.ViewMode.groupedBySpacesGrid:
        return ViewMode.groupedBySpacesGrid;
      case riverpod_plants_types.ViewMode.groupedBySpacesList:
        return ViewMode.groupedBySpacesList;
    }
  }

  // ignore: unused_element
  void _onSortChanged(SortBy sort) {
    ref.read(riverpod_plants.plantsProvider.notifier).setSortBy(sort);
  }

  // ignore: unused_element
  void _onSpaceFilterChanged(String? spaceId) {
    ref.read(riverpod_plants.plantsProvider.notifier).setSpaceFilter(spaceId);
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

  Future<void> _navigateToAddPlant(BuildContext context) async {
    // Criar um novo provider para a dialog
    final plantFormProvider = sl<PlantFormProvider>();

    // Mostrar dialog com o provider e capturar o resultado
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => core.ChangeNotifierProvider.value(
        value: plantFormProvider,
        child: const PlantFormDialog(),
      ),
    );

    // Limpar o provider após fechar a dialog
    plantFormProvider.dispose();

    // Se salvou com sucesso, forçar atualização da lista
    if (result == true && mounted) {
      await ref.read(riverpod_plants.plantsProvider.notifier).refreshPlants();
      // Scroll para o topo para mostrar a nova planta
      _scrollToTop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build UI without blocking for sync - sync happens in background
    return Consumer(
      builder: (context, ref, _) {
        final authState = ref.watch(authProvider);
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
                builder: (context, ref, child) {
                  final plantsState = ref.watch(riverpod_plants.plantsProvider);
                  final appBarData = plantsState.when(
                    data: (state) => AppBarData(
                      plantsCount: state.allPlants.length,
                      searchQuery: state.searchQuery,
                      viewMode: _convertFromRiverpodViewMode(state.viewMode),
                    ),
                    loading: () => AppBarData(
                      plantsCount: 0,
                      searchQuery: '',
                      viewMode: ViewMode.list,
                    ),
                    error: (_, __) => AppBarData(
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
      builder: (context, ref, _) {
        final plantsAsync = ref.watch(riverpod_plants.plantsProvider);
        final syncProvider = context.read<BackgroundSyncProvider?>();

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
                  child: const Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                actions: [
                  // Grouped by spaces toggle button
                  GestureDetector(
                    onTap: () {
                      final currentMode = plantsState.viewMode;
                      riverpod_plants.ViewMode newMode;

                      // Se já está agrupado, volta para o modo anterior (grid ou list)
                      if (currentMode == riverpod_plants.ViewMode.groupedBySpaces ||
                          currentMode == riverpod_plants.ViewMode.groupedBySpacesGrid ||
                          currentMode == riverpod_plants.ViewMode.groupedBySpacesList) {
                        // Volta para list como padrão
                        newMode = riverpod_plants.ViewMode.list;
                      } else {
                        // Aplica agrupamento mantendo o modo atual (grid ou list)
                        if (currentMode == riverpod_plants.ViewMode.grid) {
                          newMode = riverpod_plants.ViewMode.groupedBySpacesGrid;
                        } else {
                          newMode = riverpod_plants.ViewMode.groupedBySpacesList;
                        }
                      }

                      _onViewModeChanged(_convertFromRiverpodViewMode(newMode));
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _isGroupedBySpaces(plantsState.viewMode)
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
              // Discrete sync indicator
              if (syncProvider?.shouldShowSyncIndicator() == true)
                _buildDiscreteSyncIndicator(syncProvider!),
            ],
          ),
          loading: () => PlantisHeader(
            title: 'Minhas Plantas',
            subtitle: 'Carregando...',
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
          ),
          error: (_, __) => PlantisHeader(
            title: 'Minhas Plantas',
            subtitle: 'Erro ao carregar',
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
          ),
        );
      },
    );
  }

  Widget _buildDiscreteSyncIndicator(BackgroundSyncProvider syncProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          if (syncProvider.isSyncInProgress)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          else
            Icon(
              syncProvider.syncStatus.toString().contains('error')
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              size: 16,
              color: syncProvider.syncStatus.toString().contains('error')
                  ? Colors.red
                  : Colors.green,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              syncProvider.getSyncStatusMessage(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          if (syncProvider.syncStatus.toString().contains('error'))
            TextButton(
              onPressed: () {
                final authState = ref.read(authProvider);
                if (authState.hasValue && authState.value!.isAuthenticated) {
                  final userEntity = authState.value!.currentUser;
                  if (userEntity != null) {
                    syncProvider.retrySync(userEntity.id);
                  }
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
              child: const Text(
                'Tentar novamente',
                style: TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  /// ARCHITECTURE: Optimized content builder using granular selectors for performance
  /// Uses LoadingErrorState selector to minimize rebuilds - only rebuilds when
  /// loading state, error state, or hasPlants state actually changes
  Widget _buildOptimizedPlantsContent() {
    return Consumer(
      builder: (context, ref, child) {
        final plantsState = ref.watch(riverpod_plants.plantsProvider);

        return plantsState.when(
          loading: () => const PlantsLoadingWidget(),
          error: (error, _) => PlantsErrorWidget(
            error: error.toString(),
            onRetry: () => ref.read(riverpod_plants.plantsProvider.notifier).loadInitialData(),
          ),
          data: (state) {
            // Handle loading state within data
            if (state.isLoading) {
              return const PlantsLoadingWidget();
            }

            // Handle error state
            if (state.error != null) {
              return PlantsErrorWidget(
                error: state.error!,
                onRetry: () => ref.read(riverpod_plants.plantsProvider.notifier).loadInitialData(),
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
      builder: (context, ref, child) {
        final plantsAsync = ref.watch(riverpod_plants.plantsProvider);

        return plantsAsync.when(
          data: (plantsState) {
            final displayData = PlantsDisplayData(
              plants: plantsState.searchQuery.isNotEmpty
                  ? plantsState.searchResults
                  : plantsState.allPlants,
              isSearching: plantsState.searchQuery.isNotEmpty,
              searchQuery: plantsState.searchQuery,
            );

            // Estado vazio
            if (displayData.plants.isEmpty) {
              return EmptyPlantsWidget(
                isSearching: displayData.isSearching,
                searchQuery: displayData.searchQuery,
                onClearSearch: () => _onSearchChanged(''),
                onAddPlant: () => _navigateToAddPlant(context),
              );
            }

            // Content with view mode
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: _buildViewForMode(plantsState.viewMode, displayData),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Erro: $error'),
          ),
        );
      },
    );
  }

  /// ARCHITECTURE: Build view based on current view mode
  /// Uses Riverpod ViewMode enum for proper type safety
  Widget _buildViewForMode(riverpod_plants.ViewMode viewMode, PlantsDisplayData displayData) {
    switch (viewMode) {
      case riverpod_plants.ViewMode.groupedBySpaces:
      case riverpod_plants.ViewMode.groupedBySpacesGrid:
      case riverpod_plants.ViewMode.groupedBySpacesList:
        return Consumer(
          builder: (context, ref, child) {
            final plantsAsync = ref.watch(riverpod_plants.plantsProvider);
            return plantsAsync.when(
              data: (plantsState) {
                final useGridLayout = viewMode == riverpod_plants.ViewMode.groupedBySpacesGrid ||
                                      viewMode == riverpod_plants.ViewMode.groupedBySpaces; // Default to grid for groupedBySpaces
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
      case riverpod_plants.ViewMode.grid:
        return PlantsGridView(
          plants: displayData.plants,
          scrollController: _scrollController,
        );
      case riverpod_plants.ViewMode.list:
        return PlantsListView(
          plants: displayData.plants,
          scrollController: _scrollController,
        );
    }
  }

  /// Check if current view mode is grouped by spaces
  bool _isGroupedBySpaces(riverpod_plants.ViewMode viewMode) {
    return viewMode == riverpod_plants.ViewMode.groupedBySpaces ||
           viewMode == riverpod_plants.ViewMode.groupedBySpacesGrid ||
           viewMode == riverpod_plants.ViewMode.groupedBySpacesList;
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
