import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/settings/settings_widgets.dart';

/// Settings page with user info and configuration options
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Section
          if (user != null) ...[
            SettingsUserCard(user: user),
            const SizedBox(height: 16),
          ],

          // Premium Card Section
          const SettingsPremiumCard(),
          const SizedBox(height: 24),

          // App Section
          const AppSettingsSection(),
          const SizedBox(height: 16),

          // Support Section
          const SupportSection(),
          const SizedBox(height: 16),

          // About Section
          const LegalSection(),
          const SizedBox(height: 24),

          // Danger Zone
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sair da Conta',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _showLogoutConfirmation(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppConstants.loginRoute);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
