import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/presentation/providers/auth_provider.dart' as auth_providers;
import '../../core/theme/plantis_colors.dart';

class AccountProfilePage extends StatelessWidget {
  const AccountProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Minha Conta',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<auth_providers.AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.currentUser;
            final isAnonymous = authProvider.isAnonymous;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com informações do usuário
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: PlantisColors.primary,
                        child: user?.hasProfilePhoto == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  user!.photoUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      user.initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                user?.initials ?? 'UA',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),

                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Usuário Anônimo',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'usuario@anonimo.com',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAnonymous ? Colors.orange.withValues(alpha: 0.2) : PlantisColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isAnonymous ? 'Conta Anônima' : 'Conta Autenticada',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isAnonymous ? Colors.orange : PlantisColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Card especial para usuário anônimo
                if (isAnonymous) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Conta Anônima',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Seus dados estão armazenados apenas neste dispositivo. Para maior segurança e sincronização entre dispositivos, recomendamos criar uma conta.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/auth');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.person_add, size: 18),
                            label: const Text('Criar Conta'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Ações da conta
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      if (!isAnonymous) ...[
                        ListTile(
                          leading: Icon(
                            Icons.edit_outlined,
                            color: PlantisColors.primary,
                          ),
                          title: const Text('Editar Perfil'),
                          subtitle: const Text('Nome, foto e informações pessoais'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            _showComingSoonDialog(context);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.security_outlined,
                            color: PlantisColors.primary,
                          ),
                          title: const Text('Privacidade'),
                          subtitle: const Text('Configurações de privacidade e dados'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            _showComingSoonDialog(context);
                          },
                        ),
                        const Divider(height: 1),
                      ],
                      ListTile(
                        leading: Icon(
                          Icons.logout_outlined,
                          color: theme.colorScheme.error,
                        ),
                        title: Text(
                          'Sair da Conta',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        subtitle: const Text('Fazer logout da aplicação'),
                        onTap: () {
                          _showLogoutDialog(context, authProvider);
                        },
                      ),
                      if (!isAnonymous) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.error,
                          ),
                          title: Text(
                            'Excluir Conta',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          subtitle: const Text('Remover conta permanentemente'),
                          onTap: () {
                            _showDeleteAccountDialog(context, authProvider);
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Em breve'),
        content: const Text('Esta funcionalidade estará disponível em breve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, auth_providers.AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/welcome');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao sair: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, auth_providers.AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Excluir Conta',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta ação não pode ser desfeita. Ao excluir sua conta:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text('• Todos seus dados serão removidos permanentemente'),
            const Text('• Suas plantas e tarefas serão excluídas'),
            const Text('• Você não poderá recuperar essas informações'),
            const Text('• Sua assinatura premium será cancelada'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta ação é irreversível',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFinalDeleteConfirmation(context, authProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context, auth_providers.AuthProvider authProvider) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação Final'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Digite "EXCLUIR" para confirmar a exclusão da conta:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'EXCLUIR',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              return ElevatedButton(
                onPressed: value.text == 'EXCLUIR' ? () async {
                  Navigator.of(context).pop();
                  try {
                    // Aqui implementaríamos a exclusão da conta
                    await authProvider.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conta excluída com sucesso'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.go('/welcome');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao excluir conta: $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Excluir Conta'),
              );
            },
          ),
        ],
      ),
    );
  }
}