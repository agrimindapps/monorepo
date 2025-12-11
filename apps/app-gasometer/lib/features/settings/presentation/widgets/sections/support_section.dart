import 'package:flutter/material.dart';

import '../shared/new_settings_card.dart';
import '../shared/new_settings_list_tile.dart';
import '../shared/section_header.dart';

/// Seção de suporte - acesso a ajuda, feedback e avaliação
class SupportSection extends StatelessWidget {
  const SupportSection({
    this.onHelpTap,
    this.onFeedbackTap,
    this.onRateTap,
    super.key,
  });

  final VoidCallback? onHelpTap;
  final VoidCallback? onFeedbackTap;
  final VoidCallback? onRateTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'Suporte'),
        NewSettingsCard(
          child: Column(
            children: [
              NewSettingsListTile(
                leadingIcon: Icons.help_outline,
                title: 'Central de Ajuda',
                subtitle: 'Perguntas frequentes',
                onTap: onHelpTap,
                showDivider: true,
              ),
              NewSettingsListTile(
                leadingIcon: Icons.feedback,
                title: 'Enviar Feedback',
                subtitle: 'Ajude-nos a melhorar o app',
                onTap: onFeedbackTap,
                showDivider: true,
              ),
              NewSettingsListTile(
                leadingIcon: Icons.star_rate,
                title: 'Avaliar o App',
                subtitle: 'Deixe sua avaliação',
                onTap: onRateTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
