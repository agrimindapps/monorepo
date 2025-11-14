import 'package:flutter/material.dart';

import '../../domain/entities/calculation_template.dart';
import '../../domain/services/calculator_template_service.dart';

/// Dialog para salvar configurações atuais como template
/// 
/// Permite criar templates com nome, descrição e tags
/// para reutilização posterior
class TemplateSaveDialog extends StatefulWidget {
  final String calculatorId;
  final String calculatorName;
  final Map<String, dynamic> currentInputs;
  final CalculatorTemplateService templateService;
  final VoidCallback? onTemplateSaved;

  const TemplateSaveDialog({
    super.key,
    required this.calculatorId,
    required this.calculatorName,
    required this.currentInputs,
    required this.templateService,
    this.onTemplateSaved,
  });

  @override
  State<TemplateSaveDialog> createState() => _TemplateSaveDialogState();
}

class _TemplateSaveDialogState extends State<TemplateSaveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();
  
  final List<String> _tags = [];
  bool _isLoading = false;
  bool _isPublic = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (widget.currentInputs.isEmpty) {
      _showSnackBar(
        'Não há parâmetros preenchidos para salvar',
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final template = CalculationTemplate(
        id: '', // Será gerado pelo service
        name: _nameController.text.trim(),
        calculatorId: widget.calculatorId,
        calculatorName: widget.calculatorName,
        inputValues: Map<String, dynamic>.from(widget.currentInputs),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        tags: _tags,
        createdAt: DateTime.now(),
        userId: 'current_user',
        isPublic: _isPublic,
      );

      final success = await widget.templateService.saveTemplate(template);

      if (mounted) {
        if (success) {
          _showSnackBar('Template salvo com sucesso!', Colors.green);
          widget.onTemplateSaved?.call();
          Navigator.of(context).pop();
        } else {
          _showSnackBar('Erro ao salvar template', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao salvar template: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.bookmark_add,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Salvar como Template'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do template *',
                    hintText: 'Ex: Irrigação verão 2024',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    hintText: 'Descreva quando usar este template',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: 'Tag',
                          hintText: 'Ex: verão, produção, teste',
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (_) => _addTag(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addTag,
                      icon: const Icon(Icons.add),
                      tooltip: 'Adicionar tag',
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                if (_tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                        deleteIcon: const Icon(Icons.close, size: 16),
                      );
                    }).toList(),
                  ),
                
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Template público'),
                  subtitle: const Text(
                    'Outros usuários podem ver e usar este template',
                  ),
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Dados que serão salvos:',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• ${widget.currentInputs.length} parâmetros preenchidos',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '• Calculadora: ${widget.calculatorName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveTemplate,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

/// Função helper para mostrar dialog de salvamento de template
Future<bool> showTemplateSaveDialog({
  required BuildContext context,
  required String calculatorId,
  required String calculatorName,
  required Map<String, dynamic> currentInputs,
  required CalculatorTemplateService templateService,
  VoidCallback? onTemplateSaved,
}) async {
  if (currentInputs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preencha os parâmetros antes de salvar um template'),
        backgroundColor: Colors.orange,
      ),
    );
    return false;
  }

  bool templateSaved = false;

  await showDialog<void>(
    context: context,
    builder: (context) => TemplateSaveDialog(
      calculatorId: calculatorId,
      calculatorName: calculatorName,
      currentInputs: currentInputs,
      templateService: templateService,
      onTemplateSaved: () {
        templateSaved = true;
        onTemplateSaved?.call();
      },
    ),
  );

  return templateSaved;
}
