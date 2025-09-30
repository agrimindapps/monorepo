import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/riverpod_providers/solid_providers.dart';
import '../../../../core/state/plant_form_state_manager.dart';
import '../../../../shared/widgets/loading/loading_components.dart';
import '../providers/plant_details_provider.dart';
import '../providers/plants_provider.dart';
import 'plant_form_basic_info.dart';
import 'plant_form_care_config.dart';

/// Dialog moderna para cadastro de plantas
/// Reutiliza os widgets existentes do PlantFormPage
class PlantFormDialog extends ConsumerStatefulWidget {
  final String? plantId;

  const PlantFormDialog({super.key, this.plantId});

  @override
  ConsumerState<PlantFormDialog> createState() => _PlantFormDialogState();

  /// Factory method para mostrar a dialog
  static Future<bool?> show(BuildContext context, {String? plantId}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PlantFormDialog(plantId: plantId),
    );
  }
}

class _PlantFormDialogState extends ConsumerState<PlantFormDialog>
    with LoadingPageMixin {
  bool _initialized = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormManager();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Provider disposal will be handled automatically by ChangeNotifierProvider
    super.dispose();
  }

  void _initializeFormManager() {
    if (_initialized || !mounted) return;

    _initialized = true;
    final formManager = ref.read(solidPlantFormStateManagerProvider);

    if (widget.plantId != null) {
      if (kDebugMode) {
        print(
          '🔧 PlantFormDialog._initializeFormManager() - Iniciando edição para plantId: ${widget.plantId}',
        );
      }
      formManager.loadPlant(widget.plantId!);
    } else {
      if (kDebugMode) {
        print(
          '🔧 PlantFormDialog._initializeFormManager() - Iniciando adição de nova planta',
        );
      }
      formManager.initializeForNewPlant();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.plantId != null;
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenSize.width > 600 ? 40 : 16,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: screenSize.height * 0.9,
        ),
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2D2D2D)
                  : const Color(0xFFFFFFFF), // Branco puro para modo claro
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Header moderno
            _buildModernHeader(colorScheme, isEditing),

            // Content
            Expanded(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final formState = ref.watch(solidPlantFormStateProvider);
                  
                  if (formState.isLoading) {
                    return _buildLoadingState();
                  }

                  if (formState.hasError) {
                    return _buildErrorState(formState, isEditing);
                  }

                  return _buildFormContent(formState);
                },
              ),
            ),

            // Footer com actions
            _buildFooter(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(ColorScheme colorScheme, bool isEditing) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
      child: Row(
        children: [
          // Ícone da planta com background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.local_florist,
              color: colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Título e subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Editar Planta' : 'Nova Planta',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditing
                      ? 'Atualize as informações da sua planta'
                      : 'Adicione uma nova planta ao seu jardim',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Botão fechar
          IconButton(
            onPressed: () => _handleClose(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonShapes.rectangularImage(height: 150, width: 200),
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
      ),
    );
  }

  Widget _buildErrorState(PlantFormState formState, bool isEditing) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: colorScheme.error),
            ),
            const SizedBox(height: 8),
            Text(
              isEditing
                  ? 'Erro ao carregar dados da planta'
                  : 'Erro ao inicializar formulário',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (formState.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  formState.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: () {
                    final formManager = ref.read(solidPlantFormStateManagerProvider);
                    formManager.clearError();
                    _initializeFormManager();
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent(PlantFormState formState) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações Básicas
            _buildSectionTitle('Informações Básicas', Icons.info_outline),
            const SizedBox(height: 16),
            const PlantFormBasicInfo(),

            const SizedBox(height: 24),

            // Configurações de Cuidado
            _buildSectionTitle(
              'Configurações de Cuidado',
              Icons.settings_outlined,
            ),
            const SizedBox(height: 16),
            const PlantFormCareConfig(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final formState = ref.watch(solidPlantFormStateProvider);
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botão Cancelar
              TextButton(
                onPressed: formState.isSaving ? null : () => _handleClose(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 16),

              // Botão Salvar
              FilledButton(
                onPressed:
                    (formState.isFormValid && !formState.isSaving)
                        ? () => _handleSave()
                        : null,
                child:
                    formState.isSaving
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(widget.plantId != null ? 'Atualizar' : 'Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleClose() async {
    final formState = ref.read(solidPlantFormStateProvider);

    if (formState.hasChanges) {
      final shouldDiscard = await _showDiscardDialog();
      if (shouldDiscard == true && mounted) {
        Navigator.of(context).pop(false);
      }
    } else {
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _handleSave() async {
    final formManager = ref.read(solidPlantFormStateManagerProvider);

    try {
      final success = await formManager.savePlant();

      if (mounted) {
        if (success) {
          // Procurar o PlantsProvider no contexto ou usar DI
          PlantsProvider? plantsProvider;
          try {
            plantsProvider = di.sl<PlantsProvider>();
          } catch (e) {
            // Se não conseguir obter o provider, apenas exibir sucesso
            print(
              'Aviso: Não foi possível atualizar a lista automaticamente',
            );
          }

          // Atualizar a lista de plantas se o provider estiver disponível
          if (plantsProvider != null) {
            await plantsProvider.refreshPlants();
          }

          // Se for edição, também atualizar o PlantDetailsProvider
          if (widget.plantId != null && mounted) {
            if (kDebugMode) {
              print(
                '🔧 PlantFormDialog._handleSave() - Tentando atualizar PlantDetailsProvider para plantId: ${widget.plantId}',
              );
            }

            try {
              final plantDetailsProvider = di.sl<PlantDetailsProvider>();

              if (kDebugMode) {
                print(
                  '✅ PlantFormDialog._handleSave() - PlantDetailsProvider encontrado via DI',
                );
                print(
                  '   - Planta atual no provider: ${plantDetailsProvider.plant?.name} (${plantDetailsProvider.plant?.id})',
                );
              }

              await plantDetailsProvider.reloadPlant(widget.plantId!);

              if (kDebugMode) {
                print(
                  '✅ PlantFormDialog._handleSave() - PlantDetailsProvider (DI) recarregado com sucesso',
                );
                print(
                  '   - Nova planta no provider: ${plantDetailsProvider.plant?.name} (${plantDetailsProvider.plant?.id})',
                );
              }
            } catch (e2) {
              if (kDebugMode) {
                print('❌ PlantFormDialog._handleSave() - Falha ao atualizar PlantDetailsProvider: $e2');
              }
            }
          }

          // Mostrar snackbar de sucesso
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

            Navigator.of(context).pop(true);
          }
        } else {
          final formState = ref.read(solidPlantFormStateProvider);
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Erro inesperado: $e')),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (kDebugMode) {
        print('❌ PlantFormDialog._handleSave() - Erro: $e');
      }
    }
  }

  Future<bool?> _showDiscardDialog() {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 32,
            ),
            title: const Text('Descartar alterações?'),
            content: const Text(
              'Você tem alterações não salvas que serão perdidas. Deseja realmente sair sem salvar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Continuar Editando'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Descartar'),
              ),
            ],
          ),
    );
  }
}
