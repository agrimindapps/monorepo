import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../domain/usecases/clear_data_usecase.dart';

/// ✅ REFACTORED: Dialog Manager para Clear Data
/// Segue SRP: Responsável APENAS por gerenciar dialog de limpeza de dados
///
/// ANTES: account_actions_section.dart tinha 460 linhas com toda lógica misturada
/// DEPOIS: Manager segregado com responsabilidade única
///
/// BENEFITS:
/// ✅ SRP: Apenas gerencia dialog de clear data
/// ✅ Reusable: Pode ser usado em qualquer lugar
/// ✅ Testable: Fácil mockar e testar
/// ✅ Maintainable: Mudanças isoladas a este manager

class ClearDataDialogManager {
  final ClearDataUseCase _clearDataUseCase;

  ClearDataDialogManager({required ClearDataUseCase clearDataUseCase})
    : _clearDataUseCase = clearDataUseCase;

  /// Exibe dialog de confirmação para limpar dados
  /// Retorna true se confirmar, false se cancelar
  Future<bool?> show(
    BuildContext context, {
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) {
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_sweep, color: theme.colorScheme.error, size: 28),
            const SizedBox(width: 12),
            Text(
              'Limpar Dados',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Tem certeza que deseja limpar todos os dados? '
          'Isso irá remover todas as plantas e tarefas.'
          '\n\nSua conta permanecerá ativa.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext, true);

              // Executar limpeza
              final result = await _clearDataUseCase(const NoParams());

              result.fold(
                (failure) {
                  onError?.call();
                  _showErrorSnackbar(context, failure);
                },
                (_) {
                  onSuccess?.call();
                  _showSuccessSnackbar(context);
                },
              );
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados limpos com sucesso'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro: ${failure.message}'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }
}
