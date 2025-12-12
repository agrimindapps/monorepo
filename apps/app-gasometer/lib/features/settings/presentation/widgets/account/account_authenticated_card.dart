import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/design_tokens.dart';
import '../../../../../core/widgets/user_avatar_widget.dart';
import '../../../../auth/domain/entities/user_entity.dart' as gasometer_entities;

/// Card shown when user is authenticated.
class AccountAuthenticatedCard extends StatelessWidget {
  const AccountAuthenticatedCard({
    super.key,
    required this.user,
    required this.isAnonymous,
    required this.isPremium,
  });

  final gasometer_entities.UserEntity? user;
  final bool isAnonymous;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final displayName =
        isAnonymous ? 'Usuário Anônimo' : (user?.displayName ?? 'Usuário');
    final displayEmail = isAnonymous
        ? 'Dados salvos localmente'
        : (user?.email ?? 'Email não disponível');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusDialog,
        ),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.go('/profile');
          },
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusDialog,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                UserAvatarLarge(
                  user: user,
                  size: 80,
                  showEditIcon: true,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      if (isPremium) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: GasometerDesignTokens.colorPremiumAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
