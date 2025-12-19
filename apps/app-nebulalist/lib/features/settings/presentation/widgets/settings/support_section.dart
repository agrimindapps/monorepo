import 'package:flutter/material.dart';

import '../../dialogs/dialogs.dart';
import '../settings_item.dart';
import '../settings_section.dart';

/// Support settings section (rate app, feedback)
class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Suporte',
      children: [
        SettingsItem(
          icon: Icons.star_rate,
          title: 'Avaliar o App',
          subtitle: 'Avalie nossa experiência na loja',
          onTap: () => _showRateAppDialog(context),
        ),
        SettingsItem(
          icon: Icons.feedback,
          title: 'Enviar Feedback',
          subtitle: 'Nos ajude a melhorar o app',
          onTap: () => _showFeedbackDialog(context),
        ),
      ],
    );
  }

  Future<void> _showRateAppDialog(BuildContext context) async {
    final confirmed = await RateAppDialog.show(context);
    if (confirmed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Obrigado pelo interesse! (em desenvolvimento)'),
        ),
      );
    }
  }

  Future<void> _showFeedbackDialog(BuildContext context) async {
    final confirmed = await FeedbackDialog.show(context);
    if (confirmed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Em desenvolvimento'),
        ),
      );
    }
  }
}
