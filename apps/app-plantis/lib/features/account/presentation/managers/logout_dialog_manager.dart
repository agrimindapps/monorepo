import 'package:core/core.dart' hide LogoutUseCase;
import 'package:flutter/material.dart';

import '../../domain/usecases/logout_usecase.dart';

/// ✅ REFACTORED: Dialog Manager para Logout
/// Segue SRP: Responsável APENAS por gerenciar dialog de logout
///
/// ANTES: account_actions_section.dart tinha lógica misturada
/// DEPOIS: Manager segregado com responsabilidade única
///
/// BENEFITS:
/// ✅ SRP: Apenas gerencia dialog de logout
/// ✅ Reusable: Pode ser usado em qualquer lugar
/// ✅ Testable: Fácil mockar e testar
/// ✅ Maintainable: Mudanças isoladas a este manager

class LogoutDialogManager {
  final LogoutUseCase _logoutUseCase;

  LogoutDialogManager({required LogoutUseCase logoutUseCase})
    : _logoutUseCase = logoutUseCase;

  /// Exibe dialog de confirmação para logout
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
            Icon(
              Icons.logout_outlined,
              color: theme.colorScheme.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Sair da Conta',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Tem certeza que deseja sair da sua conta? '
          'Você precisará fazer login novamente para acessar sua conta.',
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

              // Executar logout
              final result = await _logoutUseCase(const NoParams());

              result.fold(
                (Failure failure) {
                  onError?.call();
                  _showErrorSnackbar(context, failure);
                },
                (_) {
                  onSuccess?.call();
                },
              );
            },
            child: const Text('Sair'),
          ),
        ],
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
