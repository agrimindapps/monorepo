import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reminder.dart';
import '../providers/reminders_provider.dart';
import '../../../../shared/constants/reminders_constants.dart';

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
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: RemindersConstants.tabCount, vsync: this);
    // Use Future.microtask for better performance
    Future.microtask(() => _loadReminders());
    
    // Listen for errors and show them consistently
    ref.listenManual<RemindersState>(
      remindersProvider,
      (RemindersState? previous, RemindersState next) {
        if (next.error != null && previous?.error != next.error) {
          _showError(next.error!);
        }
      },
    );
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
        title: const Text(RemindersConstants.pageTitle),
        actions: [
          Semantics(
            label: RemindersConstants.refreshLabel,
            hint: RemindersConstants.refreshHint,
            child: IconButton(
              icon: const Icon(RemindersIcons.refreshIcon),
              onPressed: _loadReminders,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Semantics(
              label: RemindersSemantics.tabLabel(RemindersConstants.todayTabText, state.todayReminders.length),
              child: Tab(
                text: '${RemindersConstants.todayTabText} (${state.todayReminders.length})',
                icon: const Icon(RemindersIcons.todayIcon),
              ),
            ),
            Semantics(
              label: RemindersSemantics.tabLabel(RemindersConstants.overdueTabText, state.overdueReminders.length),
              child: Tab(
                text: '${RemindersConstants.overdueTabText} (${state.overdueReminders.length})',
                icon: const Icon(RemindersIcons.warningIcon),
              ),
            ),
            Semantics(
              label: RemindersSemantics.tabLabel(RemindersConstants.allTabText, state.reminders.length),
              child: Tab(
                text: '${RemindersConstants.allTabText} (${state.reminders.length})',
                icon: const Icon(RemindersIcons.listIcon),
              ),
            ),
          ],
        ),
      ),
      body: state.isLoading
          ? Semantics(
              label: RemindersConstants.loadingLabel,
              child: const Center(child: CircularProgressIndicator()),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRemindersList(
                  state.todayReminders, 
                  RemindersConstants.emptyTodayMessage,
                  RemindersConstants.todayListLabel,
                ),
                _buildRemindersList(
                  state.overdueReminders, 
                  RemindersConstants.emptyOverdueMessage,
                  RemindersConstants.overdueListLabel,
                ),
                _buildRemindersList(
                  state.reminders, 
                  RemindersConstants.emptyAllMessage,
                  RemindersConstants.allListLabel,
                ),
              ],
            ),
      floatingActionButton: Semantics(
        label: RemindersConstants.addReminderLabel,
        hint: RemindersConstants.addReminderHint,
        child: FloatingActionButton(
          onPressed: () => _showAddReminderDialog(context),
          child: const Icon(RemindersIcons.addIcon),
        ),
      ),
    );
  }

  Widget _buildRemindersList(List<Reminder> reminders, String emptyMessage, String listLabel) {
    if (reminders.isEmpty) {
      return Semantics(
        label: emptyMessage,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                RemindersIcons.emptyScheduleIcon, 
                size: RemindersConstants.emptyIconSize, 
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      label: listLabel,
      child: RefreshIndicator(
        onRefresh: () async => _loadReminders(),
        child: ListView.builder(
          padding: RemindersConstants.listPadding,
          itemCount: reminders.length,
          itemExtent: RemindersConstants.itemExtent,
          cacheExtent: RemindersConstants.cacheExtent,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return _buildReminderCard(reminder);
          },
        ),
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final isOverdue = reminder.isOverdue;
    final isDueToday = reminder.isDueToday;
    final statusText = reminder.status == ReminderStatus.completed 
        ? RemindersConstants.completedStatus 
        : isOverdue 
            ? RemindersConstants.overdueStatus 
            : isDueToday 
                ? RemindersConstants.todayStatus 
                : RemindersConstants.scheduledStatus;
    
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: RemindersSemantics.reminderCardLabel(
        reminder.title, statusText, _formatDateTime(reminder.scheduledDate)),
      hint: RemindersSemantics.cardHint,
      child: Card(
        key: ValueKey(reminder.id), // Key for optimized rebuilds
        margin: RemindersConstants.cardMargin,
        color: isOverdue
            ? colorScheme.errorContainer
            : isDueToday
                ? colorScheme.tertiaryContainer
                : null,
        child: ListTile(
          leading: Semantics(
            label: RemindersSemantics.reminderTypeLabel(reminder.type.name),
            child: CircleAvatar(
              backgroundColor: isOverdue
                  ? colorScheme.error
                  : isDueToday
                      ? colorScheme.tertiary
                      : _getTypeColor(reminder.type),
              child: Icon(
                _getTypeIcon(reminder.type),
                color: RemindersColors.completedIconColor,
                semanticLabel: reminder.type.name,
              ),
            ),
          ),
          title: Text(
            reminder.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  Icon(
                    Icons.schedule, 
                    size: 14, 
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(reminder.scheduledDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOverdue 
                        ? colorScheme.error 
                        : colorScheme.onSurfaceVariant,
                      fontWeight: isOverdue ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
              if (reminder.isRecurring) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.repeat, 
                      size: 14, 
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Repete a cada ${reminder.recurringDays} dias',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: Semantics(
            label: 'Opções do lembrete',
            hint: 'Toque para ver ações disponíveis',
            child: PopupMenuButton<String>(
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
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: colorScheme.error),
                    title: Text(
                      'Excluir', 
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.vaccine:
        return RemindersColors.vaccineColor;
      case ReminderType.medication:
        return RemindersColors.medicationColor;
      case ReminderType.appointment:
        return RemindersColors.appointmentColor;
      case ReminderType.weight:
        return RemindersColors.weightColor;
      case ReminderType.general:
        return RemindersColors.generalColor;
    }
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.vaccine:
        return RemindersIcons.vaccineIcon;
      case ReminderType.medication:
        return RemindersIcons.medicationIcon;
      case ReminderType.appointment:
        return RemindersIcons.appointmentIcon;
      case ReminderType.weight:
        return RemindersIcons.weightIcon;
      case ReminderType.general:
        return RemindersIcons.generalIcon;
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

  void _handleMenuAction(String action, Reminder reminder) async {
    if (_isProcessing) return;
    
    try {
      switch (action) {
        case 'complete':
          setState(() => _isProcessing = true);
          final success = await ref
              .read(remindersProvider.notifier)
              .completeReminder(reminder.id, widget.userId);
          _showResultSnackBar(success, 'lembrete marcado como concluído');
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
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _loadReminders() {
    ref.read(remindersProvider.notifier).loadReminders(widget.userId);
  }
  
  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro: $message'),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Tentar Novamente',
          onPressed: _loadReminders,
        ),
      ),
    );
  }
  
  void _showResultSnackBar(bool success, String action) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success 
            ? '${action[0].toUpperCase()}${action.substring(1)} com sucesso'
            : 'Erro ao ${action.split(' ').join(' ')}',
        ),
        backgroundColor: success 
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.error,
        action: success ? null : SnackBarAction(
          label: 'Tentar Novamente',
          onPressed: _loadReminders,
        ),
      ),
    );
  }
  
  void _snoozeReminder(Reminder reminder, Duration duration) async {
    Navigator.of(context).pop();
    setState(() => _isProcessing = true);
    
    try {
      final snoozeUntil = DateTime.now().add(duration);
      final success = await ref.read(remindersProvider.notifier).snoozeReminder(
        reminder.id,
        snoozeUntil,
        widget.userId,
      );
      _showResultSnackBar(success, 'lembrete adiado');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adiar Lembrete'),
        content: const Text('Por quanto tempo deseja adiar este lembrete?'),
        actions: [
          TextButton(
            onPressed: () => _snoozeReminder(reminder, RemindersConstants.snooze1Hour),
            child: const Text('1 hora'),
          ),
          TextButton(
            onPressed: () => _snoozeReminder(reminder, RemindersConstants.snooze4Hours),
            child: const Text('4 horas'),
          ),
          TextButton(
            onPressed: () => _snoozeReminder(reminder, RemindersConstants.snooze1Day),
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
    showDialog<void>(
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
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() => _isProcessing = true);
              
              try {
                final success = await ref
                    .read(remindersProvider.notifier)
                    .deleteReminder(reminder.id, widget.userId);
                _showResultSnackBar(success, 'lembrete excluído');
              } finally {
                if (mounted) {
                  setState(() => _isProcessing = false);
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}