import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Dialog de confirmação de logout
class LogoutConfirmationDialog extends ConsumerStatefulWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  ConsumerState<LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState
    extends ConsumerState<LogoutConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.logout, color: Colors.red, size: 24),
          SizedBox(width: 12),
          Text('Sair da Conta'),
        ],
      ),
      content: const Text('Tem certeza que deseja sair da sua conta?'),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
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
              : const Text('Sair'),
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).signOut();
      if (!mounted) return;

      Navigator.of(context).pop();
      context.go(AppConstants.loginRoute);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sair: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Mostra o dialog de confirmação de logout
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const LogoutConfirmationDialog(),
    );
  }
}
