import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/data/models/user_model.dart';
import '../../../../core/providers/dependency_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Danger zone section with destructive actions (clear data, delete account)
class DangerZoneSection extends ConsumerWidget {
  final UserModel? user;

  const DangerZoneSection({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Zona de Perigo', isDestructive: true),
        const SizedBox(height: 8),
        Card(
          elevation: isDark ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.red.withAlpha(51),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildActionTile(
                context,
                icon: Icons.delete_sweep_outlined,
                iconColor: Colors.orange,
                title: 'Limpar Dados',
                subtitle: 'Remover listas e itens mantendo a conta',
                onTap: () => _showClearDataDialog(context, ref),
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                context,
                icon: Icons.delete_forever_outlined,
                iconColor: Colors.red,
                title: 'Excluir Conta',
                subtitle: 'Remover conta permanentemente',
                onTap: () => _showDeleteAccountDialog(context, ref, user?.email),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_sweep, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Limpar Dados'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta ação irá remover:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Todas as suas listas'),
            Text('• Todos os itens'),
            Text('• Configurações personalizadas'),
            SizedBox(height: 16),
            Text(
              'Sua conta será mantida e você poderá continuar usando o app.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Mostrar loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('Limpando dados...'),
                    ],
                  ),
                  duration: Duration(seconds: 30),
                  backgroundColor: Colors.orange,
                ),
              );

              try {
                // Limpar listas locais
                final listDataSource = ref.read(listLocalDataSourceProvider);
                await listDataSource.clearAll();

                // Limpar itens locais
                final itemDataSource = ref.read(listItemLocalDataSourceProvider);
                await itemDataSource.clearAll();

                // Limpar item masters
                final itemMasterDataSource = ref.read(itemMasterLocalDataSourceProvider);
                await itemMasterDataSource.clearAllData();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Dados limpos com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Erro ao limpar dados: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpar Dados'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref, String? email) {
    final confirmController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Excluir Conta'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta ação é permanente e não pode ser desfeita.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Todos os seus dados serão permanentemente removidos:'),
            const SizedBox(height: 8),
            const Text('• Sua conta e perfil'),
            const Text('• Todas as listas e itens'),
            const Text('• Configurações e preferências'),
            const Text('• Histórico de uso'),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                labelText: 'Digite "EXCLUIR" para confirmar',
                hintText: 'EXCLUIR',
                border: const OutlineInputBorder(),
                errorStyle: const TextStyle(color: Colors.red),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade300),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (confirmController.text.toUpperCase() != 'EXCLUIR') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Digite "EXCLUIR" para confirmar'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(context).pop();

              // Mostrar loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('Excluindo conta...'),
                    ],
                  ),
                  duration: Duration(seconds: 30),
                  backgroundColor: Colors.red,
                ),
              );

              try {
                // Primeiro limpar dados locais
                final listDataSource = ref.read(listLocalDataSourceProvider);
                await listDataSource.clearAll();

                final itemDataSource = ref.read(listItemLocalDataSourceProvider);
                await itemDataSource.clearAll();

                final itemMasterDataSource = ref.read(itemMasterLocalDataSourceProvider);
                await itemMasterDataSource.clearAllData();

                // Excluir conta no Firebase
                final success = await ref.read(authProvider.notifier).deleteAccount();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Conta excluída com sucesso'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Navigation will be handled by auth state change
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '❌ Erro ao excluir conta. Tente fazer login novamente e repetir.',
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Erro ao excluir conta: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir Conta'),
          ),
        ],
      ),
    );
  }
}
