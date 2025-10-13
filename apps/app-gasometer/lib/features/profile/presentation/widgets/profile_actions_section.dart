import 'dart:async';

import 'package:core/core.dart' show GoRouterHelper;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/data_sanitization_service.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/notifiers/notifiers.dart';
import 'profile_dialogs.dart';
import 'profile_info_item.dart';
import 'profile_section_card.dart';
import 'profile_settings_item.dart';

/// Widget para seção de ações da conta (logout, excluir)
class ProfileActionsSection extends ConsumerWidget {
  final bool isAnonymous;

  const ProfileActionsSection({
    super.key,
    required this.isAnonymous,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileSectionCard(
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
              ProfileSettingsItem(
                icon: Icons.logout,
                title: 'Sair da Conta',
                subtitle: isAnonymous ? 'Sair do modo anônimo' : 'Fazer logout',
                onTap: () => _handleLogout(context, ref),
                isFirst: true,
                isLast: isAnonymous,
              ),
              if (!isAnonymous)
                ProfileSettingsItem(
                  icon: Icons.delete_forever,
                  title: 'Excluir Conta',
                  subtitle: 'Remover permanentemente sua conta',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showAccountDeletionDialog(context);
                  },
                  isLast: true,
                  isDestructive: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAccountDeletionDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const AccountDeletionDialog(),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusDialog,
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Sair da Conta',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
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
              'Ao sair da sua conta, as seguintes ações serão realizadas:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            const ProfileInfoItem(
              icon: Icons.cleaning_services,
              text: 'Limpeza de dados locais armazenados',
            ),
            const ProfileInfoItem(
              icon: Icons.sync_disabled,
              text: 'Interrupção da sincronização automática',
            ),
            const ProfileInfoItem(
              icon: Icons.login,
              text: 'Necessário fazer login novamente para acessar',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: GasometerDesignTokens.borderRadius(
                  GasometerDesignTokens.radiusButton,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seus dados na nuvem permanecem seguros e serão restaurados no próximo login',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: GasometerDesignTokens.borderRadius(
                  GasometerDesignTokens.radiusButton,
                ),
              ),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _performLogoutWithProgressDialog(context, ref);
    }
  }

  Future<void> _performLogoutWithProgressDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LogoutProgressDialog(),
      ),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout realizado com sucesso'),
            backgroundColor: GasometerDesignTokens.colorSuccess,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao sair: ${DataSanitizationService.sanitizeForLogging(e.toString())}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
