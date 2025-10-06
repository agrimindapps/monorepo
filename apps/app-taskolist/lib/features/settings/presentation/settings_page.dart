import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/widgets/theme_toggle_switch.dart';
import '../../account/presentation/account_page.dart';
import '../../notifications/presentation/notification_settings_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userDisplayName = authState.value?.displayName ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserHeader(context, userDisplayName),

            const SizedBox(height: 24),
            _buildSectionCard(
              context,
              title: 'Aparência',
              children: [
                const ThemeToggleSwitch(),
                const SizedBox(height: 8),
                Text(
                  'Escolha o tema da interface do aplicativo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Conta',
              children: [
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Minha Conta'),
                  subtitle: Text(userDisplayName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToAccountPage(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Notificações',
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Configurações de Notificação'),
                  subtitle: const Text('Lembretes, alertas e configurações'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToNotificationSettings(context),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Dados',
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Exportar dados'),
                  subtitle: const Text('Exportar tarefas como arquivo'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showExportDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.warning,
                  ),
                  title: const Text(
                    'Limpar dados',
                    style: TextStyle(color: AppColors.warning),
                  ),
                  subtitle: const Text('Remover todas as tarefas locais'),
                  onTap: () => _showClearDataDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildSectionCard(
              context,
              title: 'Sobre',
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Versão'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Ajuda'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showHelpDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text('Avaliar app'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showRatingDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 32),
            Text(
              'Task Manager',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gerenciador de tarefas pessoal',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Task Manager',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onPrimary.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sair'),
            content: const Text('Tem certeza que deseja sair do aplicativo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pop(context); // Voltar para tela anterior

                  try {
                    await ref.read(authNotifierProvider.notifier).signOut();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao sair: ${e.toString()}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sair'),
              ),
            ],
          ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Exportar dados'),
            content: const Text(
              'Funcionalidade em desenvolvimento.\n\nEm breve você poderá exportar suas tarefas para arquivo JSON ou CSV.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Limpar dados'),
            content: const Text(
              'Tem certeza que deseja remover todas as tarefas?\n\nEsta ação não pode ser desfeita.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Limpar'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajuda'),
            content: const Text(
              'Task Manager é um aplicativo para gerenciar suas tarefas pessoais.\n\n• Adicione tarefas rapidamente\n• Organize por prioridade\n• Marque como favoritas\n• Adicione comentários e anotações\n\nPara suporte, entre em contato conosco.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendi'),
              ),
            ],
          ),
    );
  }

  void _navigateToNotificationSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (context) => const NotificationSettingsPage(),
      ),
    );
  }

  void _navigateToAccountPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(builder: (context) => const AccountPage()),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Avaliar app'),
            content: const Text(
              'Gostou do Task Manager?\n\nSua avaliação nos ajuda a melhorar o aplicativo!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Mais tarde'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Obrigado pelo interesse! Link da store em breve.',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Avaliar'),
              ),
            ],
          ),
    );
  }
}
