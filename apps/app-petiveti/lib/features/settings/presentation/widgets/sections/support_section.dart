import 'package:flutter/material.dart';

import '../shared/new_settings_card.dart';
import '../shared/new_settings_list_tile.dart';
import '../shared/section_header.dart';

/// Seção de suporte - acesso a ajuda, feedback e avaliação
class SupportSection extends StatelessWidget {
  const SupportSection({
    this.onFeedbackTap,
    this.onRateTap,
    this.onHelpTap,
    this.onContactTap,
    super.key,
  });

  final VoidCallback? onFeedbackTap;
  final VoidCallback? onRateTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onContactTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'Suporte'),
        NewSettingsCard(
          child: Column(
            children: [
              NewSettingsListTile(
                leadingIcon: Icons.star_rate,
                title: 'Avaliar o App',
                subtitle: 'Deixe sua avaliação na loja',
                onTap: onRateTap,
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
                leadingIcon: Icons.help_outline,
                title: 'Central de Ajuda',
                subtitle: 'Perguntas frequentes e tutoriais',
                onTap: onHelpTap,
                showDivider: true,
              ),
              NewSettingsListTile(
                leadingIcon: Icons.support_agent,
                title: 'Fale Conosco',
                subtitle: 'Entre em contato com o suporte',
                onTap: onContactTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
