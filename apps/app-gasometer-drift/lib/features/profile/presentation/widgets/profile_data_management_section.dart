import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/design_tokens.dart';
import 'profile_dialogs.dart';
import 'profile_section_card.dart';
import 'profile_settings_item.dart';

/// Widget para seção de gerenciamento de dados
class ProfileDataManagementSection extends StatelessWidget {
  const ProfileDataManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Gerenciamento de Dados',
      icon: Icons.cleaning_services,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusDialog,
            ),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: ProfileSettingsItem(
            icon: Icons.delete_sweep,
            title: 'Limpar Dados',
            subtitle: 'Limpar veículos, abastecimentos e manutenções',
            onTap: () {
              HapticFeedback.lightImpact();
              _showClearDataDialog(context);
            },
            isFirst: true,
            isLast: true,
            isDestructive: true,
          ),
        ),
      ],
    );
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const DataClearDialog(),
    );
  }
}
