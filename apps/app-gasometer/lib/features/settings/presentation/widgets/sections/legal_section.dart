import 'package:core/core.dart' show GoRouterHelper;
import 'package:flutter/material.dart';

import '../shared/settings_card.dart';
import '../shared/settings_item.dart';

/// Seção dedicada para políticas e termos legais
/// Exibe links para: Política de Privacidade, Termos de Uso, Política de Exclusão
class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: 'Políticas e Termos',
      icon: Icons.privacy_tip,
      children: [
        SettingsItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Política de Privacidade',
          subtitle: 'Como tratamos seus dados',
          onTap: () => context.push('/privacy-policy'),
        ),
        SettingsItem(
          icon: Icons.description_outlined,
          title: 'Termos de Uso',
          subtitle: 'Condições de utilização do app',
          onTap: () => context.push('/terms-of-service'),
        ),
        SettingsItem(
          icon: Icons.delete_forever_outlined,
          title: 'Política de Exclusão de Conta',
          subtitle: 'Como seus dados são removidos',
          onTap: () => context.push('/account-deletion-policy'),
        ),
      ],
    );
  }
}
