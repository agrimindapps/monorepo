import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/di/injection_container.dart' as di;
import '../../../core/providers/auth_providers.dart' as local;
import '../../../core/services/data_cleaner_service.dart';
import '../../../shared/widgets/base_page_scaffold.dart';
import '../dialogs/account_deletion_dialog.dart';

class AccountActionsSection extends ConsumerWidget {
  const AccountActionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mantém referência ao ref para usar nos dialogs
    final authNotifier = ref.read(local.authProvider.notifier);
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
                _showClearDataDialog(context, authState, authNotifier);
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
                _showLogoutDialog(context, authState, authNotifier);
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

  void _showClearDataDialog(
    BuildContext context,
    local.AuthState authState,
    local.AuthNotifier authNotifier,
  ) {
    final theme = Theme.of(context);
    showDialog<bool>(
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta ação irá remover:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildWarningItem(
              context,
              Icons.eco_outlined,
              'Todas as suas plantas cadastradas',
            ),
            _buildWarningItem(
              context,
              Icons.task_outlined,
              'Todas as tarefas e lembretes',
            ),
            _buildWarningItem(
              context,
              Icons.history,
              'Histórico de cuidados e atividades',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sua conta permanecerá ativa. Você poderá começar a usar o app novamente a qualquer momento.',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onPrimaryContainer,
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
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Limpar Dados'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true && context.mounted) {
        await _performClearData(context);
      }
    });
  }

  Future<void> _performClearData(BuildContext context) async {
    // Mostrar loading
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Limpando dados...'),
              ],
            ),
          ),
        ),
      ),
    ));

    try {
      final dataCleanerService = di.sl<DataCleanerService>();
      final result = await dataCleanerService.clearUserContentOnly();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Fecha loading

      if (result['success'] == true) {
        final totalCleared = result['totalRecordsCleared'] as int;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Dados limpos com sucesso! ($totalCleared registros)'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        final errors = result['errors'] as List<String>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Limpeza parcial. Erros: ${errors.length}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Fecha loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao limpar dados: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLogoutDialog(
    BuildContext context,
    local.AuthState authState,
    local.AuthNotifier authNotifier,
  ) {
    final theme = Theme.of(context);
    showDialog<bool>(
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja sair?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ao sair da conta:',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildWarningItem(
              context,
              Icons.sync_disabled,
              'Dados não sincronizados podem ser perdidos',
            ),
            _buildWarningItem(
              context,
              Icons.cloud_off,
              'Você não receberá notificações até fazer login novamente',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seus dados estão salvos e você pode fazer login novamente quando quiser.',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onPrimaryContainer,
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
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true && context.mounted) {
        await _performLogout(context, authNotifier);
      }
    });
  }

  Future<void> _performLogout(
    BuildContext context,
    local.AuthNotifier authNotifier,
  ) async {
    // Mostrar loading
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Saindo da conta...'),
              ],
            ),
          ),
        ),
      ),
    ));

    try {
      await authNotifier.logout();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Fecha loading

      // Navega para tela de login/home
      context.go('/');

      // Mostra snackbar de sucesso
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Logout realizado com sucesso!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Fecha loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao fazer logout: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    local.AuthState authState,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AccountDeletionDialog(authState: authState),
    );
  }

  Widget _buildWarningItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
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
