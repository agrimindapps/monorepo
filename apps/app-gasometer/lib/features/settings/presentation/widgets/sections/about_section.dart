import 'package:flutter/material.dart';

import '../shared/settings_card.dart';
import '../shared/settings_item.dart';

/// Seção sobre - informações sobre o aplicativo
class AboutSection extends StatelessWidget {
  const AboutSection({
    this.onVersionTap,
    super.key,
  });

  final VoidCallback? onVersionTap;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: 'Sobre',
      icon: Icons.info,
      children: [
        SettingsItem(
          icon: Icons.info_outline,
          title: 'Versão do App',
          subtitle: '1.0.0',
          onTap: onVersionTap,
        ),
      ],
    );
  }
}
