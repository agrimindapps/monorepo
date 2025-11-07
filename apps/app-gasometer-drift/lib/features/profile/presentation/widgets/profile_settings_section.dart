import 'package:core/core.dart' show GoRouterHelper;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/design_tokens.dart';
import 'profile_section_card.dart';
import 'profile_settings_item.dart';

/// Widget para seção de configurações e privacidade
class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Configurações e Privacidade',
      icon: Icons.settings,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusDialog,
            ),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Column(
            children: [
              ProfileSettingsItem(
                icon: Icons.privacy_tip,
                title: 'Política de Privacidade',
                subtitle: 'Como tratamos seus dados',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/privacy');
                },
                isFirst: true,
              ),
              ProfileSettingsItem(
                icon: Icons.description,
                title: 'Termos de Uso',
                subtitle: 'Condições de uso do aplicativo',
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.go('/terms');
                },
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
