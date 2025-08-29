import 'package:flutter/material.dart';

import '../../domain/entities/calculation_template.dart';
import '../../domain/services/calculator_template_service.dart';

/// Dialog para seleção de templates salvos
/// 
/// Permite visualizar, buscar e carregar templates existentes
/// com preview dos valores que serão carregados
class TemplateSelectionDialog extends StatefulWidget {
  final String calculatorId;
  final CalculatorTemplateService templateService;
  final void Function(CalculationTemplate) onTemplateSelected;

  const TemplateSelectionDialog({
    super.key,
    required this.calculatorId,
    required this.templateService,
    required this.onTemplateSelected,
  });

  @override
  State<TemplateSelectionDialog> createState() => _TemplateSelectionDialogState();
}

class _TemplateSelectionDialogState extends State<TemplateSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<CalculationTemplate> _templates = [];
  List<CalculationTemplate> _filteredTemplates = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _searchController.addListener(_filterTemplates);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final templates = await widget.templateService
          .getTemplatesForCalculator(widget.calculatorId);
      
      if (mounted) {
        setState(() {
          _templates = templates;
          _filteredTemplates = templates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar templates: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _filterTemplates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTemplates = _templates.where((template) {
        return template.name.toLowerCase().contains(query) ||
               (template.description?.toLowerCase() ?? '').contains(query);
      }).toList();
    });
  }

  Future<void> _selectTemplate(CalculationTemplate template) async {
    // Marcar como usado
    await widget.templateService.markTemplateAsUsed(template.id);
    
    if (mounted) {
      widget.onTemplateSelected(template);
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteTemplate(CalculationTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o template "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await widget.templateService.deleteTemplate(template.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template excluído com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        _loadTemplates();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao excluir template'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.bookmark,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selecionar Template',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Search bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar templates',
                hintText: 'Digite o nome do template...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando templates...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTemplates,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_filteredTemplates.isEmpty) {
      final hasTemplates = _templates.isNotEmpty;
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasTemplates ? Icons.search_off : Icons.bookmark_border,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasTemplates 
                  ? 'Nenhum template encontrado'
                  : 'Nenhum template salvo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hasTemplates
                  ? 'Tente alterar os termos da busca'
                  : 'Salve configurações para reutilizar depois',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredTemplates.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final template = _filteredTemplates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(CalculationTemplate template) {
    final hasDescription = template.description?.isNotEmpty == true;
    final wasUsedRecently = template.wasUsedRecently;
    
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _selectTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (wasUsedRecently)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Recente',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteTemplate(template);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Description
              if (hasDescription) ...[
                const SizedBox(height: 8),
                Text(
                  template.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Metadata
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Criado: ${template.formattedCreatedDate}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (template.lastUsed != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.history,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Usado: ${template.formattedLastUsed}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Input values preview
              Text(
                '${template.inputValues.length} parâmetros salvos',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Função helper para mostrar dialog de seleção de template
Future<CalculationTemplate?> showTemplateSelectionDialog({
  required BuildContext context,
  required String calculatorId,
  required CalculatorTemplateService templateService,
}) async {
  CalculationTemplate? selectedTemplate;
  
  await showDialog<void>(
    context: context,
    builder: (context) => TemplateSelectionDialog(
      calculatorId: calculatorId,
      templateService: templateService,
      onTemplateSelected: (template) {
        selectedTemplate = template;
      },
    ),
  );
  
  return selectedTemplate;
}