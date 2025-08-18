import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_form_provider.dart';
import 'plant_form_basic_info.dart';
import 'plant_form_care_config.dart';

class PlantFormModal extends StatefulWidget {
  final String? plantId;

  const PlantFormModal({
    super.key,
    this.plantId,
  });

  @override
  State<PlantFormModal> createState() => _PlantFormModalState();
}

class _PlantFormModalState extends State<PlantFormModal> {
  late PlantFormProvider _provider;
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.plantId != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _handleClose(context),
                  icon: const Icon(Icons.close),
                ),
                Expanded(
                  child: Text(
                    isEditing ? 'Editar Planta' : 'Nova Planta',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Consumer<PlantFormProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) return const SizedBox(width: 48);
                    
                    return TextButton(
                      onPressed: provider.isValid ? () => _savePlant(context) : null,
                      child: provider.isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Salvar',
                              style: TextStyle(
                                color: provider.isValid
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
          ),
          
          // Page Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / 2,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_currentPage + 1} de 2',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Content
          Expanded(
            child: Consumer<PlantFormProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.hasError && !isEditing) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
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

                return PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    // Página 1: Informações Básicas
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Informações Básicas'),
                          const PlantFormBasicInfo(),
                        ],
                      ),
                    ),
                    
                    // Página 2: Configurações de Cuidado
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Configurações de Cuidado'),
                          const PlantFormCareConfig(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Bottom Navigation
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Anterior'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: Consumer<PlantFormProvider>(
                    builder: (context, provider, child) {
                      if (_currentPage < 1) {
                        return ElevatedButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Próximo'),
                        );
                      } else {
                        return ElevatedButton(
                          onPressed: provider.isValid && !provider.isSaving 
                              ? () => _savePlant(context)
                              : null,
                          child: provider.isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isEditing ? 'Atualizar' : 'Salvar'),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _provider.errorMessage ?? 'Erro ao salvar planta',
            ),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleClose(BuildContext context) async {
    final hasChanges = _provider.isValid && _provider.name.isNotEmpty;
    
    if (hasChanges) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Descartar'),
            ),
          ],
        ),
      );
      
      if (shouldDiscard == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }
}