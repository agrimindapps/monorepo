import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/data/models/user_model.dart';
import '../../profile_dialogs/profile_dialogs.dart';

/// Section with profile editing actions
class ProfileActionsSection extends ConsumerWidget {
  final UserModel? user;

  const ProfileActionsSection({
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
        _buildSectionTitle(context, 'Configurações da Conta'),
        const SizedBox(height: 8),
        Card(
          elevation: isDark ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildActionTile(
                context,
                icon: Icons.person_outline,
                iconColor: theme.primaryColor,
                title: 'Editar Perfil',
                subtitle: 'Alterar nome de exibição',
                onTap: () => EditNameDialog.show(context, ref, user?.displayName),
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                context,
                icon: Icons.lock_outline,
                iconColor: theme.primaryColor,
                title: 'Alterar Senha',
                subtitle: 'Enviar email de redefinição',
                onTap: () => ChangePasswordDialog.show(context, ref, user?.email ?? ''),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
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
}
