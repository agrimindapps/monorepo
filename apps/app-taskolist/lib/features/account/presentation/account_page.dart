import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/providers/subscription_providers.dart';
import '../../../shared/widgets/delete_account_confirmation_dialog.dart';
import '../../notifications/presentation/notification_settings_page.dart';
import '../../premium/presentation/premium_page.dart';
import '../../premium/presentation/subscription_status.dart' as local_sub;

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
    final authState = ref.watch(authNotifierProvider);
    final subscriptionState = ref.watch(
      Subscription.subscriptionStatusProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Conta'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: authState.when(
        data:
            (user) =>
                user != null
                    ? _buildAccountContent(context, user, subscriptionState)
                    : _buildNotLoggedInContent(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text('Erro ao carregar conta: $error')),
      ),
    );
  }

  Widget _buildAccountContent(
    BuildContext context,
    UserEntity user,
    AsyncValue<local_sub.SubscriptionStatus> subscriptionState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do usuário
          _buildUserHeader(user),
          const SizedBox(height: 24),

          // Status da assinatura
          _buildSubscriptionSection(subscriptionState),
          const SizedBox(height: 24),

          // Configurações da conta
          _buildAccountSection(user),
          const SizedBox(height: 24),

          // Configurações do app
          _buildAppSection(),
          const SizedBox(height: 24),

          // Seção de dados
          _buildDataSection(),
          const SizedBox(height: 24),

          // Ações da conta
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
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryColor.withAlpha(26),
              backgroundImage:
                  user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child:
                  user.photoUrl == null
                      ? const Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primaryColor,
                      )
                      : null,
            ),
            const SizedBox(width: 16),

            // Informações do usuário
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

                  // Status badges
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

            // Botão editar perfil
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
    AsyncValue<local_sub.SubscriptionStatus> subscriptionState,
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
              data:
                  (status) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.isActive ? 'Premium' : 'Gratuito',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              status.isActive
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                        ),
                      ),
                      if (status.isActive && status.expirationDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Válido até ${_formatDate(status.expirationDate!)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (!status.isActive) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Limite: 50 tarefas, 10 subtarefas por tarefa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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

  Widget _buildAppSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificações'),
            subtitle: const Text('Lembretes, alertas e configurações'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<dynamic>(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
          ),

          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Tema'),
            subtitle: const Text('Aparência do aplicativo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(),
          ),

          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: const Text('Português (Brasil)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup dos dados'),
            subtitle: const Text('Salvar dados na nuvem'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBackupDialog(),
          ),

          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Exportar dados'),
            subtitle: const Text('Baixar suas tarefas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExportDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(UserEntity user) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help, color: AppColors.info),
            title: const Text('Ajuda e suporte'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHelpDialog(),
          ),

          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: AppColors.info),
            title: const Text('Privacidade'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyDialog(),
          ),

          const Divider(height: 1),
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

  // Dialog methods
  void _showEditProfileDialog(UserEntity user) {
    _displayNameController.text = user.displayName;

    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
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
      builder:
          (context) => AlertDialog(
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
                  await ref.read(authNotifierProvider.notifier).signOut();
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
    final authState = ref.read(authNotifierProvider);

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

  // Action methods
  void _updateProfile() async {
    final authService = ref.read(taskManagerAuthServiceProvider);
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

    // Mostrar loading
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

    // Remover loading snackbar
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
    // TODO: Implementar verificação de email
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
      builder:
          (context) => AlertDialog(
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
    final authService = ref.read(taskManagerAuthServiceProvider);

    // Mostrar loading
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

    // Remover loading snackbar
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
          // Conta excluída com sucesso - usuário já foi deslogado
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta excluída permanentemente'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );

          // Voltar para a tela de login (o auth guard deve redirecionar automaticamente)
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }
  }

  void _showThemeDialog() {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tema'),
            content: const Text(
              'Configurações de tema serão implementadas em breve',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showLanguageDialog() {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Idioma'),
            content: const Text(
              'Suporte a múltiplos idiomas será implementado em breve',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showBackupDialog() {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Backup'),
            content: const Text(
              'Sincronização com a nuvem será implementada em breve',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showExportDialog() {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Exportar dados'),
            content: const Text(
              'Exportação de dados será implementada em breve',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog() {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajuda'),
            content: const Text(
              'Task Manager - Gerenciador de Tarefas\n\n'
              'Para suporte, entre em contato:\n'
              '• Email: suporte@taskmanager.com\n'
              '• Website: www.taskmanager.com',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyDialog() {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Privacidade'),
            content: const Text(
              'Seus dados são tratados com segurança e privacidade.\n\n'
              'Para mais informações, consulte nossa política de privacidade.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
