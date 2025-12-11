import 'package:flutter/material.dart';

import '../shared/new_settings_card.dart';
import '../shared/new_settings_list_tile.dart';
import '../shared/section_header.dart';

/// Seção de aplicativo - configurações gerais do app
class AppSection extends StatelessWidget {
  const AppSection({
    this.onThemeTap,
    super.key,
  });

  final VoidCallback? onThemeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'Aplicativo'),
        NewSettingsCard(
          child: NewSettingsListTile(
            leadingIcon: Icons.palette,
            title: 'Tema',
            subtitle: 'Escolher aparência do aplicativo',
            onTap: onThemeTap,
          ),
        ),
      ],
    );
  }
}
