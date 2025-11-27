import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/design_tokens.dart';
import '../../../../auth/presentation/notifiers/notifiers.dart';
import '../../../../auth/presentation/state/auth_state.dart';
import 'account_login_buttons.dart';

/// Card shown when user is not authenticated.
class AccountUnauthenticatedCard extends ConsumerWidget {
  const AccountUnauthenticatedCard({
    super.key,
    required this.authState,
  });

  final AuthState authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusDialog,
        ),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAvatar(context),
            const SizedBox(height: 16),
            _buildTitle(context),
            const SizedBox(height: 8),
            _buildDescription(context),
            const SizedBox(height: 20),
            if (authState.errorMessage != null) ...[
              _buildErrorMessage(context, ref),
            ],
            AccountLoginButtons(authState: authState),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: GasometerDesignTokens.iconSizeXxl,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Faça login em sua conta',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      'Acesse recursos avançados, sincronize seus\ndados e mantenha suas informações seguras',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              authState.errorMessage!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).clearError(),
            icon: const Icon(Icons.close, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}