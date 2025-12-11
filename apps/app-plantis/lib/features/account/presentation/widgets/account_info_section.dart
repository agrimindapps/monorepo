import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_providers.dart' as local;
import '../../../../core/services/data_sanitization_service.dart';
import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/base_page_scaffold.dart';

class AccountInfoSection extends ConsumerWidget {
  const AccountInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(local.authProvider);
    final theme = Theme.of(context);

    return authStateAsync.when(
      data: (authState) {
        final user = authState.currentUser;
        final isAnonymous = authState.isAnonymous;

        if (user == null) {
          return const SizedBox.shrink();
        }

        final displayName = DataSanitizationService.sanitizeDisplayName(
          user,
          isAnonymous,
        );
        final email = DataSanitizationService.sanitizeEmail(user, isAnonymous);

        return PlantisCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar e informações básicas
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: PlantisColors.primary,
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status da conta
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isAnonymous
                      ? PlantisColors.warning.withValues(alpha: 0.1)
                      : PlantisColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAnonymous
                        ? PlantisColors.warning
                        : PlantisColors.success,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAnonymous ? Icons.warning : Icons.verified,
                      size: 16,
                      color: isAnonymous
                          ? PlantisColors.warning
                          : PlantisColors.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAnonymous ? 'Conta Temporária' : 'Conta Verificada',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isAnonymous
                            ? PlantisColors.warning
                            : PlantisColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              if (user.isAnonymous) ...[
                const SizedBox(height: 12),
                Text(
                  'Para acessar todos os recursos, faça login com sua conta Google.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
      loading: () =>
          const PlantisCard(child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => PlantisCard(
        child: Center(
          child: Text(
            'Erro ao carregar informações da conta',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
