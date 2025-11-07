import 'package:flutter/material.dart';

import '../../../../core/theme/design_tokens.dart';
import 'profile_info_row.dart';
import 'profile_section_card.dart';

/// Widget para seção de informações da conta
class ProfileAccountInfoSection extends StatelessWidget {
  final dynamic user;
  final bool isPremium;

  const ProfileAccountInfoSection({
    super.key,
    required this.user,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Informações da Conta',
      icon: Icons.info,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusDialog,
            ),
          ),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileInfoRow(
                  label: 'Tipo',
                  value: isPremium ? 'Premium' : 'Gratuita',
                ),
                if (user?.createdAt != null)
                  ProfileInfoRow(
                    label: 'Criada em',
                    value: _formatDate(user!.createdAt as DateTime),
                  ),
                if (user?.lastSignInAt != null)
                  ProfileInfoRow(
                    label: 'Último acesso',
                    value: _formatDate(user!.lastSignInAt as DateTime),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
