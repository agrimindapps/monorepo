import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/section_header_widget.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/delete_account_dialog.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProfileDialog(context, ref),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('Nenhum perfil encontrado'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileHeaderWidget(profile: profile),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              ProfileInfoSection(profile: profile),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const SectionHeaderWidget(title: 'Ações'),
              _buildActionTile(
                context,
                icon: Icons.refresh_outlined,
                label: 'Atualizar Perfil',
                onTap: () => ref.read(userProfileProvider.notifier).reload(),
              ),
              _buildActionTile(
                context,
                icon: Icons.delete_outline,
                label: 'Excluir Conta',
                color: Theme.of(context).colorScheme.error,
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Erro ao carregar perfil: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(userProfileProvider.notifier).reload(),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: TextStyle(color: color),
      ),
      trailing: Icon(Icons.chevron_right, color: color),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;

    if (profile == null) return;

    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(profile: profile),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );
  }
}
