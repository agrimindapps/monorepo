import 'package:flutter/material.dart';

import '../shared/new_settings_card.dart';
import '../shared/new_settings_list_tile.dart';
import '../shared/section_header.dart';

/// Seção sobre - informações sobre o aplicativo
class AboutSection extends StatelessWidget {
  const AboutSection({
    this.onVersionTap,
    super.key,
  });

  final VoidCallback? onVersionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'Sobre'),
        NewSettingsCard(
          child: NewSettingsListTile(
            leadingIcon: Icons.info_outline,
            title: 'Versão do App',
            subtitle: '1.0.0',
            onTap: onVersionTap,
          ),
        ),
      ],
    );
  }
}
