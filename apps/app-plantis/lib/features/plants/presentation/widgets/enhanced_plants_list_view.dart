import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/plant.dart';
import '../providers/plants_notifier.dart';
import 'empty_plants_widget.dart';
import 'enhanced_plant_card.dart';
import 'enhanced_plants_app_bar.dart';
import 'plant_form_dialog.dart';
import 'plants_error_widget.dart';
import 'plants_loading_widget.dart';

/// Simple class to represent task information
class TaskInfo {
  final String type;
  final DateTime? dueDate;
  final bool isOverdue;

  const TaskInfo({
    required this.type,
    this.dueDate,
    this.isOverdue = false,
  });
}

/// Enhanced Plants List View siguiendo principios SOLID
/// S - Responsabilidad única: Solo maneja la vista principal de plantas
/// O - Abierto/cerrado: Extensible para nuevas funcionalidades
/// L - Liskov: Puede ser sustituido por cualquier Widget
/// I - Segregación de interfaces: Interfaces específicas para cada responsabilidad
/// D - Inversión de dependencias: Depende de abstracciones

class EnhancedPlantsListView extends ConsumerStatefulWidget {
  const EnhancedPlantsListView({super.key});

  @override
  ConsumerState<EnhancedPlantsListView> createState() =>
      _EnhancedPlantsListViewState();
}

class _EnhancedPlantsListViewState extends ConsumerState<EnhancedPlantsListView>
    with WidgetsBindingObserver
    implements ISearchDelegate, IViewModeDelegate, IPlantCardActions {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
    if (state == AppLifecycleState.resumed) {
      ref.read(plantsNotifierProvider.notifier).refreshPlants();
    }
  }

  @override
  void onSearchChanged(String query) {
    final notifier = ref.read(plantsNotifierProvider.notifier);
    if (query.trim().isEmpty) {
      notifier.clearSearch();
    } else {
      notifier.searchPlants(query);
    }
  }

  @override
  void onClearSearch() {
    ref.read(plantsNotifierProvider.notifier).clearSearch();
  }

  @override
  void onViewModeChanged(AppBarViewMode mode) {
    ref.read(plantsNotifierProvider.notifier).setViewMode(
          mode == AppBarViewMode.grid ? ViewMode.grid : ViewMode.list,
        );
  }

  @override
  void onTap(Plant plant) {}

  @override
  void onEdit(Plant plant) {
    _showEditPlantModal(plant);
  }

  @override
  void onRemove(Plant plant) {
    _showRemoveConfirmation(plant);
  }

  Future<void> _loadInitialData() async {
    await ref.read(plantsNotifierProvider.notifier).loadPlants();
  }

  Future<void> _onRefresh() async {
    final notifier = ref.read(plantsNotifierProvider.notifier);
    notifier.clearError();
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
      builder: (context) => AlertDialog(
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
              await ref
                  .read(plantsNotifierProvider.notifier)
                  .deletePlant(plant.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${plant.name} foi removida'),
                  backgroundColor: Colors.green,
                ),
              );
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

  Widget _buildAppBar() {
    final state = ref.watch(plantsNotifierProvider);

    return EnhancedPlantsAppBar(
      plantsCount: state.plants.length,
      searchQuery: state.searchQuery,
      viewMode: state.viewMode == ViewMode.grid
          ? AppBarViewMode.grid
          : AppBarViewMode.list,
      searchDelegate: this,
      viewModeDelegate: this,
      showSearchBar: true,
    );
  }

  Widget _buildContent() {
    final state = ref.watch(plantsNotifierProvider);

    if (state.isLoading && state.plants.isEmpty) {
      return const PlantsLoadingWidget();
    }

    if (state.error != null && state.plants.isEmpty) {
      return PlantsErrorWidget(
        error: state.error!,
        onRetry: _loadInitialData,
      );
    }

    final plantsToShow =
        state.searchQuery.isNotEmpty ? state.searchResults : state.plants;

    if (plantsToShow.isEmpty) {
      return EmptyPlantsWidget(
        isSearching: state.searchQuery.isNotEmpty,
        searchQuery: state.searchQuery,
        onClearSearch: onClearSearch,
        onAddPlant: _showAddPlantModal,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _EnhancedPlantsContent(
        plants: plantsToShow,
        viewMode: state.viewMode,
        scrollController: _scrollController,
        actions: this,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
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
    );
  }
}

class _EnhancedPlantsContent extends StatelessWidget {
  final List<Plant> plants;
  final ViewMode viewMode;
  final ScrollController scrollController;
  final IPlantCardActions actions;

  const _EnhancedPlantsContent({
    required this.plants,
    required this.viewMode,
    required this.scrollController,
    required this.actions,
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
