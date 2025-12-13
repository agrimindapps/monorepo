import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/widgets/theme_toggle_switch.dart';
import '../../notifications/presentation/notification_settings_page.dart';
import 'widgets/enhanced_settings_item.dart';
import 'widgets/settings_card.dart';
import 'widgets/settings_sections_builder.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Section (mantido do original)
            SettingsSectionsBuilder.buildUserSection(context, user),
            const SizedBox(height: 16),
            
            // Premium Card (mantido do original)
            SettingsSectionsBuilder.buildPremiumSectionCard(context),
            const SizedBox(height: 24),
            
            // GENERAL SETTINGS - Animated Card
            SettingsCard(
              title: 'Configurações Gerais',
              subtitle: 'Tema, notificações e idioma',
              icon: Icons.settings_outlined,
              category: SettingsCardCategory.general,
              initiallyExpanded: true,
              children: [
                // Theme Toggle
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.palette_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tema Escuro',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Alternar aparência do app',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const ThemeToggleSwitch(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                EnhancedSettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notificações',
                  subtitle: 'Lembretes e alertas',
                  type: SettingsItemType.info,
                  onTap: () => _navigateToNotificationSettings(context),
                ),
                const SizedBox(height: 8),
                EnhancedSettingsItem(
                  icon: Icons.language,
                  title: 'Idioma',
                  subtitle: 'Português (Brasil)',
                  type: SettingsItemType.normal,
                  onTap: () => _showLanguageDialog(context),
                  isLast: true,
                ),
              ],
            ),
            
            // DATA MANAGEMENT - Animated Card
            SettingsCard(
              title: 'Gerenciamento de Dados',
              subtitle: 'Backup, exportação e limpeza',
              icon: Icons.storage_outlined,
              category: SettingsCardCategory.data,
              children: [
                EnhancedSettingsItem(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Backup na Nuvem',
                  subtitle: 'Sincronizar com Firebase',
                  type: SettingsItemType.success,
                  badge: 'NOVO',
                  onTap: () => _showBackupDialog(context),
                  isFirst: true,
                ),
                const SizedBox(height: 8),
                EnhancedSettingsItem(
                  icon: Icons.download_outlined,
                  title: 'Exportar Dados',
                  subtitle: 'JSON ou CSV',
                  type: SettingsItemType.info,
                  onTap: () => _showExportDialog(context),
                ),
                const SizedBox(height: 8),
                EnhancedSettingsItem(
                  icon: Icons.delete_sweep,
                  title: 'Limpar Dados Locais',
                  subtitle: 'Remover todas as tarefas',
                  type: SettingsItemType.danger,
                  onTap: () => _showClearDataDialog(context),
                  isLast: true,
                ),
              ],
            ),
            
            // SUPPORT - Animated Card
            SettingsCard(
              title: 'Suporte e Informações',
              subtitle: 'Ajuda, avaliações e sobre',
              icon: Icons.support_agent_outlined,
              category: SettingsCardCategory.account,
              children: [
                EnhancedSettingsItem(
                  icon: Icons.help_outline,
                  title: 'Central de Ajuda',
                  subtitle: 'Tutoriais e guias',
                  type: SettingsItemType.info,
                  onTap: () => _showHelpDialog(context),
                  isFirst: true,
                ),
                const SizedBox(height: 8),
                EnhancedSettingsItem(
                  icon: Icons.star_outline,
                  title: 'Avaliar na Store',
                  subtitle: 'Sua opinião é importante',
                  type: SettingsItemType.success,
                  onTap: () => _showRatingDialog(context),
                ),
                const SizedBox(height: 8),
                EnhancedSettingsItem(
                  icon: Icons.info_outline,
                  title: 'Sobre o App',
                  subtitle: 'Versão 1.0.0 • Build 1',
                  type: SettingsItemType.normal,
                  onTap: () => _showAboutDialog(context),
                  isLast: true,
                ),
              ],
            ),
            
            // ACCOUNT ACTIONS - Animated Card (Danger)
            SettingsCard(
              title: 'Ações da Conta',
              subtitle: 'Logout e configurações críticas',
              icon: Icons.account_circle_outlined,
              category: SettingsCardCategory.privacy,
              children: [
                EnhancedSettingsItem(
                  icon: Icons.logout,
                  title: 'Sair da Conta',
                  subtitle: 'Encerrar sessão atual',
                  type: SettingsItemType.danger,
                  onTap: () => _showLogoutDialog(context, ref),
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    'Taskolist',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Feito com ❤️ por Agrimind',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clean Architecture • Riverpod • Drift',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
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
              // Navigator.pop(context); // Não precisamos voltar mais uma vez pois estamos na raiz da tab ou similar

              try {
                await ref.read(authProvider.notifier).signOut();
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
      builder: (context) => AlertDialog(
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

  void _showBackupDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup'),
        content: const Text(
          'Sincronização com a nuvem será implementada em breve.',
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

  void _showLanguageDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Idioma'),
        content: const Text(
          'Suporte a múltiplos idiomas será implementado em breve.',
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
      builder: (context) => AlertDialog(
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
      builder: (context) => AlertDialog(
        title: const Text('Ajuda'),
        content: const Text(
          'Taskolist é um aplicativo para gerenciar suas tarefas pessoais.\n\n• Adicione tarefas rapidamente\n• Organize por prioridade\n• Marque como favoritas\n• Adicione comentários e anotações\n\nPara suporte, entre em contato conosco.',
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

  void _showRatingDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avaliar app'),
        content: const Text(
          'Gostou do Taskolist?\n\nSua avaliação nos ajuda a melhorar o aplicativo!',
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

  void _showAboutDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.task_alt, color: AppColors.primaryColor),
            SizedBox(width: 12),
            Text('Sobre o Taskolist'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Taskolist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Versão 1.0.0 (Build 1)',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              '🚀 Tecnologias:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Flutter 3.9+'),
            Text('• Clean Architecture'),
            Text('• Riverpod (State Management)'),
            Text('• Drift (Local Database)'),
            Text('• Firebase (Backend)'),
            SizedBox(height: 16),
            Text(
              '💚 Desenvolvido com ❤️ por Agrimind Soluções',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
