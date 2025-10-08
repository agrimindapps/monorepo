import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/notifiers/notifiers.dart';
import '../../../data_export/presentation/widgets/export_data_section.dart';
import '../controllers/profile_controller.dart';
import 'account_deletion_dialog.dart';
import 'authenticated_user_section.dart';
import 'avatar_section.dart';
import 'data_clear_dialog.dart';
import 'devices_section_widget.dart';
import 'logout_confirmation_dialog.dart';

/// Widget responsável por exibir todas as seções do perfil
class ProfileSections extends ConsumerStatefulWidget {
  final dynamic user;
  final bool isAnonymous;
  final ProfileController profileController;

  const ProfileSections({
    super.key,
    required this.user,
    required this.isAnonymous,
    required this.profileController,
  });

  @override
  ConsumerState<ProfileSections> createState() => _ProfileSectionsState();
}

class _ProfileSectionsState extends ConsumerState<ProfileSections> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProfileSection(),
        if (!widget.isAnonymous) ...[
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          const DevicesSectionWidget(),
        ],
        if (!widget.isAnonymous) ...[
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          _buildAccountInfoSection(),
        ],
        if (!widget.isAnonymous) ...[
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          _buildSyncSection(),
        ],
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildSettingsSection(),
        if (!widget.isAnonymous) ...[
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          const ExportDataSection(),
        ],
        if (!widget.isAnonymous) ...[
          const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
          _buildDataManagementSection(),
        ],
        const SizedBox(height: GasometerDesignTokens.spacingSectionSpacing),
        _buildActionsSection(),
      ],
    );
  }

  Widget _buildProfileSection() {
    final isPremium = ref.watch(isPremiumProvider);

    return _buildSection(
      context,
      title: 'Informações Pessoais',
      icon: Icons.person,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusDialog,
            ),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 20),
                if (widget.isAnonymous) ...[
                  _buildAnonymousUserSection(),
                ] else ...[
                  _buildAuthenticatedUserSection(isPremium),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return AvatarSection(
      user: widget.user,
      isAnonymous: widget.isAnonymous,
      profileController: widget.profileController,
    );
  }

  Widget _buildAnonymousUserSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.info, color: Colors.orange.shade700),
          const SizedBox(height: 8),
          Text(
            'Usuário Anônimo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seus dados estão salvos localmente. Para sincronizar entre dispositivos e ter acesso a recursos avançados, crie uma conta.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.orange.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedUserSection(bool isPremium) {
    return AuthenticatedUserSection(user: widget.user, isPremium: isPremium);
  }

  Widget _buildAccountInfoSection() {
    final isPremium = ref.watch(isPremiumProvider);

    return _buildSection(
      context,
      title: 'Informações da Conta',
      icon: Icons.info,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusDialog,
            ),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo: ${isPremium ? 'Premium' : 'Gratuita'}'),
                if (widget.user?.createdAt != null)
                  Text(
                    'Criado em: ${_formatDate(widget.user!.createdAt as DateTime)}',
                  ),
                if (widget.user?.lastSignInAt != null)
                  Text(
                    'Último acesso: ${_formatDate(widget.user!.lastSignInAt as DateTime)}',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncSection() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusDialog,
        ),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(Icons.sync, color: Theme.of(context).colorScheme.primary),
        title: const Text('Sincronização'),
        subtitle: const Text('Aguardando Phase 2 - UnifiedSync'),
        trailing: const Icon(Icons.info_outline),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return _buildSection(
      context,
      title: 'Configurações e Privacidade',
      icon: Icons.settings,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusDialog,
            ),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Column(
            children: [
              _buildSettingsItem(
                icon: Icons.privacy_tip,
                title: 'Política de Privacidade',
                subtitle: 'Como tratamos seus dados',
                onTap: () => context.go('/privacy'),
              ),
              _buildSettingsItem(
                icon: Icons.description,
                title: 'Termos de Uso',
                subtitle: 'Condições de uso do aplicativo',
                onTap: () => context.go('/terms'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataManagementSection() {
    return _buildSection(
      context,
      title: 'Gerenciamento de Dados',
      icon: Icons.cleaning_services,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusDialog,
            ),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Column(
            children: [
              _buildSettingsItem(
                icon: Icons.delete_sweep,
                title: 'Limpar Dados',
                subtitle: 'Limpar veículos, abastecimentos e manutenções',
                onTap: () => _showClearDataDialog(),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return _buildSection(
      context,
      title: 'Ações da Conta',
      icon: Icons.security,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusDialog,
            ),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Column(
            children: [
              _buildSettingsItem(
                icon: Icons.logout,
                title: 'Sair da Conta',
                subtitle:
                    widget.isAnonymous
                        ? 'Sair do modo anônimo'
                        : 'Fazer logout',
                onTap: () => _handleLogout(),
              ),
              if (!widget.isAnonymous)
                _buildSettingsItem(
                  icon: Icons.delete_forever,
                  title: 'Excluir Conta',
                  subtitle: 'Remover permanentemente sua conta',
                  onTap: () => _showAccountDeletionDialog(),
                  isDestructive: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusCard,
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: GasometerDesignTokens.iconSizeButton,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isDestructive
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                size: GasometerDesignTokens.iconSizeListItem,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showClearDataDialog() async {
    await DataClearDialog.show(context);
  }

  void _handleLogout() async {
    final confirmed = await LogoutConfirmationDialog.show(context);
    if (confirmed == true && context.mounted) {
      await widget.profileController.performLogout(context, ref);
    }
  }

  void _showAccountDeletionDialog() async {
    await AccountDeletionDialog.show(context);
  }
}
