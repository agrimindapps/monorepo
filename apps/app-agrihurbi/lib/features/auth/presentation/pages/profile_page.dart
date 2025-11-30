import 'package:core/core.dart' hide AuthProvider;
import 'package:flutter/material.dart';

import '../notifiers/auth_notifier.dart';

/// Página de perfil do usuário
///
/// Exibe informações do usuário logado e opções de configuração
/// Inclui funcionalidades de logout e refresh de dados
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _refreshUserData(ref),
                tooltip: 'Atualizar dados',
              );
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authProvider);
          if (authState.isInitializing) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!authState.isLoggedIn || authState.currentUser == null) {
            return _buildNotLoggedInState();
          }

          return _buildProfileContent(authState.currentUser!, ref);
        },
      ),
    );
  }

  /// Constrói o conteúdo principal do perfil
  Widget _buildProfileContent(UserEntity user, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => _refreshUserData(ref),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(user),
            const SizedBox(height: 32),
            _buildUserDetails(user),
            const SizedBox(height: 32),
            _buildUserActions(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Cabeçalho com avatar e informações básicas
  Widget _buildUserHeader(UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: user.profileImageUrl?.isNotEmpty == true
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl?.isEmpty ?? true
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: Theme.of(context).textTheme.headlineMedium,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.isActive ? 'Ativo' : 'Inativo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Seção com detalhes do usuário
  Widget _buildUserDetails(UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações da Conta',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailItem('ID do Usuário', user.id, Icons.person),
            _buildDetailItem(
              'Telefone',
              user.phone ?? 'Não informado',
              Icons.phone,
            ),
            _buildDetailItem(
              'Conta criada em',
              user.createdAt != null
                  ? _formatDate(user.createdAt!)
                  : 'Não informado',
              Icons.calendar_today,
            ),
            if (user.lastLoginAt != null)
              _buildDetailItem(
                'Último acesso',
                _formatDate(user.lastLoginAt!),
                Icons.access_time,
              ),
          ],
        ),
      ),
    );
  }

  /// Item de detalhe individual
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Ações disponíveis para o usuário
  Widget _buildUserActions() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Ações', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: authState.isRefreshing
                      ? null
                      : () => _refreshUserData(ref),
                  icon: authState.isRefreshing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    authState.isRefreshing
                        ? 'Atualizando...'
                        : 'Atualizar Dados',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed:
                      authState.isLoggingOut ? null : () => _performLogout(ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: authState.isLoggingOut
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.logout),
                  label: Text(
                    authState.isLoggingOut ? 'Saindo...' : 'Sair da Conta',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Estado quando usuário não está logado
  Widget _buildNotLoggedInState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Você não está logado',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Faça login para ver seu perfil',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Fazer Login'),
          ),
        ],
      ),
    );
  }

  /// Atualiza dados do usuário
  Future<void> _refreshUserData(WidgetRef ref) async {
    final authNotifier = ref.read(authProvider.notifier);

    try {
      await authNotifier.refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados atualizados com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Executa logout
  Future<void> _performLogout(WidgetRef ref) async {
    final authNotifier = ref.read(authProvider.notifier);

    try {
      await authNotifier.logout();

      if (mounted) {
        context.go('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout realizado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Formata data para exibição
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} às '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
