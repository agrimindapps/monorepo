import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart' as plantis_di;
import '../../../../core/theme/plantis_colors.dart';

/// Dialog para envio de feedback do usuário para Firebase Analytics
///
/// Portado do app-receituagro e adaptado para Plantis
class FeedbackDialog extends ConsumerStatefulWidget {
  const FeedbackDialog({super.key});

  @override
  ConsumerState<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends ConsumerState<FeedbackDialog> {
  late final TextEditingController _contentController;
  late final FocusNode _contentFocusNode;

  String _selectedType = 'suggestion';
  double _rating = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
    _contentFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: PlantisColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Enviar Feedback'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: PlantisColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Enviando feedback...',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tipo de feedback
                    Text('Tipo de Feedback', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 12),
                    _buildFeedbackTypeSelector(theme),
                    const SizedBox(height: 24),

                    // Rating (apenas para sugestões e elogios)
                    if (_selectedType != 'bug')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Como você avalia sua experiência?',
                                style: theme.textTheme.titleSmall,
                              ),
                              if (_rating > 0)
                                Text(
                                  '${_rating.toStringAsFixed(1)}/5',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: PlantisColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: List.generate(5, (index) {
                              final starValue = index + 1.0;
                              final isFilled = starValue <= _rating;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rating = _rating == starValue
                                        ? 0.0
                                        : starValue;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Icon(
                                    isFilled ? Icons.star : Icons.star_outline,
                                    color: isFilled
                                        ? Colors.amber
                                        : theme.colorScheme.outlineVariant,
                                    size: 32,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // Conteúdo do feedback
                    Text(
                      'Conte-nos mais detalhes',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      maxLines: 6,
                      minLines: 5,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: _buildPlaceholder(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: PlantisColors.primary,
                            width: 2,
                          ),
                        ),
                        counterText: '${_contentController.text.length}/500',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),

                    // Botões de ação
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _contentController.text.isEmpty
                              ? null
                              : () => _submitFeedback(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: PlantisColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.send),
                          label: const Text('Enviar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFeedbackTypeSelector(ThemeData theme) {
    final feedbackTypes = {
      'suggestion': ('💡', 'Sugestão'),
      'bug': ('🐛', 'Reportar Bug'),
      'praise': ('👍', 'Elogio'),
      'complaint': ('📝', 'Reclamação'),
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: feedbackTypes.entries.map((entry) {
        final isSelected = _selectedType == entry.key;
        return FilterChip(
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedType = entry.key;
              _rating = 0.0; // Reset rating quando muda tipo
            });
          },
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry.value.$1),
              const SizedBox(width: 8),
              Text(entry.value.$2),
            ],
          ),
          showCheckmark: false,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          selectedColor: PlantisColors.primary.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected
                ? PlantisColors.primary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  String _buildPlaceholder() {
    switch (_selectedType) {
      case 'suggestion':
        return 'Ex: Seria legal ter uma funcionalidade de...';
      case 'bug':
        return 'Descreva o problema em detalhes:\n- O que você tentou fazer\n- O que aconteceu\n- O que deveria acontecer';
      case 'praise':
        return 'Que bom que você gostou! O que foi?';
      case 'complaint':
        return 'Nos desculpe pelo incômodo. Qual foi o problema?';
      default:
        return 'Digite seu feedback aqui...';
    }
  }

  Future<void> _submitFeedback(BuildContext context) async {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      _showError('Por favor, escreva seu feedback');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Obter analytics repository do core
      final analyticsRepository = plantis_di.getIt<IAnalyticsRepository>();

      // Enviar feedback para Firebase Analytics
      final result = await analyticsRepository.logFeedback(
        type: _selectedType,
        content: content,
        rating: _rating > 0 ? _rating : null,
      );

      result.fold(
        (Failure failure) {
          setState(() => _isLoading = false);
          _showError('Erro ao enviar feedback: ${failure.message}');
        },
        (_) {
          setState(() => _isLoading = false);
          _showSuccess(context);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erro ao enviar feedback: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '✅ Feedback enviado com sucesso! Obrigado por nos ajudar a melhorar.',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    Navigator.of(context).pop();
  }
}
