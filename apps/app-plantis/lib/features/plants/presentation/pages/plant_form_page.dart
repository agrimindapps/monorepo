import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/plants_providers.dart'
    as riverpod_plants;
import '../../../../core/providers/state/plant_form_state_notifier.dart';
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

class _PlantFormPageState extends ConsumerState<PlantFormPage>
    with LoadingPageMixin {
  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final formManager = ref.read(plantFormStateNotifierProvider.notifier);
      if (widget.plantId != null) {
        formManager.loadPlant(widget.plantId!);
      } else {
        formManager.initializeForNewPlant();
      }
    });
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
              final formState = ref.watch(plantFormStateNotifierProvider);
              if (formState.isLoading) return const SizedBox.shrink();

              return SaveButton(
                onSave: () => _savePlant(context),
                text: 'Salvar',
                enabled: formState.canSave && !formState.isSaving,
                onSuccess: () {
                },
                onError: () {
                },
              );
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final formState = ref.watch(plantFormStateNotifierProvider);
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
                  final formManager = ref.read(plantFormStateNotifierProvider.notifier);
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
                  _buildSectionTitle('Informações Básicas'),
                  const PlantFormBasicInfo(),

                  const SizedBox(height: 32),
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
    final formManager = ref.read(plantFormStateNotifierProvider.notifier);
    final formState = ref.read(plantFormStateNotifierProvider);
    final plantName = formState.name.trim();
    startSaveLoading(itemName: plantName.isNotEmpty ? plantName : 'planta');

    try {
      final success = await formManager.savePlant();
      if (!mounted) return;
      stopSaveLoading();

      if (success) {
        _handleSaveSuccess();
      } else {
        _showErrorSnackBar(formState.errorMessage ?? 'Erro ao salvar planta');
      }
    } catch (e) {
      if (mounted) {
        stopSaveLoading();
        _showErrorSnackBar('Erro inesperado ao salvar: $e');
      }
      if (kDebugMode) {
        print('❌ PlantFormPage._savePlant() - Erro: $e');
      }
    }
  }

  void _handleSaveSuccess() {
    if (!mounted) return;

    unawaited(ref.read(riverpod_plants.plantsNotifierProvider.notifier).refreshPlants());
    if (kDebugMode) {
      print('✅ PlantFormPage: Plant list refresh triggered.');
    }

    final message = widget.plantId != null
        ? 'Planta atualizada com sucesso!'
        : 'Planta adicionada com sucesso!';
    _showSuccessSnackBar(message);

    widget.onSaved?.call();
    context.pop();
  }

  void _showSuccessSnackBar(String message) {
    _showSnackBar(message, icon: Icons.check_circle, backgroundColor: Colors.green);
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    _showSnackBar(
      message,
      icon: Icons.error,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  void _showSnackBar(
    String message, {
    required IconData icon,
    required Color backgroundColor,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleBackPressed(BuildContext context) async {
    final formState = ref.read(plantFormStateNotifierProvider);
    if (!_hasUnsavedChanges(formState)) {
      if (mounted) context.pop();
      return;
    }

    final navigator = Navigator.of(context);
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDiscardDialog(formState),
    );

    if (shouldDiscard == true && mounted) {
      navigator.pop();
    }
  }

  Widget _buildDiscardDialog(PlantFormState formState) {
    return AlertDialog(
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
    );
  }

  /// Check if there are unsaved changes in the form
  bool _hasUnsavedChanges(PlantFormState formState) {
    if (formState.name.trim().isNotEmpty) return true;
    if (formState.species.trim().isNotEmpty) return true;
    if (formState.spaceId != null) return true;
    if (formState.notes.trim().isNotEmpty) return true;
    if (formState.plantingDate != null) return true;
    if (formState.imageUrls.isNotEmpty) return true;
    if (formState.enableWateringCare == true ||
        formState.wateringIntervalDays != null) return true;
    if (formState.enableFertilizerCare == true ||
        formState.fertilizingIntervalDays != null) return true;
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
