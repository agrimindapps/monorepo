import 'package:core/core.dart' show GoRouterHelper;
import 'package:flutter/material.dart';

import '../shared/new_settings_card.dart';
import '../shared/new_settings_list_tile.dart';
import '../shared/section_header.dart';

/// Seção dedicada para políticas e termos legais
/// Exibe links para: Política de Privacidade, Termos de Uso, Política de Exclusão
class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'Políticas e Termos'),
        NewSettingsCard(
          child: Column(
            children: [
              NewSettingsListTile(
                leadingIcon: Icons.privacy_tip_outlined,
                title: 'Política de Privacidade',
                subtitle: 'Como tratamos seus dados',
                onTap: () => context.push('/privacy-policy'),
                showDivider: true,
              ),
              NewSettingsListTile(
                leadingIcon: Icons.description_outlined,
                title: 'Termos de Uso',
                subtitle: 'Condições de utilização do app',
                onTap: () => context.push('/terms-of-service'),
                showDivider: true,
              ),
              NewSettingsListTile(
                leadingIcon: Icons.delete_forever_outlined,
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
