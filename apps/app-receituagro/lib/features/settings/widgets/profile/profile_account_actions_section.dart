import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Widget para ações da conta (logout, delete, clear data)
/// Responsabilidade: Display e ações destrutivas da conta
class ProfileAccountActionsSection extends ConsumerWidget {
  const ProfileAccountActionsSection({
    required this.authData,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onClearData,
    super.key,
  });

  final dynamic authData;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final VoidCallback onClearData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
          child: Text(
            'Ações da Conta',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        DecoratedBox(
          decoration: _getCardDecoration(context),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_sweep,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: const Text('Limpar Dados'),
                subtitle: const Text(
                  'Limpar dados do aplicativo mantendo conta',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: onClearData,
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 20),
                ),
                title: const Text('Sair da Conta'),
                subtitle: const Text('Fazer logout da aplicação'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onLogout,
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: const Text('Excluir Conta'),
                subtitle: const Text('Remover conta permanentemente'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onDeleteAccount,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper: Decoração de card
  BoxDecoration _getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
