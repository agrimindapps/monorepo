import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

/// Settings page with user info and configuration options
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Section
          if (user != null) ...[
            Card(
              child: InkWell(
                onTap: () => context.push(AppConstants.profileRoute),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.primaryColor,
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Premium Card Section
          _buildPremiumCard(context),
          const SizedBox(height: 24),

          // App Section
          SettingsSection(
            title: 'Aplicativo',
            children: [
              SettingsItem(
                icon: Icons.notifications,
                title: 'Notificações',
                subtitle:
                    kIsWeb
                        ? 'Não disponível na web'
                        : 'Configure seus lembretes',
                onTap: () {
                  if (!kIsWeb) {
                    context.push(AppConstants.notificationsRoute);
                  }
                },
              ),
              SettingsItem(
                icon: Icons.palette,
                title: 'Tema',
                subtitle: 'Escolha entre claro, escuro ou automático',
                onTap: () => _showThemeDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Support Section
          SettingsSection(
            title: 'Suporte',
            children: [
              SettingsItem(
                icon: Icons.star_rate,
                title: 'Avaliar o App',
                subtitle: 'Avalie nossa experiência na loja',
                onTap: () => _showRateAppDialog(context),
              ),
              SettingsItem(
                icon: Icons.feedback,
                title: 'Enviar Feedback',
                subtitle: 'Nos ajude a melhorar o app',
                onTap: () => _showFeedbackDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // About Section
          SettingsSection(
            title: 'Sobre',
            children: [
              SettingsItem(
                icon: Icons.info,
                title: 'Informações do App',
                subtitle: 'Versão, suporte e feedback',
                onTap: () => _showAboutDialog(context),
              ),
              SettingsItem(
                icon: Icons.privacy_tip,
                title: 'Política de Privacidade',
                subtitle: 'Como protegemos seus dados',
                onTap: () {
                  // TODO: Implementar página de privacidade
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Em desenvolvimento'),
                    ),
                  );
                },
              ),
              SettingsItem(
                icon: Icons.description,
                title: 'Termos de Uso',
                subtitle: 'Termos e condições de uso',
                onTap: () {
                  // TODO: Implementar página de termos
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Em desenvolvimento'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Danger Zone
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sair da Conta',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _showLogoutConfirmation(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF673AB7), Color(0xFF3F51B5)], // Deep Purple → Indigo
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppConstants.premiumRoute),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NebulaList Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Desbloqueie recursos ilimitados',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeProvider);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              ref,
              ThemeMode.system,
              'Automático (Sistema)',
              'Segue a configuração do sistema',
              Icons.brightness_auto,
              currentTheme,
            ),
            _buildThemeOption(
              context,
              ref,
              ThemeMode.light,
              'Claro',
              'Tema claro sempre ativo',
              Icons.brightness_high,
              currentTheme,
            ),
            _buildThemeOption(
              context,
              ref,
              ThemeMode.dark,
              'Escuro',
              'Tema escuro sempre ativo',
              Icons.brightness_2,
              currentTheme,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
    ThemeMode currentTheme,
  ) {
    final isSelected = currentTheme == mode;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        await ref.read(themeProvider.notifier).setThemeMode(mode);
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tema "$title" selecionado')),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  void _showRateAppDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star_rate, color: Colors.amber, size: 28),
            SizedBox(width: 12),
            Text('Avaliar o App'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Está gostando do NebulaList?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Sua avaliação nos ajuda a melhorar e alcançar mais pessoas!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mais tarde'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement app rating
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Obrigado pelo interesse! (em desenvolvimento)'),
                ),
              );
            },
            icon: const Icon(Icons.star),
            label: const Text('Avaliar'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.feedback, size: 28),
            SizedBox(width: 12),
            Text('Enviar Feedback'),
          ],
        ),
        content: const Text(
          'Tem sugestões ou encontrou algum problema? Entre em contato conosco!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement feedback form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Em desenvolvimento'),
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
              child: const Icon(Icons.list_alt, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('NebulaList'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu gerenciador de tarefas moderno',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Versão', '1.0.0'),
            _buildInfoRow(context, 'Build', '1'),
            _buildInfoRow(context, 'Plataforma', 'Flutter'),
            const SizedBox(height: 16),
            Text(
              'Sistema de gerenciamento de tarefas com sincronização em nuvem.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppConstants.loginRoute);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
