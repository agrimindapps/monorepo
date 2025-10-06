import 'package:flutter/material.dart';
import '../../constants/settings_design_tokens.dart';

/// Diálogo de confirmação para logout
/// Mostra as consequências de sair da conta
class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: SettingsDesignTokens.errorBackgroundColor,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.logout,
                size: 32,
                color: SettingsDesignTokens.errorColor,
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Sair da Conta',
              style: SettingsDesignTokens.getSectionTitleStyle(
                context,
              ).copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ao sair da sua conta:',
                    style: SettingsDesignTokens.getListTitleStyle(context),
                  ),

                  const SizedBox(height: 12),
                  _buildInfoItem(
                    context,
                    icon: Icons.smartphone,
                    text: 'Todos os dados serão removidos deste dispositivo',
                    iconColor: theme.colorScheme.onSurfaceVariant,
                  ),

                  const SizedBox(height: 8),
                  _buildInfoItem(
                    context,
                    icon: Icons.link_off,
                    text: 'O dispositivo será desconectado da sua conta',
                    iconColor: theme.colorScheme.onSurfaceVariant,
                  ),

                  const SizedBox(height: 8),
                  _buildInfoItem(
                    context,
                    icon: Icons.login,
                    text: 'Você pode fazer login novamente a qualquer momento',
                    iconColor: SettingsDesignTokens.primaryColor,
                    textColor: SettingsDesignTokens.primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          SettingsDesignTokens.iconContainerRadius,
                        ),
                      ),
                      side: BorderSide(color: theme.colorScheme.outline),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SettingsDesignTokens.errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          SettingsDesignTokens.iconContainerRadius,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Sair',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Item de informação com ícone e texto
  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color iconColor,
    Color? textColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: SettingsDesignTokens.getListSubtitleStyle(context).copyWith(
              color: textColor ?? theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LogoutConfirmationDialog(),
    );
  }
}
