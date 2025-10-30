import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/plants_providers.dart' as riverpod_plants;
import '../../../../core/providers/state/plant_form_state_notifier.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/loading/loading_components.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../builders/plant_form_dialog_builder.dart';
import '../managers/plants_managers_providers.dart';
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
                onSuccess: () {},
                onError: () {},
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
                errorMessage: isEditing
                    ? 'Erro ao carregar dados da planta: ${formState.errorMessage}'
                    : 'Erro ao inicializar formulário: ${formState.errorMessage}',
                onRetry: () {
                  final formManager = ref.read(
                    plantFormStateNotifierProvider.notifier,
                  );
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

    unawaited(
      ref.read(riverpod_plants.plantsNotifierProvider.notifier).refreshPlants(),
    );
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
    _showSnackBar(
      message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green,
    );
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
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final formStateManager = ref.watch(plantFormStateManagerProvider);
        final changes = formStateManager.getChangedFields(
          name: formState.name,
          species: formState.species,
          spaceId: formState.spaceId,
          notes: formState.notes,
          plantingDate: formState.plantingDate,
          imageUrls: formState.imageUrls,
          enableWateringCare: formState.enableWateringCare,
          wateringIntervalDays: formState.wateringIntervalDays,
          enableFertilizerCare: formState.enableFertilizerCare,
          fertilizingIntervalDays: formState.fertilizingIntervalDays,
          enableSunlightCare: formState.enableSunlightCare,
          enablePestInspection: formState.enablePestInspection,
          enablePruning: formState.enablePruning,
          enableReplanting: formState.enableReplanting,
        );

        return PlantFormDialogBuilder.buildDiscardDialog(
          changes: changes,
          onDiscard: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        );
      },
    );
  }

  /// Check if there are unsaved changes in the form
  bool _hasUnsavedChanges(PlantFormState formState) {
    return ref
        .read(plantFormStateManagerProvider)
        .hasUnsavedChanges(
          name: formState.name,
          species: formState.species,
          spaceId: formState.spaceId,
          notes: formState.notes,
          plantingDate: formState.plantingDate,
          imageUrls: formState.imageUrls,
          enableWateringCare: formState.enableWateringCare,
          wateringIntervalDays: formState.wateringIntervalDays,
          enableFertilizerCare: formState.enableFertilizerCare,
          fertilizingIntervalDays: formState.fertilizingIntervalDays,
          enableSunlightCare: formState.enableSunlightCare,
          enablePestInspection: formState.enablePestInspection,
          enablePruning: formState.enablePruning,
          enableReplanting: formState.enableReplanting,
        );
  }
}
