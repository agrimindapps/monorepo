import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/subscription_providers.dart';
import '../../../shared/widgets/delete_account_confirmation_dialog.dart';
import '../../premium/presentation/premium_page.dart';
import 'widgets/account_info_section.dart';
import 'widgets/data_sync_section.dart';
import 'widgets/device_management_section.dart';
import 'widgets/profile_header.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final subscriptionState = ref.watch(
      subscriptionStatusProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Conta'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: authState.when(
        data: (user) => user != null
            ? _buildAccountContent(context, user, subscriptionState)
            : _buildNotLoggedInContent(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Erro ao carregar conta: $error')),
      ),
    );
  }

  Widget _buildAccountContent(
    BuildContext context,
    UserEntity user,
    AsyncValue<SubscriptionStatus> subscriptionState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(user: user),
          const SizedBox(height: 24),
          _buildSubscriptionSection(subscriptionState),
          const SizedBox(height: 24),
          const AccountInfoSection(),
          const SizedBox(height: 24),
          const DeviceManagementSection(),
          const SizedBox(height: 24),
          const DataSyncSection(),
          const SizedBox(height: 24),
          _buildAccountSection(user),
          const SizedBox(height: 24),
          _buildAccountActions(user),
        ],
      ),
    );
  }

  Widget _buildUserHeader(UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryColor.withAlpha(26),
              backgroundImage:
                  user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primaryColor,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName.isNotEmpty ? user.displayName : 'Usuário',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email.isNotEmpty ? user.email : 'Nenhum email',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (user.isEmailVerified)
                        _buildStatusChip(
                          'Email verificado',
                          AppColors.success,
                          Icons.verified,
                        )
                      else
                        _buildStatusChip(
                          'Email não verificado',
                          AppColors.warning,
                          Icons.warning,
                        ),
                      if (user.provider == AuthProvider.anonymous)
                        _buildStatusChip(
                          'Conta temporária',
                          AppColors.info,
                          Icons.person_outline,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showEditProfileDialog(user),
              icon: const Icon(Icons.edit),
              tooltip: 'Editar perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color.withAlpha(26),
      side: BorderSide(color: color.withAlpha(77)),
    );
  }

  Widget _buildSubscriptionSection(
    AsyncValue<SubscriptionStatus> subscriptionState,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.warning),
                const SizedBox(width: 8),
                const Text(
                  'Plano atual',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<dynamic>(
                        builder: (context) => const PremiumPage(),
                      ),
                    );
                  },
                  child: const Text('Ver planos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            subscriptionState.when(
              data: (status) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status == SubscriptionStatus.active ? 'Premium' : 'Gratuito',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: status == SubscriptionStatus.active
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (status != SubscriptionStatus.active) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Limite: 50 tarefas, 10 subtarefas por tarefa',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              loading: () => const Text('Carregando...'),
              error: (error, stack) => const Text('Erro ao carregar plano'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(UserEntity user) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Informações da conta'),
            subtitle: const Text('Nome, email e configurações pessoais'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEditProfileDialog(user),
          ),
          if (!user.isEmailVerified &&
              user.provider != AuthProvider.anonymous) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.warning),
              title: const Text('Verificar email'),
              subtitle: const Text('Confirme seu endereço de email'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _sendEmailVerification(),
            ),
          ],
          if (user.provider == AuthProvider.anonymous) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.upgrade, color: AppColors.info),
              title: const Text('Criar conta permanente'),
              subtitle: const Text('Salve seus dados com email e senha'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showUpgradeAccountDialog(),
            ),
          ],
        ],
      ),
    );
  }



  Widget _buildAccountActions(UserEntity user) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.warning),
            title: const Text('Sair'),
            onTap: () => _showLogoutDialog(),
          ),
          if (user.provider != AuthProvider.anonymous) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text('Excluir conta'),
              onTap: () => _showDeleteAccountDialog(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotLoggedInContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Você não está logado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Faça login para acessar sua conta',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(UserEntity user) {
    _displayNameController.text = user.displayName;

    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Nome de exibição',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Outras funcionalidades de edição serão implementadas em breve.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateProfile();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final authState = ref.read(authProvider);

    authState.when(
      data: (user) async {
        if (user == null) return;

        await showDeleteAccountConfirmation(
          context: context,
          userEmail: user.email,
          onConfirmed: () async {
            _deleteAccount();
          },
        );
      },
      loading: () {},
      error: (error, stackTrace) {},
    );
  }

  void _updateProfile() async {
    final authService = await ref.read(taskManagerAuthServiceProvider.future);
    final newName = _displayNameController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome não pode estar vazio'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('Atualizando perfil...'),
          ],
        ),
        duration: Duration(seconds: 10),
        backgroundColor: AppColors.info,
      ),
    );

    final result = await authService.updateProfile(displayName: newName);
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar perfil: ${failure.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      );
    }
  }

  void _sendEmailVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verificação de email será implementada em breve'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showUpgradeAccountDialog() {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar conta permanente'),
        content: const Text(
          'Para manter seus dados seguros, crie uma conta com email e senha.\n\nEsta funcionalidade será implementada em breve.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() async {
    final authService = await ref.read(taskManagerAuthServiceProvider.future);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Text('Excluindo conta...'),
          ],
        ),
        duration: Duration(seconds: 30),
        backgroundColor: AppColors.error,
      ),
    );

    final result = await authService.deleteAccount();
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir conta: ${failure.message}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta excluída permanentemente'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }
  }



}
