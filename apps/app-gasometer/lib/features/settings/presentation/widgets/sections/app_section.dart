import 'package:flutter/material.dart';

import '../shared/settings_card.dart';
import '../shared/settings_item.dart';

/// Seção de aplicativo - configurações gerais do app
class AppSection extends StatelessWidget {
  const AppSection({
    this.onThemeTap,
    this.onLanguageTap,
    this.onStorageTap,
    super.key,
  });

  final VoidCallback? onThemeTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onStorageTap;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: 'Aplicativo',
      icon: Icons.apps,
      children: [
        SettingsItem(
          icon: Icons.palette,
          title: 'Tema',
          subtitle: 'Escolher aparência do aplicativo',
          onTap: onThemeTap,
        ),
        SettingsItem(
          icon: Icons.language,
          title: 'Idioma',
          subtitle: 'Português (Brasil)',
          onTap: onLanguageTap,
        ),
        SettingsItem(
          icon: Icons.storage,
          title: 'Armazenamento',
          subtitle: 'Gerenciar dados locais',
          onTap: onStorageTap,
        ),
      ],
    );
  }
}
