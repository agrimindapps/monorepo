import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/background_sync_provider.dart';
import '../../../../core/utils/navigation_service.dart';
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
  final PlantsProvider plantsProvider;
  final PlantFormProvider Function() plantFormProviderFactory;
  
  const PlantsListPage({
    super.key,
    required this.plantsProvider,
    required this.plantFormProviderFactory,
  });

  @override
  State<PlantsListPage> createState() => _PlantsListPageState();
}

class _PlantsListPageState extends State<PlantsListPage> with RouteAware {
  // Provider injection - now via constructor
  late PlantsProvider _plantsProvider;
  
  // UI-only controller for scroll management
  final ScrollController _scrollController = ScrollController();
  
  // Background sync monitoring
  bool _wasSyncInProgress = false;
  StreamSubscription<void>? _syncStatusSubscription;

  @override
  void initState() {
    super.initState();
    _plantsProvider = widget.plantsProvider;

    // Load data after a small delay to ensure auth is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _plantsProvider.loadInitialData();
      
      // Iniciar sincronização automática se usuário não anônimo
      _tryStartAutoSync();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Subscribe to route changes with RouteObserver
    final routeObserver = NavigationService.instance.routeObserver;
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }
  
  /// Inicia sincronização em background sem bloquear UI
  void _tryStartAutoSync() {
    final authProvider = context.read<AuthProvider>();

    // Sincronização automática é iniciada pelo AuthProvider
    // em background, não precisamos bloquear a UI
    authProvider.startAutoSyncIfNeeded();

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
        _plantsProvider.refreshPlants();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _syncStatusSubscription?.cancel();
    
    // Unsubscribe from route observer
    final routeObserver = NavigationService.instance.routeObserver;
    routeObserver.unsubscribe(this);
    
    super.dispose();
  }

  // RouteAware callbacks - called when user navigates back to this page
  @override
  void didPopNext() {
    // Called when a route has been popped off, and the current route shows up.
    // This means user returned from plant details or other screen
    if (mounted) {
      _plantsProvider.refreshPlants();
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
    final plantFormProvider = widget.plantFormProviderFactory();

    // Mostrar dialog com o provider e capturar o resultado
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

    // Se salvou com sucesso, forçar atualização da lista
    if (result == true && mounted) {
      await _plantsProvider.refreshPlants();
      // Scroll para o topo para mostrar a nova planta
      _scrollToTop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build UI without blocking for sync - sync happens in background
    return Consumer2<AuthProvider, BackgroundSyncProvider?>(
      builder: (context, authProvider, syncProvider, _) {
        // Monitor background sync completion for data refresh
        if (syncProvider != null) {
          final isSyncInProgress = syncProvider.isSyncInProgress;
          if (_wasSyncInProgress && !isSyncInProgress) {
            // Background sync just finished, reload plants data
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _plantsProvider.refreshPlants();
              }
            });
          }
          _wasSyncInProgress = isSyncInProgress;
        }

        // ARCHITECTURE: Provide the injected provider to the widget tree
        // All state management flows through PlantsProvider
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _plantsProvider),
            // ChangeNotifierProvider.value(value: _spacesProvider),
          ],
          child: BasePageScaffold(
            body: ResponsiveLayout(
              child: Column(
                children: [
                  // Header with optional sync indicator
                  _buildHeaderWithSyncIndicator(context),
              
              // Search and filters section
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
            // FAB para adicionar planta
            floatingActionButton: PlantsFab(
              onScrollToTop: _scrollToTop,
              scrollController: _scrollController,
            ),
      ),
    );
      },  // Close Consumer<AuthProvider>
    );
  }

  Widget _buildHeaderWithSyncIndicator(BuildContext context) {
    return Consumer2<PlantsProvider, BackgroundSyncProvider?>(
      builder: (context, plantsProvider, syncProvider, _) {
        return Column(
          children: [
            PlantisHeader(
              title: 'Minhas Plantas',
              subtitle: '${plantsProvider.plantsCount} plantas no jardim',
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
                    final currentMode = plantsProvider.viewMode;
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
                      color: _isGroupedBySpaces(plantsProvider.viewMode)
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
                final authProvider = context.read<AuthProvider>();
                if (authProvider.currentUser != null) {
                  syncProvider.retrySync(authProvider.currentUser!.id);
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
      case ViewMode.groupedBySpacesGrid:
      case ViewMode.groupedBySpacesList:
        return Consumer<PlantsProvider>(
          builder: (context, plantsProvider, child) {
            final groupedPlants = plantsProvider.plantsGroupedBySpaces;
            final useGridLayout = viewMode == ViewMode.groupedBySpacesGrid ||
                                  viewMode == ViewMode.groupedBySpaces; // Default to grid for groupedBySpaces
            return PlantsGroupedBySpacesView(
              groupedPlants: groupedPlants,
              scrollController: _scrollController,
              useGridLayout: useGridLayout,
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
