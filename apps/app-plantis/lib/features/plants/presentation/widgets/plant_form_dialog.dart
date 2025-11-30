import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/state/plant_form_state_notifier.dart';
import '../../../../shared/widgets/loading/loading_components.dart';
import '../providers/plant_details_provider.dart';
import '../providers/plants_notifier.dart';
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
    super.dispose();
  }

  void _initializeFormManager() {
    if (_initialized || !mounted) return;

    _initialized = true;
    final formManager = ref.read(plantFormStateNotifierProvider.notifier);

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
          maxWidth: screenSize.width > 900 ? 1100 : 800,
          maxHeight: screenSize.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
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
            _buildModernHeader(colorScheme, isEditing),
            Expanded(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final isLoading = ref.watch(
                    plantFormStateNotifierProvider.select(
                      (state) => state.isLoading,
                    ),
                  );
                  final hasError = ref.watch(
                    plantFormStateNotifierProvider.select(
                      (state) => state.hasError,
                    ),
                  );
                  final errorMessage = ref.watch(
                    plantFormStateNotifierProvider.select(
                      (state) => state.errorMessage,
                    ),
                  );

                  if (isLoading) {
                    return _buildLoadingState();
                  }

                  if (hasError) {
                    return _buildErrorStateFromFields(errorMessage);
                  }

                  final formState = ref.watch(plantFormStateNotifierProvider);
                  return _buildFormContent(formState);
                },
              ),
            ),
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

  Widget _buildErrorStateFromFields(String? errorMessage) {
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
              errorMessage ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _initializeFormManager(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent(PlantFormState formState) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return Container(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coluna da Esquerda - Informações Básicas
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      'Informações Básicas',
                      Icons.info_outline,
                    ),
                    const SizedBox(height: 24),
                    const PlantFormBasicInfo(),
                  ],
                ),
              ),
            ),

            // Divisor Vertical
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),

            // Coluna da Direita - Configurações de Cuidado
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      'Configurações de Cuidado',
                      Icons.settings_outlined,
                    ),
                    const SizedBox(height: 24),
                    const PlantFormCareConfig(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Informações'),
              Tab(text: 'Cuidados'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: PlantFormBasicInfo(),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: PlantFormCareConfig(),
                ),
              ],
            ),
          ),
        ],
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
          final isSaving = ref.watch(
            plantFormStateNotifierProvider.select((state) => state.isSaving),
          );
          final isFormValid = ref.watch(
            plantFormStateNotifierProvider.select((state) => state.isFormValid),
          );

          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isSaving ? null : () => _handleClose(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed:
                    (isFormValid && !isSaving) ? () => _handleSave() : null,
                child: isSaving
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
    Navigator.of(context).pop(false);
  }

  Future<void> _handleSave() async {
    final formManager = ref.read(plantFormStateNotifierProvider.notifier);

    try {
      final success = await formManager.savePlant();

      if (mounted) {
        if (success) {
          try {
            ref.read(plantsNotifierProvider.notifier).refreshPlants();
          } catch (e) {
            print('Aviso: Não foi possível atualizar a lista automaticamente');
          }
          if (widget.plantId != null && mounted) {
            if (kDebugMode) {
              print(
                '🔧 PlantFormDialog._handleSave() - Tentando atualizar PlantDetailsProvider para plantId: ${widget.plantId}',
              );
            }

            try {
              await ref.read(plantDetailsNotifierProvider.notifier).reloadPlant(widget.plantId!);

              if (kDebugMode) {
                print(
                  '✅ PlantFormDialog._handleSave() - PlantDetailsProvider (Riverpod) recarregado com sucesso',
                );
              }
            } catch (e2) {
              if (kDebugMode) {
                print(
                  '❌ PlantFormDialog._handleSave() - Falha ao atualizar PlantDetailsProvider: $e2',
                );
              }
            }
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

            Navigator.of(context).pop(true);
          }
        } else {
          final formState = ref.read(plantFormStateNotifierProvider);
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
}
