import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/settings_design_tokens.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';
import '../shared/settings_list_tile.dart';

/// Seção de Políticas e Termos Legais
/// Fornece acesso às políticas de privacidade, termos de uso e exclusão de conta
class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Políticas e Termos',
          icon: Icons.policy_outlined,
          showIcon: false,
        ),
        SettingsCard(
          child: Column(
            children: [
              SettingsListTile(
                leadingIcon: Icons.privacy_tip_outlined,
                title: 'Política de Privacidade',
                subtitle: 'Como tratamos seus dados pessoais',
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _openPrivacyPolicy(context),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              SettingsListTile(
                leadingIcon: Icons.description_outlined,
                title: 'Termos de Uso',
                subtitle: 'Condições de utilização do app',
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _openTermsOfUse(context),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              SettingsListTile(
                leadingIcon: Icons.delete_forever_outlined,
                title: 'Política de Exclusão de Conta',
                subtitle: 'Como seus dados são removidos',
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _openAccountDeletionPolicy(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Abre a Política de Privacidade
  Future<void> _openPrivacyPolicy(BuildContext context) async {
    const url = 'https://agrimindsolucoes.com/receituagro/privacy-policy';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          _showErrorDialog(
            context,
            'Política de Privacidade',
            'Não foi possível abrir o link.\n\nAcesse manualmente: $url',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Erro',
          'Erro ao abrir Política de Privacidade: $e',
        );
      }
    }
  }

  /// Abre os Termos de Uso
  Future<void> _openTermsOfUse(BuildContext context) async {
    const url = 'https://agrimindsolucoes.com/receituagro/terms-of-use';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          _showErrorDialog(
            context,
            'Termos de Uso',
            'Não foi possível abrir o link.\n\nAcesse manualmente: $url',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Erro',
          'Erro ao abrir Termos de Uso: $e',
        );
      }
    }
  }

  /// Abre a Política de Exclusão de Conta
  Future<void> _openAccountDeletionPolicy(BuildContext context) async {
    const url = 'https://agrimindsolucoes.com/receituagro/account-deletion-policy';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          _showErrorDialog(
            context,
            'Política de Exclusão',
            'Não foi possível abrir o link.\n\nAcesse manualmente: $url',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Erro',
          'Erro ao abrir Política de Exclusão: $e',
        );
      }
    }
  }

  /// Mostra dialog de erro amigável
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SettingsDesignTokens.cardBorderRadius),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
