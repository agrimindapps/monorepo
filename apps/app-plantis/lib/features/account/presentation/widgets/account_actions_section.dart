import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_providers.dart' as local;
import '../dialogs/account_deletion_dialog.dart';
import '../providers/dialog_managers_providers.dart';
import '../utils/widget_utils.dart';

/// ✅ REFACTORED: AccountActionsSection - Follows SRP
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
    final isDark = theme.brightness == Brightness.dark;

    // Obter managers via Riverpod (DIP)
    final clearDataManager = ref.watch(clearDataDialogManagerProvider);
    final logoutManager = ref.watch(logoutDialogManagerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(context, 'Ações da Conta'),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ✅ Limpar Dados - Delegado a manager
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
            subtitle: const Text('Limpar plantas e tarefas mantendo conta'),
            trailing: const Icon(Icons.chevron_right),
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
        ),
      ],
    );
  }
}
