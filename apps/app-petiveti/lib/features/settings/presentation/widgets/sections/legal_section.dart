import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../shared/new_settings_card.dart';
import '../shared/new_settings_list_tile.dart';
import '../shared/section_header.dart';

/// Seção legal - políticas de privacidade, termos de uso, etc
class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'Legal'),
        NewSettingsCard(
          child: Column(
            children: [
              NewSettingsListTile(
                leadingIcon: Icons.privacy_tip,
                title: 'Política de Privacidade',
                subtitle: 'Como protegemos seus dados',
                onTap: () => context.push('/privacy-policy'),
                showDivider: true,
              ),
              NewSettingsListTile(
                leadingIcon: Icons.description,
                title: 'Termos de Uso',
                subtitle: 'Termos e condições de uso',
                onTap: () => context.push('/terms-of-service'),
                showDivider: true,
              ),
              NewSettingsListTile(
                leadingIcon: Icons.delete_forever,
                title: 'Política de Exclusão de Conta',
                subtitle: 'Como seus dados são removidos',
                onTap: () => context.push('/account-deletion-policy'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
