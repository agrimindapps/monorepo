// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../../core/services/app_rating_service.dart';
import '../constants/todoist_colors.dart';
import '../controllers/auth_controller.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_selector_panel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSync = true;
  bool _offlineMode = false;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<TodoistAuthController>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Obx(() => Scaffold(
          backgroundColor: TodoistColors.backgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          TodoistColors.primaryColor,
                          TodoistColors.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'TodoList',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Gerencie suas preferências',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.palette,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const ThemeSelectorPanel(),
                      );
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Seção Usuário
                    _buildUserSection(context, authController),
                    const SizedBox(height: 16),

                    // Seção Assinatura
                    _buildSubscriptionSection(context),
                    const SizedBox(height: 16),

                    // Seção Notificações
                    _buildNotificationsSection(context, themeProvider),
                    const SizedBox(height: 16),

                    // Seção Personalização
                    _buildCustomizationSection(context, themeProvider),
                    const SizedBox(height: 16),

                    // Seção Desenvolvimento
                    _buildDevelopmentSection(context),
                    const SizedBox(height: 16),

                    // Seção Sobre
                    _buildAboutSection(context),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildUserSection(
      BuildContext context, TodoistAuthController authController) {
    final theme = Theme.of(context);
    final user = authController.currentUser;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conta',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (user != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.primaryColor,
                    child: Text(
                      (user.displayName ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'Usuário',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingsItem(
                icon: Icons.sync,
                title: 'Sincronizar Dados',
                onTap: () {
                  // TODO: Implementar sincronização
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sincronizando dados...')),
                  );
                },
              ),
              _buildSettingsItem(
                icon: Icons.logout,
                title: 'Sair da Conta',
                onTap: () {
                  authController.signOut();
                },
                isDestructive: true,
              ),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 60, color: theme.primaryColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fazer Login',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Sincronize suas tarefas em todos os dispositivos',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Fazer Login'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context) {
    final theme = Theme.of(context);
    const isPremium = false; // TODO: Implementar lógica de assinatura

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assinatura',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (isPremium) ...[
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.star, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium Ativo',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Renova em 30 dias',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingsItem(
                icon: Icons.manage_accounts,
                title: 'Gerenciar Assinatura',
                onTap: () {
                  // TODO: Implementar gerenciamento de assinatura
                },
              ),
            ] else ...[
              Row(
                children: [
                  const Icon(Icons.star_outline, size: 60, color: Colors.amber),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recursos Premium',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '• Sincronização ilimitada\n• Temas personalizados\n• Backup automático',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implementar assinatura premium
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Funcionalidade em desenvolvimento')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Assinar Premium'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(
      BuildContext context, ThemeProvider themeProvider) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificações',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              icon: Icons.notifications_outlined,
              title: 'Notificações Push',
              subtitle: 'Receber lembretes de tarefas',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSwitchItem(
              icon: Icons.sync_outlined,
              title: 'Sincronização Automática',
              subtitle: 'Sincronizar dados automaticamente',
              value: _autoSync,
              onChanged: (value) {
                setState(() {
                  _autoSync = value;
                });
              },
            ),
            _buildSwitchItem(
              icon: Icons.wifi_off_outlined,
              title: 'Modo Offline',
              subtitle: 'Trabalhar sem conexão com internet',
              value: _offlineMode,
              onChanged: (value) {
                setState(() {
                  _offlineMode = value;
                });
              },
            ),
            _buildSwitchItem(
              icon: Icons.dark_mode_outlined,
              title: 'Modo Escuro',
              subtitle: 'Alternar entre tema claro e escuro',
              value: themeProvider.isDark,
              onChanged: (value) {
                themeProvider.toggleDarkMode();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationSection(
      BuildContext context, ThemeProvider themeProvider) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalização',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.palette_outlined,
              title: 'Temas e Cores',
              subtitle: 'Personalize a aparência do app',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const ThemeSelectorPanel(),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.text_fields_outlined,
              title: 'Tamanho da Fonte',
              subtitle: 'Ajustar tamanho do texto',
              onTap: () {
                // TODO: Implementar ajuste de fonte
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sobre',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Central de Ajuda',
              onTap: () {
                // TODO: Implementar central de ajuda
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento')),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'Sobre o App',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('TodoList'),
                    content: const Text(
                      'Versão 1.0.0\n\nUm app simples e eficiente para gerenciar suas tarefas diárias.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Política de Privacidade',
              onTap: () {
                // TODO: Implementar política de privacidade
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento')),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.description_outlined,
              title: 'Termos de Uso',
              onTap: () {
                // TODO: Implementar termos de uso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento')),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.star_rate_outlined,
              title: 'Avaliar o App',
              subtitle: 'Avalie nossa experiência na loja',
              onTap: _handleAppRating,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopmentSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desenvolvimento',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.campaign_outlined,
              title: 'Página promocional',
              onTap: () {
                // TODO: Implementar página promocional
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : theme.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// Lida com a solicitação de avaliação do app
  Future<void> _handleAppRating() async {
    try {
      final success = await AppRatingService.instance.requestRating();
      if (!success) {
        // Se não conseguir mostrar o diálogo nativo, abre a loja diretamente
        await AppRatingService.instance.openStoreListing();
      }
    } catch (e) {
      // Em caso de erro, tenta abrir a loja como fallback
      try {
        await AppRatingService.instance.openStoreListing();
      } catch (fallbackError) {
        // Log do erro mas não interrompe a experiência do usuário
        // TODO: Implementar logging framework adequado
        debugPrint('Erro ao abrir avaliação do app: $fallbackError');
      }
    }
  }
}
