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
          child: SettingsListTile(
            leadingIcon: Icons.star_outline,
            title: 'Avaliar o App',
            subtitle: 'Avalie nossa experiência na loja',
            onTap: () => _showRateApp(context),
          ),
        ),
        const SizedBox(height: 12),
        SettingsCard(
          child: SettingsListTile(
            leadingIcon: Icons.feedback_outlined,
            title: 'Enviar Feedback',
            subtitle: 'Nos ajude a melhorar o app',
            onTap: () => _showFeedback(context),
          ),
        ),
        const SizedBox(height: 12),
        SettingsCard(
          child: SettingsListTile(
            leadingIcon: Icons.info_outline,
            title: 'Sobre o Aplicativo',
            subtitle: 'Versão, suporte e informações',
            onTap: () => _showAboutApp(context),
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

  void _showAboutApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sobre o app - Em desenvolvimento'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}