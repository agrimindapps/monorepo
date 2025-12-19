import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/config/app_constants.dart';
import '../../dialogs/dialogs.dart';
import '../settings_item.dart';
import '../settings_section.dart';

/// Legal settings section (privacy, terms, about)
class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Sobre',
      children: [
        SettingsItem(
          icon: Icons.info,
          title: 'Informações do App',
          subtitle: 'Versão, suporte e feedback',
          onTap: () => AboutAppDialog.show(context),
        ),
        SettingsItem(
          icon: Icons.privacy_tip,
          title: 'Política de Privacidade',
          subtitle: 'Como protegemos seus dados',
          onTap: () => context.push(AppConstants.privacyPolicyRoute),
        ),
        SettingsItem(
          icon: Icons.description,
          title: 'Termos de Uso',
          subtitle: 'Termos e condições de uso',
          onTap: () => context.push(AppConstants.termsOfServiceRoute),
        ),
        SettingsItem(
          icon: Icons.delete_outline,
          title: 'Política de Exclusão de Conta',
          subtitle: 'Como seus dados são removidos',
          onTap: () => context.push(AppConstants.accountDeletionPolicyRoute),
        ),
      ],
    );
  }
}
