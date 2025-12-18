import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/task_lists/presentation/create_edit_task_list_page.dart';
import '../../features/task_lists/providers/task_list_providers.dart';
import '../../features/tasks/domain/task_list_entity.dart';
import '../../features/tasks/presentation/pages/my_day_page.dart';
import '../constants/task_list_colors.dart';
import '../providers/auth_providers.dart';

class ModernDrawer extends ConsumerWidget {
  const ModernDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final userDisplayName = user?.displayName ?? 'Usuário';
    final userEmail = user?.email ?? 'usuario@exemplo.com';
    final isAnonymous = user?.email.isEmpty ?? true;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      child: Column(
        children: [
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.wb_sunny_rounded,
                  title: 'Meu Dia',
                  subtitle: 'Tarefas de hoje',
                  iconColor: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (context) => const MyDayPage(),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.home_rounded,
                  title: 'Início',
                  subtitle: 'Visualizar tarefas',
                  onTap: () => Navigator.pop(context),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'MINHAS LISTAS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                ),

                _buildTaskListsSection(context, ref),

                _buildMenuItem(
                  context,
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Nova Lista',
                  subtitle: 'Criar lista personalizada',
                  iconColor: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (context) => const CreateEditTaskListPage(),
                      ),
                    );
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
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
                      MaterialPageRoute<dynamic>(
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
    Color? iconColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                isDestructive
                    ? Colors.red.withAlpha(26)
                    : (iconColor ?? AppColors.primaryColor).withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red[600] : (iconColor ?? AppColors.primaryColor),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color:
                isDestructive
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
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(102),
            ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor:
            isDestructive
                ? Colors.red.withAlpha(13)
                : AppColors.primaryColor.withAlpha(13),
      ),
    );
  }

  Widget _buildTaskListsSection(BuildContext context, WidgetRef ref) {
    final taskListsAsync = ref.watch(taskListsProvider);

    return taskListsAsync.when(
      data: (lists) {
        if (lists.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Nenhuma lista criada',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(128),
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: lists.map((list) {
            final color = TaskListColors.fromHex(list.color);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.list_rounded,
                    color: color,
                    size: 24,
                  ),
                ),
                title: Text(
                  list.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
                subtitle: list.description != null
                    ? Text(
                        list.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(153),
                          letterSpacing: 0.1,
                        ),
                      )
                    : null,
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(102),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to TaskListPage with list.id
                },
                onLongPress: () {
                  _showListOptions(context, ref, list);
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                hoverColor: color.withAlpha(13),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Erro ao carregar listas',
          style: TextStyle(
            fontSize: 14,
            color: Colors.red[600],
          ),
        ),
      ),
    );
  }

  void _showListOptions(BuildContext context, WidgetRef ref, TaskListEntity taskList) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Colors.blue),
              title: const Text('Editar Lista'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => CreateEditTaskListPage(taskList: taskList),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_rounded, color: Colors.orange),
              title: const Text('Arquivar Lista'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(archiveTaskListProvider.notifier).call(taskList.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lista arquivada!')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text('Deletar Lista'),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Deletar Lista?'),
                    content: const Text('Esta ação não pode ser desfeita.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Deletar'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await ref.read(deleteTaskListProvider.notifier).call(taskList.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lista deletada!')),
                    );
                  }
                }
              },
            ),
          ],
        ),
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
        await ref.read(authProvider.notifier).signOut();
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
