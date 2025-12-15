import 'package:core/core.dart' hide Column, AuthStatus, User;
import 'package:flutter/material.dart';

import '../../../../auth/domain/entities/user.dart' as local;
import '../../../../auth/presentation/providers/auth_provider.dart'
    show authProvider, AuthStatus;
import '../shared/new_settings_card.dart';
import '../shared/section_header.dart';

/// Seção de perfil do usuário - exibe informações do usuário logado
class ProfileUserSection extends ConsumerWidget {
  const ProfileUserSection({this.onLoginTap, super.key});

  final VoidCallback? onLoginTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final local.User? user = authState.user;
    final isLoggedIn =
        authState.status == AuthStatus.authenticated && user != null;

    return Column(
      children: [
        const SectionHeader(title: 'Conta'),
        NewSettingsCard(
          child: InkWell(
            onTap: isLoggedIn ? () => context.push('/profile') : onLoginTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildAvatar(context, user, isLoggedIn),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn ? user.displayName : 'Fazer Login',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLoggedIn
                              ? user.email
                              : 'Entre para sincronizar seus dados',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, local.User? user, bool isLoggedIn) {
    if (isLoggedIn && user?.photoUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(user!.photoUrl!),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(
        isLoggedIn ? Icons.person : Icons.login,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
