import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:core/core.dart' hide Provider;
import 'package:provider/provider.dart';

import '../../../../core/theme/plantis_colors.dart';

import '../../../../shared/widgets/loading/loading_components.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../providers/plant_form_provider.dart';
import '../providers/plants_provider.dart';
import '../widgets/plant_form_basic_info.dart';
import '../widgets/plant_form_care_config.dart';

class PlantFormPage extends StatefulWidget {
  final String? plantId;
  final VoidCallback? onSaved;

  const PlantFormPage({super.key, this.plantId, this.onSaved});

  @override
  State<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends State<PlantFormPage> with LoadingPageMixin {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize provider only once
    if (!_initialized) {
      _initialized = true;
      final provider = Provider.of<PlantFormProvider>(context, listen: false);
      
      // Initialize provider data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (widget.plantId != null) {
            provider.initializeForEdit(widget.plantId!);
          } else {
            provider.initializeForAdd();
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
          Consumer<PlantFormProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) return const SizedBox.shrink();

              return SaveButton(
                onSave: () => _savePlant(context),
                text: 'Salvar',
                enabled: provider.isValid && !provider.isSaving,
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
        child: Consumer<PlantFormProvider>(
          builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonShapes.rectangularImage(
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 24),
                  SkeletonShapes.text(height: 20, width: 150),
                  const SizedBox(height: 12),
                  SkeletonShapes.text(height: 16, width: 200),
                  const SizedBox(height: 24),
                  ...List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SkeletonShapes.listTile(),
                  )),
                ],
              ),
            );
          }

          if (provider.hasError) {
            return ErrorRecovery(
              errorMessage: isEditing 
                  ? 'Erro ao carregar dados da planta: ${provider.errorMessage}'
                  : 'Erro ao inicializar formulário: ${provider.errorMessage}',
              onRetry: () {
                provider.clearError();
                if (widget.plantId != null) {
                  provider.initializeForEdit(widget.plantId!);
                } else {
                  provider.initializeForAdd();
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
    final provider = Provider.of<PlantFormProvider>(context, listen: false);
    final plantName = provider.name.trim();
    
    // Start contextual loading
    startSaveLoading(itemName: plantName.isNotEmpty ? plantName : 'planta');
    
    try {
      final success = await provider.savePlant();

      if (mounted) {
        // Stop loading
        stopSaveLoading();
        
        if (success) {
          if (kDebugMode) {
            print('🔄 PlantFormPage._savePlant() - Atualizando lista de plantas');
          }
          
          // Atualizar a lista de plantas antes de navegar
          final plantsProvider = Provider.of<PlantsProvider>(context, listen: false);
          await plantsProvider.refreshPlants();
          
          if (kDebugMode) {
            print('✅ PlantFormPage._savePlant() - Lista atualizada, navegando de volta');
          }
          
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(provider.errorMessage ?? 'Erro ao salvar planta'),
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
                Expanded(
                  child: Text('Erro inesperado ao salvar planta: $e'),
                ),
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
    final provider = Provider.of<PlantFormProvider>(context, listen: false);
    
    // Use comprehensive change detection instead of just checking name
    final hasChanges = provider.hasUnsavedChanges;

    if (hasChanges) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
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
              ..._buildChangesList(provider),
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

  /// Builds a list of changes to show user what they would lose
  List<Widget> _buildChangesList(PlantFormProvider provider) {
    final changes = <String>[];
    final theme = Theme.of(context);
    
    // Check what data would be lost
    if (provider.name.trim().isNotEmpty) {
      changes.add('Nome da planta');
    }
    if (provider.species.trim().isNotEmpty) {
      changes.add('Espécie');
    }
    if (provider.spaceId != null) {
      changes.add('Espaço selecionado');
    }
    if (provider.notes.trim().isNotEmpty) {
      changes.add('Observações');
    }
    if (provider.plantingDate != null) {
      changes.add('Data de plantio');
    }
    if (provider.imageUrls.isNotEmpty) {
      changes.add('Foto${provider.imageUrls.length > 1 ? 's' : ''} da planta');
    }
    
    // Care configurations
    if (provider.enableWateringCare == true || provider.wateringIntervalDays != null) {
      changes.add('Configuração de rega');
    }
    if (provider.enableFertilizerCare == true || provider.fertilizingIntervalDays != null) {
      changes.add('Configuração de adubo');
    }
    if (provider.enableSunlightCare == true) {
      changes.add('Configuração de luz solar');
    }
    if (provider.enablePestInspection == true) {
      changes.add('Configuração de verificação de pragas');
    }
    if (provider.enablePruning == true) {
      changes.add('Configuração de poda');
    }
    if (provider.enableReplanting == true) {
      changes.add('Configuração de replantio');
    }
    
    // Limit to show maximum 4 changes + "and X more" to avoid overwhelming dialog
    final displayChanges = changes.take(4).toList();
    final remainingCount = changes.length - displayChanges.length;
    
    return [
      ...displayChanges.map((change) => Padding(
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
      )),
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
