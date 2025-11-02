import 'package:flutter/material.dart';

import '../shared/settings_card.dart';
import '../shared/settings_item.dart';

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
    return SettingsCard(
      title: 'Suporte',
      icon: Icons.help,
      children: [
        SettingsItem(
          icon: Icons.help_outline,
          title: 'Central de Ajuda',
          subtitle: 'Perguntas frequentes',
          onTap: onHelpTap,
        ),
        SettingsItem(
          icon: Icons.feedback,
          title: 'Enviar Feedback',
          subtitle: 'Ajude-nos a melhorar o app',
          onTap: onFeedbackTap,
        ),
        SettingsItem(
          icon: Icons.star_rate,
          title: 'Avaliar o App',
          subtitle: 'Deixe sua avaliação',
          onTap: onRateTap,
        ),
      ],
    );
  }
}
