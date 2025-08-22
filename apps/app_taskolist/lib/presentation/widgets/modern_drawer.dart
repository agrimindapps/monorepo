import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';
import '../pages/settings_page.dart';

class ModernDrawer extends ConsumerWidget {
  const ModernDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;
    final userDisplayName = user?.displayName ?? 'Usuário';
    final userEmail = user?.email ?? 'usuario@exemplo.com';
    final isAnonymous = user?.email.isEmpty ?? true;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      child: Column(
        children: [
          // Header com gradiente
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withBlue(255),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar com animação
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withAlpha(51),
                              border: Border.all(
                                color: Colors.white.withAlpha(102),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isAnonymous ? Icons.person_outline : Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Nome do usuário
                    Text(
                      userDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Email ou status anônimo
                    Text(
                      isAnonymous ? 'Modo Anônimo' : userEmail,
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home_rounded,
                  title: 'Início',
                  subtitle: 'Visualizar tarefas',
                  onTap: () => Navigator.pop(context),
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.task_rounded,
                  title: 'Minhas Tarefas',
                  subtitle: 'Gerenciar atividades',
                  onTap: () => Navigator.pop(context),
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.analytics_rounded,
                  title: 'Estatísticas',
                  subtitle: 'Visualizar progresso',
                  onTap: () => Navigator.pop(context),
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.category_rounded,
                  title: 'Categorias',
                  subtitle: 'Organizar por tags',
                  onTap: () => Navigator.pop(context),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Configurações',
                  subtitle: 'Personalizar app',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.help_rounded,
                  title: 'Ajuda & Suporte',
                  subtitle: 'Obter assistência',
                  onTap: () => Navigator.pop(context),
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.info_rounded,
                  title: 'Sobre o App',
                  subtitle: 'Versão e informações',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Footer com logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withAlpha(26),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withAlpha(51),
                ),
              ),
            ),
            child: _buildMenuItem(
              context,
              icon: Icons.logout_rounded,
              title: 'Sair',
              subtitle: 'Fazer logout',
              isDestructive: true,
              onTap: () => _handleLogout(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withAlpha(26)
                : AppColors.primaryColor.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive 
                ? Colors.red[600]
                : AppColors.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDestructive 
                ? Colors.red[600]
                : Theme.of(context).textTheme.titleMedium?.color,
            letterSpacing: 0.2,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(153),
            letterSpacing: 0.1,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(102),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: isDestructive 
            ? Colors.red.withAlpha(13)
            : AppColors.primaryColor.withAlpha(13),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirmar Logout'),
            ],
          ),
          content: const Text(
            'Tem certeza que deseja sair do aplicativo?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ref.read(authNotifierProvider.notifier).signOut();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao fazer logout: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}