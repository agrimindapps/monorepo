import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../dialogs/dialogs.dart';
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
                onTap: () => _showThemeDialog(context),
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
                onTap: () => AboutAppDialog.show(context),
              ),
              SettingsItem(
                icon: Icons.privacy_tip,
                title: 'Política de Privacidade',
                subtitle: 'Como protegemos seus dados',
                onTap: () => context.push(AppConstants.privacyPolicyRoute),
              ),
              SettingsItem(
                icon: Icons.description,
                title: 'Termos de Uso',
                subtitle: 'Termos e condições de uso',
                onTap: () => context.push(AppConstants.termsOfServiceRoute),
              ),
              SettingsItem(
                icon: Icons.delete_outline,
                title: 'Política de Exclusão de Conta',
                subtitle: 'Como seus dados são removidos',
                onTap: () => context.push(AppConstants.accountDeletionPolicyRoute),
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

  void _showThemeDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const ThemeSelectionDialog(),
    );
  }

  Future<void> _showRateAppDialog(BuildContext context) async {
    final confirmed = await RateAppDialog.show(context);
    if (confirmed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Obrigado pelo interesse! (em desenvolvimento)'),
        ),
      );
    }
  }

  Future<void> _showFeedbackDialog(BuildContext context) async {
    final confirmed = await FeedbackDialog.show(context);
    if (confirmed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Em desenvolvimento'),
        ),
      );
    }
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
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
