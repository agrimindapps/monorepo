import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../auth/presentation/notifiers/notifiers.dart';
import '../../../../auth/presentation/state/auth_state.dart';

/// Login and anonymous auth buttons for unauthenticated card.
class AccountLoginButtons extends ConsumerWidget {
  const AccountLoginButtons({
    super.key,
    required this.authState,
  });

  final AuthState authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(child: _buildLoginButton(context)),
        const SizedBox(width: 12),
        Expanded(child: _buildAnonymousButton(context, ref)),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: authState.isLoading
          ? null
          : () {
              HapticFeedback.lightImpact();
              context.go('/login');
            },
      icon: const Icon(Icons.login, size: 16),
      label: const Text('Fazer Login'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildAnonymousButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: authState.isLoading
          ? null
          : () => _handleAnonymousLogin(context, ref),
      icon: authState.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.visibility_off, size: 16),
      label: Text(authState.isLoading ? 'Entrando...' : 'Modo Anônimo'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Future<void> _handleAnonymousLogin(
      BuildContext context, WidgetRef ref) async {
    await HapticFeedback.lightImpact();
    await ref.read(authProvider.notifier).loginAnonymously();
    final currentAuthState = ref.read(authProvider);
    if (context.mounted) {
      final message =
          currentAuthState.errorMessage ?? 'Login anônimo realizado com sucesso';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
