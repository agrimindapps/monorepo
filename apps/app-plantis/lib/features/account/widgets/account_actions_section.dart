import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart' as local;
import '../../../shared/widgets/base_page_scaffold.dart';

class AccountActionsSection extends ConsumerWidget {
  const AccountActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authStateAsync = ref.watch(local.authProvider);
    final isAnonymous = authStateAsync.maybeWhen(
      data: (authState) => authState.isAnonymous,
      orElse: () => true,
    );

    return PlantisCard(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.delete_sweep, color: theme.colorScheme.error),
            title: Text(
              'Limpar Dados',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Limpar plantas e tarefas mantendo conta'),
            onTap: () {
              authStateAsync.whenData((authState) {
                _showClearDataDialog(context, authState);
              });
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Sair da Conta',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Fazer logout da aplicação'),
            onTap: () {
              authStateAsync.whenData((authState) {
                _showLogoutDialog(context, authState);
              });
            },
          ),
          if (!isAnonymous) ...[
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Excluir Conta',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              subtitle: const Text('Remover conta permanentemente'),
              onTap: () {
                authStateAsync.whenData((authState) {
                  _showDeleteAccountDialog(context, authState);
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, local.AuthState authState) {
    // TODO: Implement clear data dialog
    // This will be implemented when we extract the dialog functionality
  }

  void _showLogoutDialog(BuildContext context, local.AuthState authState) {
    // TODO: Implement logout dialog
    // This will be implemented when we extract the dialog functionality
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    local.AuthState authState,
  ) {
    // TODO: Implement delete account dialog
    // This will be implemented when we extract the dialog functionality
  }
}
