import 'package:core/core.dart' hide Provider, Consumer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../../../core/riverpod_providers/plants_providers.dart'
    as riverpod_plants;
import '../../../../core/riverpod_providers/solid_providers.dart';
import '../../../../core/state/plant_form_state_manager.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/loading/loading_components.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../widgets/plant_form_basic_info.dart';
import '../widgets/plant_form_care_config.dart';

class PlantFormPage extends ConsumerStatefulWidget {
  final String? plantId;
  final VoidCallback? onSaved;

  const PlantFormPage({super.key, this.plantId, this.onSaved});

  @override
  ConsumerState<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends ConsumerState<PlantFormPage> with LoadingPageMixin {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize SOLID state manager only once
    if (!_initialized) {
      _initialized = true;
      final formManager = ref.read(solidPlantFormStateManagerProvider);

      // Initialize form data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (widget.plantId != null) {
            formManager.loadPlant(widget.plantId!);
          } else {
            formManager.initializeForNewPlant();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.plantId != null;

    return Scaffold(
      backgroundColor: PlantisColors.getPageBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Planta' : 'Nova Planta',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: PlantisColors.getPageBackgroundColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        leading: IconButton(
          onPressed: () => _handleBackPressed(context),
          icon: const Icon(Icons.close),
        ),
        actions: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final formState = ref.watch(solidPlantFormStateProvider);
              if (formState.isLoading) return const SizedBox.shrink();

              return SaveButton(
                onSave: () => _savePlant(context),
                text: 'Salvar',
                enabled: formState.canSave && !formState.isSaving,
                onSuccess: () {
                  // Success handled in _savePlant method
                },
                onError: () {
                  // Error handled in _savePlant method
                },
              );
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final formState = ref.watch(solidPlantFormStateProvider);
            if (formState.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonShapes.rectangularImage(height: 200, width: 200),
                    const SizedBox(height: 24),
                    SkeletonShapes.text(height: 20, width: 150),
                    const SizedBox(height: 12),
                    SkeletonShapes.text(height: 16, width: 200),
                    const SizedBox(height: 24),
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SkeletonShapes.listTile(),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (formState.hasError) {
              return ErrorRecovery(
                errorMessage:
                    isEditing
                        ? 'Erro ao carregar dados da planta: ${formState.errorMessage}'
                        : 'Erro ao inicializar formulário: ${formState.errorMessage}',
                onRetry: () {
                  final formManager = ref.read(solidPlantFormStateManagerProvider);
                  formManager.clearError();
                  if (widget.plantId != null) {
                    formManager.loadPlant(widget.plantId!);
                  } else {
                    formManager.initializeForNewPlant();
                  }
                },
                onDismiss: () => context.pop(),
                style: ErrorRecoveryStyle.card,
                showRetryButton: true,
                showDismissButton: true,
                retryText: 'Tentar Novamente',
                dismissText: 'Voltar',
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações Básicas
                  _buildSectionTitle('Informações Básicas'),
                  const PlantFormBasicInfo(),

                  const SizedBox(height: 32),

                  // Configurações de Cuidado
                  _buildSectionTitle('Configurações de Cuidado'),
                  const PlantFormCareConfig(),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _savePlant(BuildContext context) async {
    final formManager = ref.read(solidPlantFormStateManagerProvider);
    final formState = ref.read(solidPlantFormStateProvider);
    final plantName = formState.name.trim();

    // Start contextual loading
    startSaveLoading(itemName: plantName.isNotEmpty ? plantName : 'planta');

    try {
      final success = await formManager.savePlant();

      if (!mounted) return;

      // Stop loading
      stopSaveLoading();

      if (success) {
        if (kDebugMode) {
          print(
            '🔄 PlantFormPage._savePlant() - Atualizando lista de plantas via Riverpod',
          );
        }

        // Atualizar lista de plantas via Riverpod
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(riverpod_plants.plantsProvider.notifier).refreshPlants();
          }
        });

        if (kDebugMode) {
          print(
            '✅ PlantFormPage._savePlant() - Lista atualizada via Riverpod, navegando de volta',
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.plantId != null
                          ? 'Planta atualizada com sucesso!'
                          : 'Planta adicionada com sucesso!',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Call the onSaved callback if provided
          widget.onSaved?.call();

          context.pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      formState.errorMessage ?? 'Erro ao salvar planta',
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        stopSaveLoading();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Erro inesperado ao salvar planta: $e')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (kDebugMode) {
        print('❌ PlantFormPage._savePlant() - Erro: $e');
      }
    }
  }

  Future<void> _handleBackPressed(BuildContext context) async {
    final formState = ref.read(solidPlantFormStateProvider);

    // Use comprehensive change detection instead of just checking name
    final hasChanges = _hasUnsavedChanges(formState);

    if (hasChanges) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Descartar alterações?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Você tem alterações não salvas que serão perdidas:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ..._buildChangesList(formState),
                  const SizedBox(height: 16),
                  const Text(
                    'Deseja realmente sair sem salvar?',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Descartar'),
                ),
              ],
            ),
      );

      if (shouldDiscard == true && mounted) {
        context.pop();
      }
    } else {
      context.pop();
    }
  }

  /// Check if there are unsaved changes in the form
  bool _hasUnsavedChanges(PlantFormState formState) {
    // Basic info changes
    if (formState.name.trim().isNotEmpty) return true;
    if (formState.species.trim().isNotEmpty) return true;
    if (formState.spaceId != null) return true;
    if (formState.notes.trim().isNotEmpty) return true;
    if (formState.plantingDate != null) return true;
    if (formState.imageUrls.isNotEmpty) return true;

    // Care configuration changes
    if (formState.enableWateringCare == true || formState.wateringIntervalDays != null) return true;
    if (formState.enableFertilizerCare == true || formState.fertilizingIntervalDays != null) return true;
    if (formState.enableSunlightCare == true) return true;
    if (formState.enablePestInspection == true) return true;
    if (formState.enablePruning == true) return true;
    if (formState.enableReplanting == true) return true;

    return false;
  }

  /// Builds a list of changes to show user what they would lose
  List<Widget> _buildChangesList(PlantFormState formState) {
    final changes = <String>[];
    final theme = Theme.of(context);

    // Check what data would be lost
    if (formState.name.trim().isNotEmpty) {
      changes.add('Nome da planta');
    }
    if (formState.species.trim().isNotEmpty) {
      changes.add('Espécie');
    }
    if (formState.spaceId != null) {
      changes.add('Espaço selecionado');
    }
    if (formState.notes.trim().isNotEmpty) {
      changes.add('Observações');
    }
    if (formState.plantingDate != null) {
      changes.add('Data de plantio');
    }
    if (formState.imageUrls.isNotEmpty) {
      changes.add('Foto${formState.imageUrls.length > 1 ? 's' : ''} da planta');
    }

    // Care configurations
    if (formState.enableWateringCare == true ||
        formState.wateringIntervalDays != null) {
      changes.add('Configuração de rega');
    }
    if (formState.enableFertilizerCare == true ||
        formState.fertilizingIntervalDays != null) {
      changes.add('Configuração de adubo');
    }
    if (formState.enableSunlightCare == true) {
      changes.add('Configuração de luz solar');
    }
    if (formState.enablePestInspection == true) {
      changes.add('Configuração de verificação de pragas');
    }
    if (formState.enablePruning == true) {
      changes.add('Configuração de poda');
    }
    if (formState.enableReplanting == true) {
      changes.add('Configuração de replantio');
    }

    // Limit to show maximum 4 changes + "and X more" to avoid overwhelming dialog
    final displayChanges = changes.take(4).toList();
    final remainingCount = changes.length - displayChanges.length;

    return [
      ...displayChanges.map(
        (change) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  change,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (remainingCount > 0)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                Icons.more_horiz,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'e mais $remainingCount configuração${remainingCount > 1 ? 'ões' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
    ];
  }
}
