import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_providers.dart' as local;
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../dialogs/account_deletion_dialog.dart';
import '../managers/clear_data_dialog_manager.dart';
import '../managers/logout_dialog_manager.dart';
import '../providers/dialog_managers_providers.dart';

/// ✅ REFACTORED: AccountActionsSection - Follows SRP
///
/// ANTES: 460 linhas com:
/// ❌ Dialog construction
/// ❌ Dialog state management
/// ❌ Business logic
/// ❌ Service calls
///
/// DEPOIS: Widget apenas cuida de UI
/// ✅ UI rendering
/// ✅ Delegação de dialogs a managers
/// ✅ Limpo e manutenível
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

    // Obter managers via Riverpod (DIP)
    final clearDataManager = ref.watch(clearDataDialogManagerProvider);
    final logoutManager = ref.watch(logoutDialogManagerProvider);

    return PlantisCard(
      child: Column(
        children: [
          // ✅ Limpar Dados - Delegado a manager
          ListTile(
            leading: Icon(Icons.delete_sweep, color: theme.colorScheme.error),
            title: Text(
              'Limpar Dados',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Limpar plantas e tarefas mantendo conta'),
            onTap: () async {
              await clearDataManager.show(
                context,
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Dados limpos com sucesso!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onError: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Erro ao limpar dados'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              );
            },
          ),

          // ✅ Logout - Delegado a manager
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
            onTap: () async {
              await logoutManager.show(
                context,
                onSuccess: () async {
                  // Navega para tela inicial após logout bem-sucedido
                  if (context.mounted) {
                    context.go('/');
                  }
                },
                onError: () {
                  // Erro já foi mostrado pelo manager
                },
              );
            },
          ),

          // ✅ Excluir Conta - Delegado a dialog dedicado
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
                  showDialog<void>(
                    context: context,
                    builder: (context) =>
                        AccountDeletionDialog(authState: authState),
                  );
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}
