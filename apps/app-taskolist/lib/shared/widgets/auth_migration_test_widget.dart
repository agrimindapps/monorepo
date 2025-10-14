import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers_new.dart';

/// Widget de teste para validar migração Auth
/// Compara providers antigos vs novos
class AuthMigrationTestWidget extends ConsumerWidget {
  const AuthMigrationTestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isAuth = ref.watch(isAuthenticatedProvider);
    final currentUser = ref.watch(currentAuthenticatedUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Auth Migration Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔍 Testing NEW auth providers (code generation)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            _buildInfoRow('Auth State:', authState.toString()),
            const SizedBox(height: 8),
            _buildInfoRow('Is Authenticated:', isAuth.toString()),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Current User Email:',
              currentUser?.email ?? 'null',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Current User ID:',
              currentUser?.id ?? 'null',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            _buildStatusCard(authState),
            const SizedBox(height: 20),
            _buildActionButtons(ref, authState),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(AsyncValue<dynamic> authState) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            authState.when(
              data: (user) => user != null
                  ? Text(
                      '✅ Authenticated as ${user.email ?? "Anonymous"}',
                      style: const TextStyle(color: Colors.green),
                    )
                  : const Text(
                      '❌ Not authenticated',
                      style: TextStyle(color: Colors.orange),
                    ),
              loading: () => const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Loading...'),
                ],
              ),
              error: (error, stack) => Text(
                '❌ Error: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(WidgetRef ref, AsyncValue<dynamic> authState) {
    final isLoading = authState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: isLoading
              ? null
              : () async {
                  try {
                    await ref
                        .read(authNotifierProvider.notifier)
                        .signInAnonymously();

                    if (!ref.context.mounted) return;

                    ScaffoldMessenger.of(ref.context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Anonymous sign in successful'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!ref.context.mounted) return;

                    ScaffoldMessenger.of(ref.context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
          icon: const Icon(Icons.person_outline),
          label: const Text('Test Anonymous Sign In'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isLoading || authState.value == null
              ? null
              : () async {
                  try {
                    await ref.read(authNotifierProvider.notifier).signOut();

                    if (!ref.context.mounted) return;

                    ScaffoldMessenger.of(ref.context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Sign out successful'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  } catch (e) {
                    if (!ref.context.mounted) return;

                    ScaffoldMessenger.of(ref.context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
          icon: const Icon(Icons.logout),
          label: const Text('Test Sign Out'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            ref.invalidate(authNotifierProvider);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Invalidate Provider'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
