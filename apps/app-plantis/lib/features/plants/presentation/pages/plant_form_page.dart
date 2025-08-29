import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/plant_form_provider.dart';
import '../providers/plants_provider.dart';
import '../widgets/plant_form_basic_info.dart';
import '../widgets/plant_form_care_config.dart';

class PlantFormPage extends StatefulWidget {
  final String? plantId;

  const PlantFormPage({super.key, this.plantId});

  @override
  State<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends State<PlantFormPage> {
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
      backgroundColor: theme.brightness == Brightness.light
          ? const Color(0xFFF5F5F5)
          : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Planta' : 'Nova Planta',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.brightness == Brightness.light
            ? const Color(0xFFF5F5F5)
            : theme.appBarTheme.backgroundColor,
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

              return TextButton(
                onPressed: provider.isValid ? () => _savePlant(context) : null,
                child:
                    provider.isSaving
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(
                          'Salvar',
                          style: TextStyle(
                            color:
                                provider.isValid
                                    ? theme.colorScheme.primary
                                    : theme.disabledColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PlantFormProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isEditing ? Icons.edit_off : Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEditing 
                        ? 'Erro ao carregar dados da planta'
                        : 'Erro ao inicializar formulário',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage ?? 'Erro desconhecido',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.light
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.brightness == Brightness.light
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          provider.clearError();
                          if (widget.plantId != null) {
                            provider.initializeForEdit(widget.plantId!);
                          } else {
                            provider.initializeForAdd();
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
    
    final success = await provider.savePlant();

    if (mounted) {
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
            content: Text(
              widget.plantId != null
                  ? 'Planta atualizada com sucesso!'
                  : 'Planta adicionada com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Erro ao salvar planta'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
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
