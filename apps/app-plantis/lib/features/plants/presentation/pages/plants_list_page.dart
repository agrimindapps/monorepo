import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../providers/plants_provider.dart';
import '../providers/plant_form_provider.dart';
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
      builder: (context) => ChangeNotifierProvider(
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
        backgroundColor: theme.brightness == Brightness.dark 
          ? const Color(0xFF1C1C1E) 
          : theme.colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              // New App Bar with integrated search
              Consumer<PlantsProvider>(
                builder: (context, plantsProvider, child) {
                  return PlantsAppBar(
                    plantsCount: plantsProvider.plantsCount,
                    searchQuery: plantsProvider.searchQuery,
                    onSearchChanged: _onSearchChanged,
                    viewMode: plantsProvider.viewMode,
                    onViewModeChanged: _onViewModeChanged,
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
                          // Show modal for adding plant
                          _showAddPlantModal(context);
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