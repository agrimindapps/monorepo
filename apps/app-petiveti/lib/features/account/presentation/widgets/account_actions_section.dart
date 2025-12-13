import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../dialogs/account_deletion_dialog.dart';
import '../dialogs/clear_data_dialog.dart';
import '../utils/widget_utils.dart';

class AccountActionsSection extends ConsumerWidget {
  const AccountActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isAnonymous = authState.user?.provider.name == 'anonymous';
    final isDark = theme.brightness == Brightness.dark;

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
              // Limpar Dados
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
                subtitle: const Text('Limpar dados locais do app'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showClearDataDialog(context, ref),
              ),

              // Logout
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
                onTap: () {
                  ref
                      .read(profileActionsServiceProvider)
                      .showLogoutDialog(
                        context: context,
                        onConfirm: () {
                          ref.read(authProvider.notifier).signOut();
                          context.go('/login');
                        },
                      );
                },
              ),

              // Excluir Conta
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
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showClearDataDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ClearDataDialog(),
    );

    // Dialog já mostra o feedback de sucesso/erro
    if (result == true && context.mounted) {
      // Opcionalmente, você pode adicionar lógica adicional aqui
      // como invalidar providers, etc.
    }
  }

  Future<void> _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AccountDeletionDialog(),
    );

    if (result == true && context.mounted) {
      // Navegar para tela de promo/login após exclusão
      context.go('/promo');
    }
  }
}
