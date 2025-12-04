import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/localization/app_strings.dart';
import '../../../../../core/theme/plantis_colors.dart';
import '../../../../../shared/widgets/base_page_scaffold.dart';
import '../../../../../shared/widgets/responsive_layout.dart';
import '../../../domain/entities/plant.dart';
import '../../providers/plant_details_provider.dart';
import '../../providers/plant_task_provider.dart';
import '../../providers/plants_notifier.dart';
import '../plant_form_dialog.dart';
import 'plant_care_section.dart';
import 'plant_details_controller.dart';
import 'plant_details_error_widgets.dart';
import 'plant_details_invalid_state_widget.dart';
import 'plant_info_section.dart';
import 'plant_notes_section.dart';
import 'plant_tasks_section.dart';

/// Constantes para o PlantDetailsView
class _PlantDetailsConstants {
  // Cores para estados de loading e erro
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color darkCardColor = Color(0xFF2C2C2E);
}

/// Main widget for the plant details screen
///
/// This widget is responsible only for the visual structure and coordination
/// of components. All business logic is handled by the [PlantDetailsController].
///
/// Features provided:
/// - Plant information display with tabs (Overview, Tasks, Care, Notes)
/// - Loading and error states with user-friendly interfaces
/// - Image gallery integration
/// - Quick actions for common plant care tasks
/// - Plant management options (edit, delete, share, duplicate)
///
/// The widget uses a [CustomScrollView] with [SliverAppBar] for a modern
/// scrolling experience and [TabBarView] for organized content presentation.
///
/// Example usage:
/// ```dart
/// PlantDetailsView(plantId: 'plant-123')
/// ```
class PlantDetailsView extends ConsumerStatefulWidget {
  final String plantId;

  const PlantDetailsView({super.key, required this.plantId});

  @override
  ConsumerState<PlantDetailsView> createState() => _PlantDetailsViewState();
}

class _PlantDetailsViewState extends ConsumerState<PlantDetailsView>
    with TickerProviderStateMixin {
  PlantDetailsController? _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        FocusScope.of(context).unfocus();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeController();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller = null;
    super.dispose();
  }

  void _initializeController() {
    try {
      if (kDebugMode) {
        print(
          '🔧 PlantDetailsView._initializeController - plantId: ${widget.plantId}',
        );
      }

      final notifier = ref.read(plantDetailsNotifierProvider.notifier);
      final state = ref.read(plantDetailsNotifierProvider);
      final provider = PlantDetailsProvider(notifier, state);
      final taskProvider = ref.read(plantTaskNotifierProvider.notifier);

      if (kDebugMode) {
        print('✅ PlantDetailsView._initializeController - Providers loaded');
      }

      _controller = PlantDetailsController(
        provider: provider,
        onBack: _onBack,
        onNavigateToEdit: _onNavigateToEdit,
        onNavigateToImages: (plantId) {},
        onNavigateToSchedule: (plantId) {},
        onShowSnackBar: _showSnackBar,
        onShowSnackBarWithColor:
            (message, type, {Color? backgroundColor}) => _showSnackBarWithColor(
              message,
              backgroundColor: backgroundColor,
            ),
        onShowDialog: _onShowDialog,
        onShowBottomSheet: _onShowBottomSheet,
        onPlantDeleted: _syncPlantDeletion,
      );

      if (kDebugMode) {
        print('✅ PlantDetailsView._initializeController - Controller created');
      }

      _controller!.loadPlant(widget.plantId);
      _initializeTasksIfNeeded(taskProvider);

      if (kDebugMode) {
        print(
          '✅ PlantDetailsView._initializeController - Initialization complete',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('💥 PlantDetailsView._initializeController - Error: $e');
        print('Stack trace: $stackTrace');
      }
      debugPrint('Error initializing PlantDetailsView: $e');
    }
  }

  void _onBack() {
    if (!mounted) return;
    Navigator.of(context).pop();
    _notifyListScreenUpdate();
  }

  Future<void> _onNavigateToEdit(String plantId) async {
    if (!mounted) return;
    final result = await PlantFormDialog.show(context, plantId: plantId);
    if (result == true && mounted) {
      final notifier = ref.read(plantDetailsNotifierProvider.notifier);
      await notifier.reloadPlant(plantId);
      if (kDebugMode) {
        final state = ref.read(plantDetailsNotifierProvider);
        print(
          '✅ PlantDetailsView - Plant reloaded after edit: ${state.plant?.name}',
        );
      }
    }
  }

  void _onShowDialog(Widget dialog) {
    if (!mounted) return;
    showDialog<void>(context: context, builder: (_) => dialog);
  }

  void _onShowBottomSheet(Widget bottomSheet) {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => bottomSheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantDetailsState = ref.watch(plantDetailsNotifierProvider);

    return BasePageScaffold(
      body: ResponsiveLayout(
        child: Builder(
          builder: (context) {
            final details = plantDetailsState;
            final plant = details.plant;

            // Se está carregando E não tem planta, criar planta placeholder
            // para usar com Skeletonizer
            final Plant displayPlant = plant ??
                Plant(
                  id: 'loading',
                  name: 'Carregando nome da planta',
                  species: 'Carregando espécie',
                  spaceId: 'loading',
                  notes: 'Carregando observações',
                  plantingDate: DateTime.now(),
                );

            final bool isLoading = details.isLoading && plant == null;

            if (details.hasError && plant == null) {
              return PlantDetailsErrorState(
                errorMessage: details.errorMessage,
                onRetry: () => _controller?.refresh(widget.plantId),
                onBack: () => Navigator.of(context).pop(),
                plantId: widget.plantId,
              );
            }

            // Validar dados apenas se não estiver carregando
            if (!isLoading && !_isPlantDataValid(displayPlant)) {
              return PlantDetailsInvalidDataState(
                context: context,
                plant: displayPlant,
                onEdit: () => _controller?.editPlant(displayPlant),
              );
            }

            return _buildMainContent(context, displayPlant, isLoading);
          },
        ),
      ),
    );
  }

  /// Initializes plant tasks if none exist for the current plant
  ///
  /// This method checks if the plant already has tasks assigned and
  /// generates initial tasks if none are found. It ensures that every
  /// plant has basic care reminders set up automatically.
  ///
  /// The initialization process:
  /// 1. Checks if tasks already exist for the plant
  /// 2. If no tasks found, generates default tasks based on plant type
  /// 3. Tasks include watering, fertilizing, and other care reminders
  ///
  /// This is called once during widget initialization to avoid duplicate
  /// task creation on subsequent widget rebuilds.
  ///
  /// Parameters:
  /// - [taskProvider]: The task provider instance for task management
  void _initializeTasksIfNeeded(PlantTaskProvider taskProvider) {
    // Usa um listener para reagir quando a planta for carregada
    ref.listenManual(plantDetailsNotifierProvider, (previous, next) async {
      if (!mounted) return;
      
      // Se a planta acabou de ser carregada
      if (previous?.plant == null && next.plant != null) {
        try {
          // Primeiro carrega as tarefas do repositório
          await taskProvider.loadTasksForPlant(widget.plantId);
          if (!mounted) return;
          
          // Depois verifica se precisa gerar novas tarefas
          final tasks = taskProvider.getTasksForPlant(widget.plantId);
          if (tasks.isEmpty && next.plant!.config != null) {
            await taskProvider.generateTasksForPlant(next.plant!);
          }
        } catch (e) {
          debugPrint('Error initializing tasks: $e');
        }
      }
    }, fireImmediately: true);
  }

  /// Shows the new task creation modal
  ///
  /// This method displays a comprehensive task creation interface
  /// where users can create custom care reminders for their plants.
  ///
  /// The task creation modal includes:
  /// - Task type selection (watering, fertilizing, pruning, etc.)
  /// - Custom title and description fields
  /// - Date picker for scheduling
  /// - Form validation and submission
  ///
  /// After successful task creation, the task is added to the plant's
  /// care schedule and the user receives confirmation.
  ///
  /// Parameters:
  /// - [context]: Build context for showing the modal
  /// - [plant]: The plant entity for which to create the task

  /// Returns the default title for a new task of the given type
  ///
  /// This method provides sensible default task titles that users
  /// can customize when creating new plant care tasks.
  ///
  /// Parameters:
  /// - [type]: The task type enum to get the default title for
  ///
  /// Returns:
  /// - A localized default title string for the task type
  ///
  /// Example:
  /// ```dart
  /// final title = _getDefaultTaskTitle(TaskType.watering); // returns "Regar planta"
  /// ```

  /// Creates and saves a new plant care task
  ///
  /// This method handles the actual task creation process by:
  /// 1. Creating a new PlantTask entity with provided parameters
  /// 2. Adding it to the task provider's list for the plant
  /// 3. Closing the creation modal
  /// 4. Showing success feedback to the user
  ///
  /// The task is immediately available in the Tasks tab and will
  /// trigger notifications based on the scheduled date.
  ///
  /// Parameters:
  /// - [context]: Build context for navigation and feedback
  /// - [plant]: The plant entity this task belongs to
  /// - [type]: The type of care task (watering, fertilizing, etc.)
  /// - [title]: User-provided or default title for the task
  /// - [description]: Optional detailed description of the task
  /// - [scheduledDate]: When the task should be performed

  void _syncPlantDeletion(String plantId) {
    // Schedule the refresh for after the current frame to avoid potential
    // conflicts with the widget lifecycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        ref.read(plantsNotifierProvider.notifier).refreshPlants();
        if (kDebugMode) {
          print(
            '✅ _syncPlantDeletion: Refresh requested for plantId: $plantId',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ _syncPlantDeletion: Failed to refresh plants list: $e');
        }
      }
    });
  }

  /// Notifies the list screen to update after changes.
  void _notifyListScreenUpdate() {
    // A small delay ensures the update happens after any navigation animations.
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      try {
        ref.read(plantsNotifierProvider.notifier).refreshPlants();
        if (kDebugMode) {
          print('✅ _notifyListScreenUpdate: Plants list refresh requested.');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ _notifyListScreenUpdate: Failed to refresh plants list: $e');
        }
      }
    });
  }

  void _handleMenuAction(String action, Plant plant) {
    switch (action) {
      case 'edit':
        _controller?.editPlant(plant);
        break;
      case 'delete':
        _controller?.confirmDelete(plant, _buildDeleteConfirmDialog);
        break;
    }
  }

  Widget _buildDeleteConfirmDialog(Plant plant) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: _PlantDetailsConstants.lightBackgroundColor,
      title: const Text('Excluir planta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tem certeza que deseja excluir "${plant.displayName}"?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PlantisColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: PlantisColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_outlined,
                  color: PlantisColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta ação não pode ser desfeita.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PlantisColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        StatefulBuilder(
          builder: (context, setState) {
            return TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Fechar diálogo primeiro

                // Usar o plantsNotifierProvider para deletar
                // Isso garante que a lista seja atualizada automaticamente
                final success = await ref.read(plantsNotifierProvider.notifier).deletePlant(plant.id);

                if (success) {
                  _showSnackBarWithColor(
                    AppStrings.plantDeletedSuccessfully,
                    backgroundColor: Colors.green,
                  );
                  _onBack();
                } else {
                  // Obtém a mensagem de erro específica do provider
                  final errorMessage = ref.read(plantsNotifierProvider).error ??
                      AppStrings.errorDeletingPlant;
                  _showSnackBarWithColor(
                    errorMessage,
                    backgroundColor: Colors.red,
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: PlantisColors.error),
              child: const Text('Excluir'),
            );
          },
        ),
      ],
    );
  }

  void _showSnackBar(String message, String type) {
    Color? backgroundColor;
    switch (type) {
      case 'error':
        backgroundColor = Theme.of(context).colorScheme.error;
        break;
      case 'success':
        backgroundColor = PlantisColors.success;
        break;
      default:
        backgroundColor = null;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSnackBarWithColor(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Builds the main content area with plant details and tabs
  ///
  /// This method creates the primary interface for displaying plant information
  /// using a tabbed layout. It includes:
  /// - Custom app bar with plant image and action buttons
  /// - Tab bar with four sections: Overview, Tasks, Care, Notes
  /// - Responsive layout that adapts to screen size
  /// - Floating action buttons for quick plant management
  ///
  /// The content is organized in a [CustomScrollView] for smooth scrolling
  /// and optimal performance with large amounts of plant data.
  ///
  /// Parameters:
  /// - [plant]: The plant entity containing all plant information
  ///
  /// Returns:
  /// - A [Widget] containing the complete plant details interface
  Widget _buildMainContent(BuildContext context, Plant plant, bool isLoading) {
    return Column(
      children: [
        _buildHeader(context, plant),
        Expanded(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color:
                  Colors
                      .transparent, // Transparente para usar o fundo do BasePageScaffold
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xs),
                _buildTabBar(context),
                const SizedBox(height: AppSpacing.xs),
                Expanded(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color:
                          Colors
                              .transparent, // Transparente para usar o fundo do BasePageScaffold
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(context, plant, isLoading),
                        _buildTasksTab(context, plant),
                        _buildCareTab(context, plant),
                        _buildNotesTab(context, plant),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Plant plant) {
    return PlantisHeader(
      title: plant.displayName,
      subtitle:
          plant.species?.isNotEmpty == true
              ? plant.species!
              : 'Detalhes da planta',
      margin: const EdgeInsets.only(
        bottom: 8,
        top: 4,
      ), // Usar mesmo margin das outras páginas
      onBackPressed: () => _controller?.goBack(),
      actions: [
        PopupMenuButton<String>(
          color: _PlantDetailsConstants.lightBackgroundColor,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
          ),
          onSelected: (action) => _handleMenuAction(action, plant),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: PlantisColors.error,
                    ),
                    title: Text(
                      'Excluir',
                      style: TextStyle(color: PlantisColors.error),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildPlantImageSection(BuildContext context, Plant plant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: PlantisColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: PlantisColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: PlantisColors.primary.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child:
              plant.hasImage
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(58),
                    child: Image.network(
                      plant.primaryImageUrl!,
                      width: 116,
                      height: 116,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildPlaceholderIcon(),
                    ),
                  )
                  : _buildPlaceholderIcon(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(Icons.eco, color: PlantisColors.primary, size: 48),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? _PlantDetailsConstants.darkCardColor
                : _PlantDetailsConstants.lightBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.info_outline), text: AppStrings.overview),
          Tab(icon: Icon(Icons.task_alt), text: AppStrings.tasks),
          Tab(icon: Icon(Icons.spa), text: AppStrings.care),
          Tab(icon: Icon(Icons.comment), text: AppStrings.notes),
        ],
        indicator: BoxDecoration(
          color: PlantisColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, Plant plant, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Column(
        children: [
          _buildPlantImageSection(context, plant),
          const SizedBox(height: AppSpacing.lg),
          // Aplica Skeletonizer apenas no conteúdo dinâmico
          Skeletonizer(
            enabled: isLoading,
            child: PlantInfoSection(plant: plant),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: PlantTasksSection(plant: plant),
    );
  }

  Widget _buildCareTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: PlantCareSection(plant: plant),
    );
  }

  Widget _buildNotesTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: PlantNotesSection(plant: plant),
    );
  }

  /// Validates if plant data is complete and valid for display
  ///
  /// This method performs basic validation checks to ensure the plant
  /// has minimum required information to be properly displayed.
  ///
  /// Validation checks:
  /// - Plant ID is not empty
  /// - Display name is not empty or whitespace-only
  /// - Basic plant information is present
  ///
  /// Currently allows plants with minimal data to be displayed,
  /// but this can be extended for more strict validation if needed.
  ///
  /// Parameters:
  /// - [plant]: The plant entity to validate
  ///
  /// Returns:
  /// - `true` if plant data is valid for display, `false` otherwise
  bool _isPlantDataValid(Plant plant) {
    if (plant.id.isEmpty) return false;
    if (plant.displayName.trim().isEmpty) return false;
    return true; // Allow plants with minimal data to be displayed
  }
}
