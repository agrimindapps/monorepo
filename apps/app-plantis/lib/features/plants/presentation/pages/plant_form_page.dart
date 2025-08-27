import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/plant_form_provider.dart';
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
      backgroundColor: const Color(0xFFF5F5F5), // Cor de fundo mais clara conforme mockup
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Planta' : 'Nova Planta'),
        backgroundColor: const Color(0xFFF5F5F5), // Mesmo fundo que o Scaffold
        elevation: 0,
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
                      color: Colors.grey[600],
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
                          foregroundColor: Colors.grey[600],
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

          return Column(
            children: [
              // Form content
              Expanded(
                child: SingleChildScrollView(
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
                ),
              ),
              // Área de botões com fundo branco
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleBackPressed(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.isValid && !provider.isSaving
                            ? () => _savePlant(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: provider.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    
    final hasChanges = provider.isValid && provider.name.isNotEmpty;

    if (hasChanges) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Descartar alterações?'),
              content: const Text(
                'Você tem alterações não salvas. '
                'Deseja realmente sair sem salvar?',
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
}
