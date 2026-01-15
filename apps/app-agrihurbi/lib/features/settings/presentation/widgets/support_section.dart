import 'package:flutter/material.dart';

import 'settings_section.dart';
import 'settings_tile.dart';

/// Seção de suporte - acesso a ajuda, feedback e avaliação
///
/// Portado do app-gasometer e adaptado para AgrihurbI
class SupportSection extends StatelessWidget {
  const SupportSection({
    this.onFeedbackTap,
    this.onRateTap,
    this.onContactTap,
    super.key,
  });

  final VoidCallback? onFeedbackTap;
  final VoidCallback? onRateTap;
  final VoidCallback? onContactTap;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Suporte',
      icon: Icons.support_agent,
      children: [
        SettingsTile.navigation(
          title: 'Avaliar o App',
          subtitle: 'Deixe sua avaliação na loja',
          leading: const Icon(Icons.star_rate, color: Colors.amber),
          onTap: onRateTap,
        ),
        SettingsTile.navigation(
          title: 'Enviar Feedback',
          subtitle: 'Ajude-nos a melhorar o app',
          leading: const Icon(Icons.feedback, color: Colors.blue),
          onTap: onFeedbackTap,
        ),
        if (onContactTap != null)
          SettingsTile.navigation(
            title: 'Fale Conosco',
            subtitle: 'Entre em contato com o suporte',
            leading: const Icon(Icons.email, color: Colors.green),
            onTap: onContactTap,
          ),
      ],
    );
  }
}
