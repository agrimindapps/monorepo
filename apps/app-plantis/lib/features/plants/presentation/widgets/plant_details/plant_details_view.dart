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
import '../../providers/plants_provider.dart';
import '../plant_form_dialog.dart';
import 'plant_care_section.dart';
import 'plant_details_controller.dart';
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

      try {
        final provider = ref.read(plantDetailsProviderProvider);
        final taskProvider = ref.read(plantTaskProviderProvider);
        if (mounted) {
          _controller = PlantDetailsController(
            provider: provider,
            onBack: () {
              if (mounted) {
                Navigator.of(context).pop();
                _notifyListScreenUpdate();
              }
            },
            onNavigateToEdit: (plantId) async {
              if (mounted) {
                final result = await PlantFormDialog.show(
                  context,
                  plantId: plantId,
                );
                if (result == true && mounted) {
                  final provider = ref.read(plantDetailsProviderProvider);
                  await provider.reloadPlant(plantId);

                  if (kDebugMode) {
                    print(
                      '✅ PlantDetailsView - Planta recarregada após edição: ${provider.plant?.name}',
                    );
                  }
                }
              }
            },
            onNavigateToImages: (plantId) {},
            onNavigateToSchedule: (plantId) {},
            onShowSnackBar: (message, type) {
              if (mounted) _showSnackBar(message, type);
            },
            onShowSnackBarWithColor: (message, type, {Color? backgroundColor}) {
              if (mounted) {
                _showSnackBarWithColor(
                  message,
                  backgroundColor: backgroundColor,
                );
              }
            },
            onShowDialog: (dialog) {
              if (mounted) {
                showDialog<void>(context: context, builder: (_) => dialog);
              }
            },
            onShowBottomSheet: (bottomSheet) {
              if (mounted) {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) => bottomSheet,
                );
              }
            },
            onPlantDeleted: (plantId) {
              if (mounted) _syncPlantDeletion(plantId);
            },
          );
          if (_controller != null && mounted) {
            _controller!.loadPlant(widget.plantId);
          }
          if (mounted) {
            _initializeTasksIfNeeded(taskProvider);
          }
        }
      } catch (e) {
        if (mounted) {
          debugPrint('Error initializing PlantDetailsView: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_controller != null) {
      _controller = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plantDetailsProvider = ref.watch(plantDetailsProviderProvider);

    return BasePageScaffold(
      body: ResponsiveLayout(
        child: Builder(
          builder: (context) {
            if (plantDetailsProvider.isLoading &&
                plantDetailsProvider.plant == null) {
              return _buildLoadingState(context);
            }

            if (plantDetailsProvider.hasError &&
                plantDetailsProvider.plant == null) {
              return _buildErrorState(
                context,
                plantDetailsProvider.errorMessage,
              );
            }

            final plant = plantDetailsProvider.plant;
            if (plant == null) {
              return _buildLoadingState(context);
            }
            if (!_isPlantDataValid(plant)) {
              return _buildInvalidDataState(context, plant);
            }
            return _buildMainContent(context, plant);
          },
        ),
      ),
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
      backgroundColor:
          theme.brightness == Brightness.dark
              ? const Color(0xFF1C1C1E)
              : theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
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
                child: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildLoadingImageSection(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _LoadingShimmer(
                    height: AppSpacing.sectionSpacing,
                    width: 200,
                  ),
                  const SizedBox(height: AppSpacing.iconPadding),
                  const _LoadingShimmer(height: AppSpacing.lg, width: 150),
                  const SizedBox(height: AppSpacing.sectionSpacing),
                  _buildLoadingTabs(context),
                  const SizedBox(height: AppSpacing.lg),
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
                borderRadius: BorderRadius.circular(
                  AppSpacing.borderRadiusCircular,
                ),
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
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFFFFFFF), // Branco puro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < 4; i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color:
                      theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.borderRadiusSmall,
                  ),
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
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFFFFFFF), // Branco puro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoadingShimmer(height: AppSpacing.xl, width: 150),
          SizedBox(height: AppSpacing.iconPadding),
          _LoadingShimmer(height: AppSpacing.lg, width: double.infinity),
          SizedBox(height: AppSpacing.xs),
          _LoadingShimmer(height: AppSpacing.lg, width: 250),
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
      backgroundColor:
          theme.brightness == Brightness.dark
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
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.3,
                  ),
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
              if (errorMessage != null && errorMessage.isNotEmpty)
                _buildErrorDetails(context, errorMessage),

              const SizedBox(height: 32),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _controller?.refresh(widget.plantId),
                      icon: const Icon(Icons.refresh),
                      label: const Text(AppStrings.tryAgain),
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text(AppStrings.goBack),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.buttonSpacing,
                            ),
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
                          label: const Text(AppStrings.help),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.buttonSpacing,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sectionSpacing),
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
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.iconPadding,
          ),
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
        color:
            theme.brightness == Brightness.dark
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
            margin: const EdgeInsets.only(
              top: AppSpacing.iconPadding,
              right: AppSpacing.buttonSpacing,
            ),
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
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(AppStrings.needHelp),
            content: const Text(AppStrings.helpMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.understood),
              ),
            ],
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        final provider = ref.read(plantDetailsProviderProvider);
        if (provider.plant != null && mounted) {
          final tasks = taskProvider.getTasksForPlant(widget.plantId);
          if (tasks.isEmpty && mounted) {
            taskProvider.generateTasksForPlant(provider.plant!);
          }
        }
      } catch (e) {
        if (mounted) {
          debugPrint('Error initializing tasks: $e');
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
    try {
      final plantsProvider = ref.read(plantsProviderProvider);
      plantsProvider.refreshPlants();

      if (kDebugMode) {
        print(
          '✅ _syncPlantDeletion: Refresh solicitado para plantId: $plantId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          '⚠️ _syncPlantDeletion: Provider não encontrado, tentando ref.read: $e',
        );
      }
      try {
        Future.delayed(Duration.zero, () {
          if (mounted) {
            final plantsProvider = ref.read(plantsProviderProvider);
            plantsProvider.refreshPlants();
          }
        });
      } catch (fallbackError) {
        if (kDebugMode) {
          print(
            '❌ _syncPlantDeletion: Falha total na sincronização: $fallbackError',
          );
        }
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            try {
              final plantsProvider = ref.read(plantsProviderProvider);
              plantsProvider.refreshPlants();

              if (kDebugMode) {
                print('✅ _syncPlantDeletion: Refresh com delay bem sucedido');
              }
            } catch (delayedError) {
              if (kDebugMode) {
                print(
                  '❌ _syncPlantDeletion: Falha mesmo com delay: $delayedError',
                );
              }
            }
          }
        });
      }
    }
  }

  /// Notifica a tela de lista para atualizar após mudanças
  void _notifyListScreenUpdate() {
    try {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          try {
            final plantsProvider = ref.read(plantsProviderProvider);
            plantsProvider.refreshPlants();

            if (kDebugMode) {
              print(
                '✅ _notifyListScreenUpdate: Atualização da lista solicitada',
              );
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ _notifyListScreenUpdate: Erro ao atualizar lista: $e');
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ _notifyListScreenUpdate: Erro geral: $e');
      }
    }
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
      backgroundColor: const Color(0xFFFFFFFF), // Branco puro
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
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_outlined, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta ação não pode ser desfeita.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
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
                await _controller?.deletePlant(plant.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
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
                const SizedBox(height: AppSpacing.lg),
                _buildTabBar(context),
                const SizedBox(height: AppSpacing.lg),
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
                        _buildOverviewTab(context, plant),
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
          color: const Color(0xFFFFFFFF), // Fundo branco puro
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
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Excluir', style: TextStyle(color: Colors.red)),
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
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFFFFFFF), // Branco puro
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

  Widget _buildOverviewTab(BuildContext context, Plant plant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Column(
        children: [
          _buildPlantImageSection(context, plant),
          const SizedBox(height: AppSpacing.lg),
          PlantInfoSection(plant: plant),
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
      backgroundColor:
          theme.brightness == Brightness.dark
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
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
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
              Column(
                children: [
                  if (plant.id.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: Semantics(
                        label: AppStrings.editPlantData,
                        button: true,
                        child: ElevatedButton.icon(
                          onPressed: () => _controller?.editPlant(plant),
                          icon: const Icon(Icons.edit),
                          label: const Text(AppStrings.editPlant),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PlantisColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (plant.id.isNotEmpty) const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(AppStrings.goBack),
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

/// Optimized loading shimmer widget that doesn't rebuild unnecessarily
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer({required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
      ),
    );
  }
}
