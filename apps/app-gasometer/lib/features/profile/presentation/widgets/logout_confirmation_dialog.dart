import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';

/// Dialog para confirmação de logout
class LogoutConfirmationDialog extends ConsumerStatefulWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  ConsumerState<LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LogoutConfirmationDialog(),
    );
  }
}

class _LogoutConfirmationDialogState
    extends ConsumerState<LogoutConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusDialog,
        ),
      ),
      title: Row(
        children: [
          Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Sair da Conta',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ao sair da sua conta, as seguintes ações serão realizadas:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildLogoutItem(
            context,
            Icons.cleaning_services,
            'Limpeza de dados locais armazenados',
          ),
          _buildLogoutItem(
            context,
            Icons.sync_disabled,
            'Interrupção da sincronização automática',
          ),
          _buildLogoutItem(
            context,
            Icons.login,
            'Necessário fazer login novamente para acessar',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusButton,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cloud,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seus dados na nuvem permanecem seguros e serão restaurados no próximo login',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _performLogout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusButton,
              ),
            ),
          ),
          child:
              _isLoading
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

  Widget _buildLogoutItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
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

  Future<void> _performLogout(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implementar logout através do controller
      await Future<void>.delayed(
        const Duration(milliseconds: 800),
      ); // Simulação

      if (context.mounted) {
        Navigator.of(context).pop(true);
        // TODO: Navigate to home/login page
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sair: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
