import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../providers/plants_provider.dart';
// import '../../../spaces/presentation/providers/spaces_provider.dart' as spaces;
import '../widgets/plants_app_bar.dart';
import '../widgets/plants_grid_view.dart';
import '../widgets/plants_list_view.dart';
import '../widgets/plants_search_bar.dart';
import '../widgets/plants_filter_bar.dart';
import '../widgets/empty_plants_widget.dart';
import '../widgets/plants_loading_widget.dart';
import '../widgets/plants_error_widget.dart';
import '../widgets/plants_fab.dart';

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
    _loadInitialData();
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

  void _onSortChanged(SortBy sort) {
    _plantsProvider.setSortBy(sort);
  }

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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _plantsProvider),
        // ChangeNotifierProvider.value(value: _spacesProvider),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // App Bar com título e ações
              Consumer<PlantsProvider>(
                builder: (context, plantsProvider, child) {
                  // Mostra AppBar simplificado quando não há plantas
                  if (plantsProvider.plants.isEmpty && !plantsProvider.isLoading) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Minhas Plantas',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return PlantsAppBar(
                    plantsCount: plantsProvider.plantsCount,
                    viewMode: plantsProvider.viewMode,
                    onViewModeChanged: _onViewModeChanged,
                    sortBy: plantsProvider.sortBy,
                    onSortChanged: _onSortChanged,
                  );
                },
              ),
              
              // Barra de pesquisa (só quando há plantas)
              Consumer<PlantsProvider>(
                builder: (context, plantsProvider, child) {
                  if (plantsProvider.plants.isEmpty && !plantsProvider.isLoading) {
                    return const SizedBox.shrink();
                  }
                  return PlantsSearchBar(
                    searchQuery: plantsProvider.searchQuery,
                    onSearchChanged: _onSearchChanged,
                    isSearching: plantsProvider.isSearching,
                  );
                },
              ),
              
              // Filtros (só quando há plantas)
              Consumer<PlantsProvider>(
                builder: (context, plantsProvider, child) {
                  if (plantsProvider.plants.isEmpty && !plantsProvider.isLoading) {
                    return const SizedBox.shrink();
                  }
                  return PlantsFilterBar(
                    spaces: const [], // Empty list for now
                    selectedSpaceId: plantsProvider.filterBySpace,
                    onSpaceFilterChanged: _onSpaceFilterChanged,
                  );
                },
              ),
              
              // Lista de plantas
              Expanded(
                child: Consumer<PlantsProvider>(
                  builder: (context, plantsProvider, child) {
                    // Estado de carregamento
                    if (plantsProvider.isLoading && plantsProvider.plants.isEmpty) {
                      return const PlantsLoadingWidget();
                    }
                    
                    // Estado de erro
                    if (plantsProvider.error != null && plantsProvider.plants.isEmpty) {
                      return PlantsErrorWidget(
                        error: plantsProvider.error!,
                        onRetry: _loadInitialData,
                      );
                    }
                    
                    // Determina que lista mostrar (busca ou geral)
                    final plantsToShow = plantsProvider.searchQuery.isNotEmpty
                        ? plantsProvider.searchResults
                        : plantsProvider.plants;
                    
                    // Estado vazio
                    if (plantsToShow.isEmpty) {
                      return EmptyPlantsWidget(
                        isSearching: plantsProvider.searchQuery.isNotEmpty,
                        searchQuery: plantsProvider.searchQuery,
                        onClearSearch: () => _onSearchChanged(''),
                        onAddPlant: () {
                          // Navigate to add plant page
                          Navigator.of(context).pushNamed('/add-plant');
                        },
                      );
                    }
                    
                    // Lista com RefreshIndicator
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: plantsProvider.viewMode == ViewMode.grid
                          ? PlantsGridView(
                              plants: plantsToShow,
                              scrollController: _scrollController,
                            )
                          : PlantsListView(
                              plants: plantsToShow,
                              scrollController: _scrollController,
                            ),
                    );
                  },
                ),
              ),
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
}