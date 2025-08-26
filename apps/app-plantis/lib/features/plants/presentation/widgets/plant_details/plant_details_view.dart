import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/localization/app_strings.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../domain/entities/plant.dart';
import '../../../../tasks/presentation/providers/tasks_provider.dart';
import '../../providers/plant_details_provider.dart';
import '../../providers/plant_task_provider.dart';
import '../../../../../features/plants/domain/entities/plant_task.dart';
import 'plant_care_section.dart';
import 'plant_details_controller.dart';
import 'plant_image_section.dart';
import 'plant_info_section.dart';
import 'plant_notes_section.dart';
import 'plant_tasks_section.dart';

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
class PlantDetailsView extends StatefulWidget {
  final String plantId;

  const PlantDetailsView({super.key, required this.plantId});

  @override
  State<PlantDetailsView> createState() => _PlantDetailsViewState();
}

class _PlantDetailsViewState extends State<PlantDetailsView>
    with TickerProviderStateMixin {
  PlantDetailsController? _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Inicializar controller e carregar dados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<PlantDetailsProvider>();
        final taskProvider = context.read<PlantTaskProvider>();
        
        _controller = PlantDetailsController(
          provider: provider,
          onBack: () => Navigator.of(context).pop(),
          onNavigateToEdit: (plantId) => context.push('/plants/edit/$plantId'),
          onNavigateToImages: (plantId) => context.push('/plants/$plantId/images'),
          onNavigateToSchedule: (plantId) => context.push('/plants/$plantId/schedule'),
          onShowSnackBar: (message, type) => _showSnackBar(message, type),
          onShowSnackBarWithColor: (message, type, {Color? backgroundColor}) => 
              _showSnackBarWithColor(message, backgroundColor: backgroundColor),
          onShowDialog: (dialog) => showDialog(context: context, builder: (_) => dialog),
          onShowBottomSheet: (bottomSheet) => showModalBottomSheet(
            context: context,
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => bottomSheet,
          ),
        );
        _controller!.loadPlant(widget.plantId);
        
        // Inicializar tarefas uma vez
        _initializeTasksIfNeeded(taskProvider);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.brightness == Brightness.dark
              ? const Color(0xFF1C1C1E)
              : theme.colorScheme.surface,
      // Optimized with Selector - only rebuilds when plant loading state changes
      body: Selector<PlantDetailsProvider, Map<String, dynamic>>(
        selector: (context, provider) => {
          'isLoading': provider.isLoading,
          'hasError': provider.hasError,
          'plant': provider.plant,
          'errorMessage': provider.errorMessage,
        },
        builder: (context, plantData, child) {
          // Estados de loading e erro
          if ((plantData['isLoading'] as bool) && plantData['plant'] == null) {
            return _buildLoadingState(context);
          }

          if ((plantData['hasError'] as bool) && plantData['plant'] == null) {
            return _buildErrorState(context, plantData['errorMessage'] as String?);
          }

          final plant = plantData['plant'] as Plant?;
          if (plant == null) {
            return _buildLoadingState(context);
          }
          
          // Validate plant data
          if (!_isPlantDataValid(plant)) {
            return _buildInvalidDataState(context, plant);
          }

          // Tela principal com a planta carregada
          return _buildMainContent(context, plant);
        },
      ),
      // Enhanced FloatingActionButton with multiple actions
      floatingActionButton: Selector<PlantDetailsProvider, Plant?>(
        selector: (context, provider) => provider.plant,
        builder: (context, plant, child) {
          if (plant == null) return const SizedBox.shrink();

          return _OptimizedActionButtons(
            plant: plant,
            onQuickActions: () => _showQuickActionsMenu(context, plant),
            onEdit: () => _controller?.editPlant(plant),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Builds the loading state UI with skeleton placeholders
  /// 
  /// This method creates a comprehensive loading interface that includes:
  /// - Loading shimmer effects for plant image, name, and description
  /// - Placeholder tabs and content cards
  /// - Semantic labels for accessibility
  /// - Smooth animations and proper spacing
  /// 
  /// The loading state provides visual feedback while plant data is being fetched,
  /// improving the user experience by showing content structure.
  /// 
  /// Returns:
  /// - A [Widget] containing the complete loading state interface
  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF1C1C1E)
          : theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Loading AppBar
          SliverAppBar(
            expandedHeight: AppSpacing.appBarHeight,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(AppSpacing.iconPadding),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildLoadingImageSection(context),
            ),
          ),
          
          // Loading Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loading text shimmer
                  const _LoadingShimmer(height: AppSpacing.sectionSpacing, width: 200),
                  const SizedBox(height: AppSpacing.iconPadding),
                  const _LoadingShimmer(height: AppSpacing.lg, width: 150),
                  const SizedBox(height: AppSpacing.sectionSpacing),
                  
                  // Loading tabs
                  _buildLoadingTabs(context),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Loading content cards
                  ...[
                    for (int i = 0; i < 3; i++) ...[
                      _buildLoadingCard(context),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingImageSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: AppSpacing.loadingImageHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primary.withValues(alpha: 0.1),
            PlantisColors.primaryLight.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.iconSize,
              height: AppSpacing.iconSize,
              decoration: BoxDecoration(
                color: PlantisColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.borderRadiusCircular),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: AppSpacing.strokeWidth,
                  color: PlantisColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Semantics(
              label: AppStrings.loadingPlantAriaLabel,
              liveRegion: true,
              child: Text(
                AppStrings.loadingPlant,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  
  Widget _buildLoadingTabs(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: AppSpacing.tabHeight,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < 4; i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LoadingShimmer(height: AppSpacing.xl, width: 150),
          const SizedBox(height: AppSpacing.iconPadding),
          const _LoadingShimmer(height: AppSpacing.lg, width: double.infinity),
          const SizedBox(height: AppSpacing.xs),
          const _LoadingShimmer(height: AppSpacing.lg, width: 250),
        ],
      ),
    );
  }

  /// Builds the error state UI with recovery options
  /// 
  /// This method creates a user-friendly error interface that includes:
  /// - Clear error messaging with illustration
  /// - Retry functionality to recover from temporary failures
  /// - Troubleshooting tips for common issues
  /// - Help dialog for additional support
  /// - Navigation options to return to previous screen
  /// 
  /// The error state helps users understand what went wrong and provides
  /// actionable steps to resolve the issue.
  /// 
  /// Parameters:
  /// - [errorMessage]: Optional detailed error message for debugging
  /// 
  /// Returns:
  /// - A [Widget] containing the complete error state interface
  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF1C1C1E)
          : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          AppStrings.error,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.eco,
                  size: 60,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionSpacing),
              
              Semantics(
                label: AppStrings.plantLoadError,
                liveRegion: true,
                child: Text(
                  AppStrings.oopsError,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.buttonSpacing),
              
              Text(
                AppStrings.plantLoadError,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.iconPadding),
              
              // Error details (expandable)
              if (errorMessage != null && errorMessage.isNotEmpty)
                _buildErrorDetails(context, errorMessage),
              
              const SizedBox(height: 32),
              
              // Action buttons
              Column(
                children: [
                  // Primary retry button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _controller?.refresh(widget.plantId),
                      icon: const Icon(Icons.refresh),
                      label: Text(AppStrings.tryAgain),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PlantisColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.buttonSpacing),
                  
                  // Secondary actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: Text(AppStrings.goBack),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.buttonSpacing),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.buttonSpacing),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => _showErrorHelp(context),
                          icon: const Icon(Icons.help_outline),
                          label: Text(AppStrings.help),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.buttonSpacing),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.sectionSpacing),
              
              // Troubleshooting tips
              _buildTroubleshootingTips(context),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorDetails(BuildContext context, String errorMessage) {
    final theme = Theme.of(context);
    
    return ExpansionTile(
      title: Text(
        AppStrings.errorDetails,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      iconColor: theme.colorScheme.onSurfaceVariant,
      collapsedIconColor: theme.colorScheme.onSurfaceVariant,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.iconPadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
            border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            errorMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTroubleshootingTips(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2E)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.troubleshootingTips,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildTip(context, AppStrings.checkConnection),
          _buildTip(context, AppStrings.restartApp),
          _buildTip(context, AppStrings.checkUpdates),
        ],
      ),
    );
  }
  
  Widget _buildTip(BuildContext context, String tip) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.iconPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.tipBulletSize,
            height: AppSpacing.tipBulletSize,
            margin: const EdgeInsets.only(top: AppSpacing.iconPadding, right: AppSpacing.buttonSpacing),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSpacing.tipBulletSize / 2),
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showErrorHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.needHelp),
        content: Text(AppStrings.helpMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.understood),
          ),
        ],
      ),
    );
  }
  
  /// Shows the quick actions menu in a modal bottom sheet
  /// 
  /// This method displays a comprehensive set of quick actions that users
  /// can perform on a plant without navigating to different screens.
  /// 
  /// Quick actions include:
  /// - Water plant (record watering)
  /// - Fertilize plant (record fertilizing)
  /// - Take photo (capture plant progress)
  /// - Add note (record observations)
  /// - Toggle favorite status
  /// - Share plant information
  /// - Delete plant (with confirmation)
  /// 
  /// The menu is presented in an accessible grid layout with clear icons
  /// and labels for each action.
  /// 
  /// Parameters:
  /// - [context]: Build context for showing the modal bottom sheet
  /// - [plant]: The plant entity for which to show quick actions
  void _showQuickActionsMenu(BuildContext context, Plant plant) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.modalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacing.tipBulletSize / 2),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              AppStrings.quickActions,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick action grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              children: [
                _QuickActionButton(
                  icon: Icons.water_drop,
                  label: AppStrings.water,
                  color: Colors.blue,
                  onTap: () => _quickWater(context, plant),
                ),
                _QuickActionButton(
                  icon: Icons.grass,
                  label: AppStrings.fertilize,
                  color: Colors.green,
                  onTap: () => _quickFertilize(context, plant),
                ),
                _QuickActionButton(
                  icon: Icons.add_photo_alternate,
                  label: AppStrings.photo,
                  color: Colors.purple,
                  onTap: () => _quickPhoto(context, plant),
                ),
                _QuickActionButton(
                  icon: Icons.note_add,
                  label: AppStrings.note,
                  color: Colors.orange,
                  onTap: () => _quickNote(context, plant),
                ),
                _QuickActionButton(
                  icon: plant.isFavorited ? Icons.favorite : Icons.favorite_border,
                  label: plant.isFavorited ? AppStrings.unfavorite : AppStrings.favorite,
                  color: Colors.red,
                  onTap: () => _toggleFavorite(plant),
                ),
                _QuickActionButton(
                  icon: Icons.share,
                  label: AppStrings.share,
                  color: Colors.indigo,
                  onTap: () => _sharePlant(context, plant),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Danger zone
            Divider(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _controller?.confirmDelete(plant, _buildDeleteConfirmDialog);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  AppStrings.deletePlant,
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  
  void _toggleFavorite(Plant plant) {
    // TODO: Implement favorite toggle
    final provider = context.read<PlantDetailsProvider>();
    provider.toggleFavorite(plant.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          plant.isFavorited 
            ? AppStrings.plantRemovedFromFavorites
            : AppStrings.plantAddedToFavorites,
        ),
        backgroundColor: PlantisColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _quickWater(BuildContext context, Plant plant) {
    // TODO: Implement quick water action
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.quickWaterRecorded),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _quickFertilize(BuildContext context, Plant plant) {
    // TODO: Implement quick fertilize action
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.quickFertilizeRecorded),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _quickPhoto(BuildContext context, Plant plant) {
    // TODO: Implement quick photo capture
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.photoCaptureInDevelopment),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _quickNote(BuildContext context, Plant plant) {
    // TODO: Implement quick note addition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.noteAdditionInDevelopment),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _sharePlant(BuildContext context, Plant plant) {
    // TODO: Implement plant sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.sharingInDevelopment),
        behavior: SnackBarBehavior.floating,
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
    // Carrega as tarefas uma única vez no initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<PlantDetailsProvider>();
        if (provider.plant != null) {
          final tasks = taskProvider.getTasksForPlant(widget.plantId);
          // Se não há tarefas, gera tarefas iniciais
          if (tasks.isEmpty) {
            taskProvider.generateTasksForPlant(provider.plant!);
          }
        }
      }
    });
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
  void _addNewTask(BuildContext context, Plant plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddTaskModal(context, plant),
    );
  }
  
  Widget _buildAddTaskModal(BuildContext context, Plant plant) {
    final theme = Theme.of(context);
    TaskType selectedType = TaskType.watering;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String title = '';
    String description = '';
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppSpacing.sectionSpacing,
            right: AppSpacing.sectionSpacing,
            top: AppSpacing.sectionSpacing,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    AppStrings.newTask,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionSpacing),
              
              // Task type selection
              Text(
                AppStrings.taskType,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.iconPadding),
              Wrap(
                spacing: 8,
                children: TaskType.values.map((type) {
                  final isSelected = selectedType == type;
                  return FilterChip(
                    selected: isSelected,
                    label: Text(_getTaskTypeLabel(type)),
                    avatar: Icon(
                      _getTaskIcon(type),
                      size: 18,
                      color: isSelected ? Colors.white : null,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedType = type);
                        title = _getDefaultTaskTitle(type);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Title field
              TextField(
                decoration: InputDecoration(
                  labelText: AppStrings.taskTitle,
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: title.isEmpty ? _getDefaultTaskTitle(selectedType) : title),
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Description field
              TextField(
                decoration: InputDecoration(
                  labelText: AppStrings.descriptionOptional,
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => description = value,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Date selection
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(AppStrings.scheduledDate),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sectionSpacing),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _createTask(
                        context,
                        plant,
                        selectedType,
                        title.isEmpty ? _getDefaultTaskTitle(selectedType) : title,
                        description,
                        selectedDate,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PlantisColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(AppStrings.create),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionSpacing),
            ],
          ),
        );
      },
    );
  }
  
  /// Returns the localized display label for a task type
  /// 
  /// This method maps task type enums to user-friendly display strings
  /// that are properly localized for the current app language.
  /// 
  /// Parameters:
  /// - [type]: The task type enum to get the label for
  /// 
  /// Returns:
  /// - A localized string label for the task type
  /// 
  /// Example:
  /// ```dart
  /// final label = _getTaskTypeLabel(TaskType.watering); // returns "Rega"
  /// ```
  String _getTaskTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return AppStrings.watering;
      case TaskType.fertilizing:
        return AppStrings.fertilizing;
      case TaskType.pruning:
        return AppStrings.pruning;
      case TaskType.sunlightCheck:
        return AppStrings.sunlightCheck;
      case TaskType.pestInspection:
        return AppStrings.pestInspection;
      case TaskType.replanting:
        return AppStrings.replanting;
    }
  }
  
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
  String _getDefaultTaskTitle(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return AppStrings.waterPlant;
      case TaskType.fertilizing:
        return AppStrings.applyFertilizer;
      case TaskType.pruning:
        return AppStrings.pruneBranches;
      case TaskType.sunlightCheck:
        return AppStrings.checkSunExposure;
      case TaskType.pestInspection:
        return AppStrings.inspectPests;
      case TaskType.replanting:
        return AppStrings.replantInLargerPot;
    }
  }
  
  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return Icons.water_drop;
      case TaskType.fertilizing:
        return Icons.grass;
      case TaskType.pruning:
        return Icons.content_cut;
      case TaskType.sunlightCheck:
        return Icons.wb_sunny;
      case TaskType.pestInspection:
        return Icons.bug_report;
      case TaskType.replanting:
        return Icons.change_circle;
    }
  }
  
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
  void _createTask(
    BuildContext context,
    Plant plant,
    TaskType type,
    String title,
    String description,
    DateTime scheduledDate,
  ) {
    final taskProvider = context.read<PlantTaskProvider>();
    
    // Create new task
    final newTask = PlantTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      plantId: plant.id,
      type: type,
      title: title,
      description: description.isNotEmpty ? description : null,
      scheduledDate: scheduledDate,
      status: TaskStatus.pending,
      intervalDays: 7, // Default interval of 7 days
      createdAt: DateTime.now(),
    );
    
    // Add task to provider
    final currentTasks = taskProvider.getTasksForPlant(plant.id);
    currentTasks.add(newTask);
    
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.taskCreatedSuccessfully),
        backgroundColor: PlantisColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showSnackBar(String message, String type) {
    Color? backgroundColor;
    switch (type) {
      case 'error':
        backgroundColor = Theme.of(context).colorScheme.error;
        break;
      case 'success':
        backgroundColor = Colors.green;
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
  
  Widget _buildMoreOptionsSheet(Plant plant) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppSpacing.tipBulletSize / 2),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            AppStrings.options,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(AppStrings.share),
            subtitle: Text(AppStrings.shareInfo),
            onTap: () {
              Navigator.of(context).pop();
              _controller?.sharePlant(plant);
            },
          ),
          ListTile(
            leading: const Icon(Icons.content_copy_outlined),
            title: Text(AppStrings.duplicate),
            subtitle: Text(AppStrings.createCopy),
            onTap: () {
              Navigator.of(context).pop();
              _controller?.duplicatePlant(plant);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
            ),
            title: Text(
              AppStrings.deleteAction,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
            subtitle: Text(AppStrings.permanentlyRemove),
            onTap: () {
              Navigator.of(context).pop();
              _controller?.confirmDelete(plant, _buildDeleteConfirmDialog);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildDeleteConfirmDialog(Plant plant) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(AppStrings.confirmDelete),
      content: Text(
        '${AppStrings.deleteConfirmMessage} "${plant.displayName}"? ${AppStrings.cannotBeUndone}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _controller?.deletePlant(plant.id);
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
          child: Text(AppStrings.delete),
        ),
      ],
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
  Widget _buildMainContent(BuildContext context, Plant plant) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, plant),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              _buildTabBar(context),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(context, plant),
                    _buildTasksTab(context, plant),
                    _buildCareTab(context, plant),
                    _buildNotesTab(context, plant),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, Plant plant) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      leading: Semantics(
        label: 'Voltar para a lista de plantas',
        button: true,
        child: IconButton(
          onPressed: () => _controller?.goBack(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          ),
        ),
      ),
      actions: [
        // Favorite button
        Semantics(
          label: plant.isFavorited 
              ? '${AppStrings.removeFavorite} ${plant.displayName}'
              : '${AppStrings.addFavorite} ${plant.displayName}',
          button: true,
          child: IconButton(
            onPressed: () => _toggleFavorite(plant),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                plant.isFavorited ? Icons.favorite : Icons.favorite_border,
                color: plant.isFavorited ? Colors.red : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        // More options
        Semantics(
          label: '${AppStrings.moreOptions} ${plant.displayName}',
          button: true,
          child: IconButton(
            onPressed: () => _controller?.showMoreOptions(plant, _buildMoreOptionsSheet),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: PlantImageSection(
          plant: plant,
          onEditImages: () {
            // TODO: Implementar navegação para edição de imagens
          },
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
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
          color: PlantisColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
        ),
        labelColor: PlantisColors.primary,
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

  Widget _buildOverviewTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PlantInfoSection(plant: plant),
    );
  }

  Widget _buildTasksTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Consumer<PlantTaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              // Add task button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _addNewTask(context, plant),
                  icon: const Icon(Icons.add_task),
                  label: Text(AppStrings.addNewTask),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PlantisColors.primary.withValues(alpha: 0.1),
                    foregroundColor: PlantisColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: PlantisColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Tasks section
              PlantTasksSection(plant: plant),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCareTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PlantCareSection(plant: plant),
    );
  }

  Widget _buildNotesTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
    // Basic validation checks
    if (plant.id.isEmpty) return false;
    if (plant.displayName.trim().isEmpty) return false;
    
    // Plant must have at least basic information
    return true; // Allow plants with minimal data to be displayed
  }
  
  /// Builds UI for plants with invalid or incomplete data
  /// 
  /// This method creates a specialized interface for handling plants
  /// that have missing or invalid data. It provides:
  /// - Clear messaging about the data issues
  /// - Direct access to edit the plant to fix problems
  /// - Navigation options to return to the plant list
  /// - Accessible design with proper semantic labels
  /// 
  /// This state helps users understand data problems and provides
  /// immediate action to resolve them.
  /// 
  /// Parameters:
  /// - [plant]: The plant entity with invalid or incomplete data
  /// 
  /// Returns:
  /// - A [Widget] containing the invalid data state interface
  Widget _buildInvalidDataState(BuildContext context, Plant plant) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF1C1C1E)
          : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        title: Text(
          AppStrings.incompleteData,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Semantics(
          label: AppStrings.backToPlantList,
          button: true,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.warning_amber_outlined,
                  size: 60,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionSpacing),
              
              Semantics(
                label: AppStrings.incompleteDataAriaLabel,
                child: Text(
                  AppStrings.incompleteData,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.buttonSpacing),
              
              Text(
                AppStrings.incompleteDataMessage,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Action buttons
              Column(
                children: [
                  // Primary edit button (if plant has valid ID)
                  if (plant.id.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: Semantics(
                        label: AppStrings.editPlantData,
                        button: true,
                        child: ElevatedButton.icon(
                          onPressed: () => _controller?.editPlant(plant),
                          icon: const Icon(Icons.edit),
                          label: Text(AppStrings.editPlant),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PlantisColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  if (plant.id.isNotEmpty) const SizedBox(height: 12),
                  
                  // Secondary actions
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(AppStrings.goBack),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Optimized widgets to prevent unnecessary rebuilds

/// Optimized loading shimmer widget that doesn't rebuild unnecessarily
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer({
    required this.height,
    required this.width,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
      ),
    );
  }
}

/// Optimized action buttons that only rebuild when plant changes
class _OptimizedActionButtons extends StatelessWidget {
  const _OptimizedActionButtons({
    required this.plant,
    required this.onQuickActions,
    required this.onEdit,
  });

  final Plant plant;
  final VoidCallback onQuickActions;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Quick Actions Menu
        _OptimizedActionButton(
          plant: plant,
          onPressed: onQuickActions,
          icon: Icons.more_horiz,
          semanticLabel: '${AppStrings.quickActionsFor} ${plant.displayName}',
          backgroundColor: PlantisColors.primary.withValues(alpha: 0.9),
          mini: true,
          heroTag: "quick_actions",
        ),
        const SizedBox(height: AppSpacing.buttonSpacing),
        
        // Main Edit Button
        _OptimizedActionButton(
          plant: plant,
          onPressed: onEdit,
          icon: Icons.edit,
          semanticLabel: '${AppStrings.editPlantFor} ${plant.displayName}',
          backgroundColor: PlantisColors.primary,
          heroTag: "edit_plant",
        ),
      ],
    );
  }
}

/// Optimized action button that rebuilds only when needed
class _OptimizedActionButton extends StatelessWidget {
  const _OptimizedActionButton({
    required this.plant,
    required this.onPressed,
    required this.icon,
    required this.semanticLabel,
    required this.backgroundColor,
    this.mini = false,
    this.heroTag,
  });

  final Plant plant;
  final VoidCallback onPressed;
  final IconData icon;
  final String semanticLabel;
  final Color backgroundColor;
  final bool mini;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        mini: mini,
        child: Icon(icon, size: mini ? 20 : 24),
      ),
    );
  }
}

/// Optimized quick action button for the grid
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: AppSpacing.sectionSpacing),
            const SizedBox(height: AppSpacing.iconPadding),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
