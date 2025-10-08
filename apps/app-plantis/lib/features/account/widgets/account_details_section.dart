import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart' as local;
import '../../../shared/widgets/base_page_scaffold.dart';
import '../utils/widget_utils.dart';

class AccountDetailsSection extends ConsumerWidget {
  const AccountDetailsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(local.authProvider);

    return authStateAsync.when(
      data: (authState) {
        final user = authState.currentUser;

        if (user == null || authState.isAnonymous) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader(context, 'Informações da Conta'),
            const SizedBox(height: 16),
            PlantisCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  buildInfoRow(
                    context,
                    'Tipo de Conta',
                    authState.isPremium ? 'Premium' : 'Gratuita',
                  ),
                  if (user.createdAt != null) ...[
                    const SizedBox(height: 12),
                    buildInfoRow(
                      context,
                      'Criada em',
                      formatDate(user.createdAt),
                    ),
                  ],
                  if (user.lastLoginAt != null) ...[
                    const SizedBox(height: 12),
                    buildInfoRow(
                      context,
                      'Último acesso',
                      formatDate(user.lastLoginAt),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
