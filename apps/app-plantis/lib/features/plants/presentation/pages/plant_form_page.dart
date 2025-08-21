import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
  late PlantFormProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<PlantFormProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.plantId != null) {
        _provider.initializeForEdit(widget.plantId!);
      } else {
        _provider.initializeForAdd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.plantId != null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Planta' : 'Nova Planta'),
        backgroundColor: theme.colorScheme.surface,
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

          if (provider.hasError && !isEditing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Erro desconhecido',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.clearError();
                      if (widget.plantId != null) {
                        provider.initializeForEdit(widget.plantId!);
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
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

                      const SizedBox(
                        height: 100,
                      ), // Espaço para o botão flutuante
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<PlantFormProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed:
                provider.isValid && !provider.isSaving
                    ? () => _savePlant(context)
                    : null,
            backgroundColor:
                provider.isValid
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
            foregroundColor: Colors.white,
            icon:
                provider.isSaving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.check),
            label: Text(provider.isSaving ? 'Salvando...' : 'Salvar'),
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
    final success = await _provider.savePlant();

    if (success) {
      if (mounted) {
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
      }
    } else {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_provider.errorMessage ?? 'Erro ao salvar planta'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleBackPressed(BuildContext context) async {
    final hasChanges = _provider.isValid && _provider.name.isNotEmpty;

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
