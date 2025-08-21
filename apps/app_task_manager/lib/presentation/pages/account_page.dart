import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart' show UserEntity, AuthProvider;

import '../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';
import '../providers/subscription_providers.dart';
import '../../domain/entities/subscription_status.dart';
import '../pages/premium_page.dart';
import '../pages/notification_settings_page.dart';

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
    final subscriptionState = ref.watch(Subscription.subscriptionStatusProvider);

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
        error: (error, stack) => Center(
          child: Text('Erro ao carregar conta: $error'),
        ),
      ),
    );
  }

  Widget _buildAccountContent(
    BuildContext context, 
    UserEntity user, 
    AsyncValue<SubscriptionStatus> subscriptionState
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
              backgroundImage: user.photoUrl != null 
                ? NetworkImage(user.photoUrl!)
                : null,
              child: user.photoUrl == null
                ? Icon(
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
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

  Widget _buildSubscriptionSection(AsyncValue<SubscriptionStatus> subscriptionState) {
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
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
                    status.isActive ? 'Premium' : 'Gratuito',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: status.isActive ? AppColors.success : AppColors.textSecondary,
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
          
          if (!user.isEmailVerified && user.provider != AuthProvider.anonymous) ...[
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
                MaterialPageRoute(
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
          Icon(
            Icons.account_circle,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Você não está logado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
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
    
    showDialog(
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
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
    showDialog(
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Esta ação não pode ser desfeita. Todos os seus dados serão permanentemente removidos.\n\nTem certeza que deseja excluir sua conta?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _updateProfile() {
    // TODO: Implementar atualização de perfil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Atualização de perfil será implementada em breve'),
        backgroundColor: AppColors.info,
      ),
    );
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar conta permanente'),
        content: const Text(
          'Para manter seus dados seguros, crie uma conta com email e senha.\n\nEsta funcionalidade será implementada em breve.'
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

  void _deleteAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exclusão de conta será implementada em breve'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tema'),
        content: const Text('Configurações de tema serão implementadas em breve'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Idioma'),
        content: const Text('Suporte a múltiplos idiomas será implementado em breve'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup'),
        content: const Text('Sincronização com a nuvem será implementada em breve'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar dados'),
        content: const Text('Exportação de dados será implementada em breve'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda'),
        content: const Text(
          'Task Manager - Gerenciador de Tarefas\n\n'
          'Para suporte, entre em contato:\n'
          '• Email: suporte@taskmanager.com\n'
          '• Website: www.taskmanager.com'
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacidade'),
        content: const Text(
          'Seus dados são tratados com segurança e privacidade.\n\n'
          'Para mais informações, consulte nossa política de privacidade.'
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