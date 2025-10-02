import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/plant.dart';
import '../providers/plant_task_provider.dart';
import '../providers/plants_provider.dart';
import 'empty_plants_widget.dart';
import 'enhanced_plant_card.dart';
import 'enhanced_plants_app_bar.dart';
import 'plant_form_dialog.dart';
import 'plants_error_widget.dart';
import 'plants_loading_widget.dart';

/// Enhanced Plants List View siguiendo principios SOLID
/// S - Responsabilidad única: Solo maneja la vista principal de plantas
/// O - Abierto/cerrado: Extensible para nuevas funcionalidades
/// L - Liskov: Puede ser sustituido por cualquier Widget
/// I - Segregación de interfaces: Interfaces específicas para cada responsabilidad
/// D - Inversión de dependencias: Depende de abstracciones

class EnhancedPlantsListView extends StatefulWidget {
  const EnhancedPlantsListView({super.key});

  @override
  State<EnhancedPlantsListView> createState() => _EnhancedPlantsListViewState();
}

class _EnhancedPlantsListViewState extends State<EnhancedPlantsListView>
    with WidgetsBindingObserver
    implements
        ISearchDelegate,
        IViewModeDelegate,
        IPlantCardActions,
        ITaskDataProvider {
  late PlantsProvider _plantsProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _plantsProvider = di.sl<PlantsProvider>();

    // Add observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _plantsProvider.refreshPlants();
    }
  }

  // ISearchDelegate implementation
  @override
  void onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      _plantsProvider.clearSearch();
    } else {
      _plantsProvider.searchPlants(query);
    }
  }

  @override
  void onClearSearch() {
    _plantsProvider.clearSearch();
  }

  // IViewModeDelegate implementation
  @override
  void onViewModeChanged(AppBarViewMode mode) {
    _plantsProvider.setViewMode(
      mode == AppBarViewMode.grid ? ViewMode.grid : ViewMode.list,
    );
  }

  // IPlantCardActions implementation
  @override
  void onTap(Plant plant) {
    // Navigate to plant details
    // TODO: Implement navigation
  }

  @override
  void onEdit(Plant plant) {
    _showEditPlantModal(plant);
  }

  @override
  void onRemove(Plant plant) {
    _showRemoveConfirmation(plant);
  }

  // ITaskDataProvider implementation
  @override
  Future<List<TaskInfo>> getPendingTasks(String plantId) async {
    try {
      // Get PlantTaskProvider from DI
      final plantTaskProvider = di.sl<PlantTaskProvider>();

      // Load tasks if not already loaded for this plant
      await plantTaskProvider.loadTasksForPlant(plantId);

      // Get overdue and upcoming tasks
      final overdueTasks = plantTaskProvider.getOverdueTasksForPlant(plantId);
      final upcomingTasks = plantTaskProvider.getUpcomingTasksForPlant(plantId);

      // Convert to TaskInfo format
      final tasks = <TaskInfo>[];

      // Add overdue tasks
      for (final task in overdueTasks) {
        tasks.add(TaskInfo(
          type: task.type.toString().split('.').last,
          dueDate: task.scheduledDate,
          isOverdue: true,
        ));
      }

      // Add upcoming tasks (not overdue)
      for (final task in upcomingTasks) {
        if (!overdueTasks.contains(task)) {
          tasks.add(TaskInfo(
            type: task.type.toString().split('.').last,
            dueDate: task.scheduledDate,
            isOverdue: false,
          ));
        }
      }

      return tasks;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error loading tasks for plant $plantId: $e');
      }
      return [];
    }
  }

  Future<void> _loadInitialData() async {
    await _plantsProvider.loadPlants();
  }

  Future<void> _onRefresh() async {
    _plantsProvider.clearError();
    await _loadInitialData();
  }

  void _showAddPlantModal() {
    PlantFormDialog.show(context);
  }

  void _showEditPlantModal(Plant plant) {
    PlantFormDialog.show(context, plantId: plant.id);
  }

  void _showRemoveConfirmation(Plant plant) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remover Planta'),
            content: Text(
              'Tem certeza que deseja remover "${plant.name}"? '
              'Esta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _plantsProvider.deletePlant(plant.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${plant.name} foi removida'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remover'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _plantsProvider,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Enhanced App Bar - Optimized with Selector
              Selector<PlantsProvider, Map<String, dynamic>>(
                selector:
                    (context, provider) => {
                      'plantsCount': provider.plantsCount,
                      'searchQuery': provider.searchQuery,
                      'viewMode': provider.viewMode,
                    },
                builder: (context, appBarData, child) {
                  return EnhancedPlantsAppBar(
                    plantsCount: appBarData['plantsCount'] as int,
                    searchQuery: appBarData['searchQuery'] as String,
                    viewMode:
                        (appBarData['viewMode'] as ViewMode) == ViewMode.grid
                            ? AppBarViewMode.grid
                            : AppBarViewMode.list,
                    searchDelegate: this,
                    viewModeDelegate: this,
                    showSearchBar: true,
                  );
                },
              ),

              // Content Area - Optimized with Selector
              Expanded(
                child: Selector<PlantsProvider, Map<String, dynamic>>(
                  selector:
                      (context, provider) => {
                        'isLoading': provider.isLoading,
                        'error': provider.error,
                        'plants': provider.plants,
                        'searchResults': provider.searchResults,
                        'searchQuery': provider.searchQuery,
                        'viewMode': provider.viewMode,
                      },
                  builder: (context, contentData, child) {
                    // Loading state
                    if ((contentData['isLoading'] as bool) &&
                        (contentData['plants'] as List<Plant>).isEmpty) {
                      return const PlantsLoadingWidget();
                    }

                    // Error state
                    if (contentData['error'] != null &&
                        (contentData['plants'] as List<Plant>).isEmpty) {
                      return PlantsErrorWidget(
                        error: contentData['error'] as String,
                        onRetry: _loadInitialData,
                      );
                    }

                    // Determine which plants to show
                    final plantsToShow =
                        (contentData['searchQuery'] as String).isNotEmpty
                            ? (contentData['searchResults'] as List<Plant>)
                            : (contentData['plants'] as List<Plant>);

                    // Empty state
                    if (plantsToShow.isEmpty) {
                      return EmptyPlantsWidget(
                        isSearching:
                            (contentData['searchQuery'] as String).isNotEmpty,
                        searchQuery: contentData['searchQuery'] as String,
                        onClearSearch: onClearSearch,
                        onAddPlant: _showAddPlantModal,
                      );
                    }

                    // Plants list with RefreshIndicator
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: _EnhancedPlantsContent(
                        plants: plantsToShow,
                        viewMode: contentData['viewMode'] as ViewMode,
                        scrollController: _scrollController,
                        actions: this,
                        taskProvider: this,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Enhanced FAB
        floatingActionButton: _EnhancedFAB(
          onAddPlant: _showAddPlantModal,
          onScrollToTop: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }
}

class _EnhancedPlantsContent extends StatelessWidget {
  final List<Plant> plants;
  final ViewMode viewMode;
  final ScrollController scrollController;
  final IPlantCardActions actions;
  final ITaskDataProvider taskProvider;

  const _EnhancedPlantsContent({
    required this.plants,
    required this.viewMode,
    required this.scrollController,
    required this.actions,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (viewMode == ViewMode.grid) {
      return GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          return EnhancedPlantCard(
            key: ValueKey('grid_plant_${plant.id}'),
            plant: plant,
            actions: actions,
            taskProvider: taskProvider,
            isGridView: true,
          );
        },
      );
    } else {
      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          return EnhancedPlantCard(
            key: ValueKey('list_plant_${plant.id}'),
            plant: plant,
            actions: actions,
            taskProvider: taskProvider,
            isGridView: false,
          );
        },
      );
    }
  }
}

class _EnhancedFAB extends StatelessWidget {
  final VoidCallback onAddPlant;
  final VoidCallback onScrollToTop;

  const _EnhancedFAB({required this.onAddPlant, required this.onScrollToTop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      onPressed: onAddPlant,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(Icons.add, size: 24),
      label: const Text(
        'Nova Planta',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}
