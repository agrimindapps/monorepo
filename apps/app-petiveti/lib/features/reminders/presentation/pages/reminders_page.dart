import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reminder.dart';
import '../providers/reminders_provider.dart';

class RemindersPage extends ConsumerStatefulWidget {
  final String userId;

  const RemindersPage({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends ConsumerState<RemindersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(remindersProvider.notifier).loadReminders(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lembretes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Hoje (${state.todayReminders.length})',
              icon: const Icon(Icons.today),
            ),
            Tab(
              text: 'Atrasados (${state.overdueReminders.length})',
              icon: const Icon(Icons.warning),
            ),
            Tab(
              text: 'Todos (${state.reminders.length})',
              icon: const Icon(Icons.list),
            ),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Erro: ${state.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(remindersProvider.notifier)
                            .loadReminders(widget.userId),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRemindersList(state.todayReminders, 'Nenhum lembrete para hoje'),
                    _buildRemindersList(state.overdueReminders, 'Nenhum lembrete atrasado'),
                    _buildRemindersList(state.reminders, 'Nenhum lembrete cadastrado'),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRemindersList(List<Reminder> reminders, String emptyMessage) {
    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return _buildReminderCard(reminder);
      },
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final isOverdue = reminder.isOverdue;
    final isDueToday = reminder.isDueToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isOverdue
          ? Colors.red[50]
          : isDueToday
              ? Colors.orange[50]
              : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOverdue
              ? Colors.red
              : isDueToday
                  ? Colors.orange
                  : _getTypeColor(reminder.type),
          child: Icon(
            _getTypeIcon(reminder.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: reminder.status == ReminderStatus.completed
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder.description.isNotEmpty) ...[
              Text(reminder.description),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(reminder.scheduledDate),
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.grey[600],
                    fontWeight: isOverdue ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
            if (reminder.isRecurring) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.repeat, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Repete a cada ${reminder.recurringDays} dias',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, reminder),
          itemBuilder: (context) => [
            if (reminder.status == ReminderStatus.active) ...[
              const PopupMenuItem(
                value: 'complete',
                child: ListTile(
                  leading: Icon(Icons.check),
                  title: Text('Marcar como Concluído'),
                ),
              ),
              const PopupMenuItem(
                value: 'snooze',
                child: ListTile(
                  leading: Icon(Icons.snooze),
                  title: Text('Adiar'),
                ),
              ),
            ],
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.vaccine:
        return Colors.green;
      case ReminderType.medication:
        return Colors.blue;
      case ReminderType.appointment:
        return Colors.purple;
      case ReminderType.weight:
        return Colors.teal;
      case ReminderType.general:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.vaccine:
        return Icons.vaccines;
      case ReminderType.medication:
        return Icons.medication;
      case ReminderType.appointment:
        return Icons.event;
      case ReminderType.weight:
        return Icons.scale;
      case ReminderType.general:
        return Icons.notifications;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;

    if (difference == 0) {
      return 'Hoje às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Amanhã às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference == -1) {
      return 'Ontem às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _handleMenuAction(String action, Reminder reminder) {
    switch (action) {
      case 'complete':
        ref.read(remindersProvider.notifier).completeReminder(reminder.id, widget.userId);
        break;
      case 'snooze':
        _showSnoozeDialog(reminder);
        break;
      case 'edit':
        _showEditReminderDialog(reminder);
        break;
      case 'delete':
        _showDeleteConfirmation(reminder);
        break;
    }
  }

  void _showAddReminderDialog(BuildContext context) {
    // TODO: Implementar dialog de adicionar lembrete
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de adicionar lembrete em desenvolvimento')),
    );
  }

  void _showEditReminderDialog(Reminder reminder) {
    // TODO: Implementar dialog de editar lembrete
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de editar lembrete em desenvolvimento')),
    );
  }

  void _showSnoozeDialog(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adiar Lembrete'),
        content: const Text('Por quanto tempo deseja adiar este lembrete?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final snoozeUntil = DateTime.now().add(const Duration(hours: 1));
              ref.read(remindersProvider.notifier).snoozeReminder(
                reminder.id,
                snoozeUntil,
                widget.userId,
              );
            },
            child: const Text('1 hora'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final snoozeUntil = DateTime.now().add(const Duration(hours: 4));
              ref.read(remindersProvider.notifier).snoozeReminder(
                reminder.id,
                snoozeUntil,
                widget.userId,
              );
            },
            child: const Text('4 horas'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final snoozeUntil = DateTime.now().add(const Duration(days: 1));
              ref.read(remindersProvider.notifier).snoozeReminder(
                reminder.id,
                snoozeUntil,
                widget.userId,
              );
            },
            child: const Text('1 dia'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o lembrete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(remindersProvider.notifier).deleteReminder(
                reminder.id,
                widget.userId,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}