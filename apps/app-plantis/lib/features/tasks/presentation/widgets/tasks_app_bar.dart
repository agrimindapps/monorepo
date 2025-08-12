import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tasks_provider.dart';

class TasksAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const TasksAppBar({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Consumer<TasksProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tarefas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              if (provider.totalTasks > 0)
                Text(
                  '${provider.pendingTasks} pendentes de ${provider.totalTasks}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        // Busca
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(context),
        ),
        // Menu de opções
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Atualizar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Configurações'),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: theme.colorScheme.primary,
          child: TabBar(
            controller: tabController,
            isScrollable: true,
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
            indicatorColor: theme.colorScheme.onPrimary,
            tabs: const [
              Tab(
                icon: Icon(Icons.list_alt, size: 16),
                text: 'Todas',
              ),
              Tab(
                icon: Icon(Icons.today, size: 16),
                text: 'Hoje',
              ),
              Tab(
                icon: Icon(Icons.warning, size: 16),
                text: 'Atrasadas',
              ),
              Tab(
                icon: Icon(Icons.schedule, size: 16),
                text: 'Próximas',
              ),
              Tab(
                icon: Icon(Icons.check_circle, size: 16),
                text: 'Concluídas',
              ),
              Tab(
                icon: Icon(Icons.local_florist, size: 16),
                text: 'Por Planta',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Tarefas'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Digite o nome da tarefa ou planta...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (query) {
            context.read<TasksProvider>().searchTasks(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<TasksProvider>().searchTasks('');
              Navigator.of(context).pop();
            },
            child: const Text('Limpar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    final provider = context.read<TasksProvider>();
    
    switch (action) {
      case 'refresh':
        provider.refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atualizando tarefas...')),
        );
        break;
      case 'settings':
        // TODO: Implementar página de configurações de tarefas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações em desenvolvimento')),
        );
        break;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);
}