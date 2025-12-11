import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_di_providers.dart';
import '../../../../core/services/data_sanitization_service.dart';
import '../utils/text_formatters.dart';

/// Dialog stateful para confirmação de limpeza de dados
class DataClearDialog extends ConsumerStatefulWidget {
  const DataClearDialog({super.key});

  @override
  ConsumerState<DataClearDialog> createState() => _DataClearDialogState();
}

class _DataClearDialogState extends ConsumerState<DataClearDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateConfirmation);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateConfirmation() {
    setState(() {
      _isConfirmationValid =
          _confirmationController.text.trim().toUpperCase() == 'LIMPAR';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(Icons.delete_sweep, size: 32, color: Colors.red),
          ),

          const SizedBox(height: 20),
          const Text(
            'Limpar Dados do App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esta ação limpará todos os dados em todos seus dispositivos:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildClearItem(
                context,
                Icons.local_florist,
                'Todas as suas plantas',
              ),
              _buildClearItem(
                context,
                Icons.task_alt,
                'Todas as tarefas e lembretes',
              ),
              _buildClearItem(
                context,
                Icons.space_dashboard,
                'Todos os espaços criados',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.shield, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Serão mantidos: perfil, configurações, tema e assinatura',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Para confirmar, digite LIMPAR abaixo:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmationController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Digite LIMPAR para confirmar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.orange,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isConfirmationValid && !_isLoading
              ? () async {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    final dataCleanerService = ref.read(
                      dataCleanerServiceProvider,
                    );
                    final result = await dataCleanerService
                        .clearUserContentOnly();

                    if (context.mounted) {
                      Navigator.of(context).pop();

                      if (result['success'] as bool) {
                        final plantsCleaned = result['plantsCleaned'] as int;
                        final tasksCleaned = result['tasksCleaned'] as int;
                        final spacesCleaned = result['spacesCleaned'] as int;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Dados limpos com sucesso!\n'
                              'Plantas: $plantsCleaned | Tarefas: $tasksCleaned | Espaços: $spacesCleaned',
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      } else {
                        final errors = result['errors'] as List<String>;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erro ao limpar dados: ${errors.join(', ')}',
                            ),
                            backgroundColor: theme.colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erro ao limpar dados: ${DataSanitizationService.sanitizeForLogging(e.toString())}',
                          ),
                          backgroundColor: theme.colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }

                  setState(() {
                    _isLoading = false;
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isConfirmationValid && !_isLoading
                ? Colors.orange
                : theme.colorScheme.onSurface.withValues(alpha: 0.12),
            foregroundColor: _isConfirmationValid && !_isLoading
                ? Colors.white
                : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Limpar Dados'),
        ),
      ],
    );
  }

  /// Constrói item de informação sobre limpeza
  Widget _buildClearItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
