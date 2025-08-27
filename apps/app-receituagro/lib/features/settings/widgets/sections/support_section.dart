import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/settings_design_tokens.dart';
import '../../presentation/providers/settings_provider.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';
import '../shared/settings_list_tile.dart';

/// Support and feedback section
/// Handles app rating and user feedback
class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Suporte',
          icon: Icons.support,
          showIcon: true,
        ),
        SettingsCard(
          child: Column(
            children: [
              SettingsListTile(
                leadingIcon: Icons.star_outline,
                title: 'Avaliar o App',
                subtitle: 'Avalie nossa experiência na loja',
                onTap: () => _showRateApp(context),
                showDivider: true,
              ),
              SettingsListTile(
                leadingIcon: Icons.feedback_outlined,
                iconColor: Theme.of(context).colorScheme.secondary,
                title: 'Enviar Feedback',
                subtitle: 'Nos ajude a melhorar o app',
                onTap: () => _showFeedback(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showRateApp(BuildContext context) async {
    final provider = context.read<SettingsProvider>();
    
    try {
      final success = await provider.showRateAppDialog(context);
      
      if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SettingsDesignTokens.getErrorSnackbar(
            'Não foi possível abrir a loja de aplicativos',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SettingsDesignTokens.getErrorSnackbar('Erro ao abrir avaliação do app'),
        );
      }
    }
  }

  void _showFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SettingsDesignTokens.getWarningSnackbar(
        'Sistema de feedback em desenvolvimento',
      ),
    );
  }
}