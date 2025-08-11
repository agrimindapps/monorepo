import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/plant_form_provider.dart';
import '../widgets/plant_form_basic_info.dart';
import '../widgets/plant_form_care_config.dart';
import '../widgets/plant_form_environment_config.dart';
import '../../../../core/theme/colors.dart';

class PlantFormPage extends StatefulWidget {
  final String? plantId;

  const PlantFormPage({
    super.key,
    this.plantId,
  });

  @override
  State<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends State<PlantFormPage> {
  late PlantFormProvider _provider;
  late PageController _pageController;
  int _currentPage = 0;
  
  final List<String> _pageTitles = [
    'Informações Básicas',
    'Configurações de Cuidado',
    'Ambiente',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
                              ? PlantisColors.primary
                              : Colors.grey,
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

          return Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),
              
              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: const [
                    PlantFormBasicInfo(),
                    PlantFormCareConfig(),
                    PlantFormEnvironmentConfig(),
                  ],
                ),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _pageTitles[_currentPage],
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(_pageTitles.length, (index) {
              final isActive = index <= _currentPage;
              final isCurrent = index == _currentPage;
              
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index < _pageTitles.length - 1 ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? (isCurrent ? PlantisColors.primary : PlantisColors.primaryLight)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous button
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
              )
            else
              const Expanded(child: SizedBox.shrink()),
              
            const SizedBox(width: 16),
            
            // Next/Save button
            Expanded(
              child: Consumer<PlantFormProvider>(
                builder: (context, provider, child) {
                  final isLastPage = _currentPage == _pageTitles.length - 1;
                  
                  return ElevatedButton(
                    onPressed: provider.isSaving ? null : () {
                      if (isLastPage) {
                        _savePlant(context);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: provider.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isLastPage ? 'Salvar' : 'Próximo'),
                  );
                },
              ),
            ),
          ],
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _provider.errorMessage ?? 'Erro ao salvar planta',
            ),
            backgroundColor: Colors.red,
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
        context.pop();
      }
    } else {
      context.pop();
    }
  }
}