import 'package:flutter/material.dart';

import '../../../../core/services/data_sanitization_service.dart';
import '../../../../core/theme/design_tokens.dart';

/// Widget para exibir informações do perfil do usuário autenticado
class AuthenticatedUserSection extends StatelessWidget {
  final dynamic user;
  final bool isPremium;

  const AuthenticatedUserSection({
    super.key,
    required this.user,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProfileInfoRow(
          context,
          'Nome',
          DataSanitizationService.sanitizeDisplayName(user, false),
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildProfileInfoRow(
          context,
          'Email',
          DataSanitizationService.sanitizeEmail(user, false),
          icon: Icons.email,
        ),
        const SizedBox(height: 24),
        if (isPremium) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GasometerDesignTokens.getPremiumBackgroundWithOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GasometerDesignTokens.colorPremiumAccent,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.star,
                  color: GasometerDesignTokens.colorPremiumAccent,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Conta Premium',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GasometerDesignTokens.colorPremiumAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aproveite todos os recursos avançados',
                  style: TextStyle(
                    fontSize: 14,
                    color: GasometerDesignTokens.colorPremiumAccent.withValues(
                      alpha: 0.8,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileInfoRow(
    BuildContext context,
    String label,
    String value, {
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
