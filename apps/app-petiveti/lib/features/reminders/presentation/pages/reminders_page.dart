import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/enhanced_animal_selector.dart';
import '../../../../shared/widgets/petiveti_page_header.dart';
import '../../../animals/presentation/providers/animals_providers.dart';
import '../../domain/entities/reminder.dart';
import '../providers/reminders_providers.dart';
import '../widgets/add_reminder_dialog.dart';

/// Página de lembretes seguindo padrão responsivo (desktop/mobile)
class RemindersPage extends ConsumerStatefulWidget {
  final String userId;

  const RemindersPage({super.key, required this.userId});

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends ConsumerState<RemindersPage> {
  String? _selectedAnimalId;
  bool _showOnlyOverdue = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadReminders());
    ref.listenManual<RemindersState>(remindersProvider, (
      RemindersState? previous,
      RemindersState next,
    ) {
      if (next.error != null && previous?.error != next.error) {
        _showError(next.error!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(remindersProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildAnimalSelector(),
            _buildFilterChips(state),
            Expanded(child: _buildContent(context, state)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectedAnimalId != null
            ? () => _showAddReminderDialog(context)
            : null,
        tooltip: _selectedAnimalId != null
            ? 'Adicionar lembrete'
            : 'Selecione um pet primeiro',
        backgroundColor: _selectedAnimalId != null
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: _selectedAnimalId != null
            ? null
            : Theme.of(context).colorScheme.onSurfaceVariant,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: PetivetiPageHeader(
        icon: Icons.notifications_active,
        title: 'Lembretes',
        subtitle: 'Gerencie seus lembretes',
        showBackButton: true,
        actions: [
          _buildHeaderAction(
            icon: Icons.refresh,
            onTap: _loadReminders,
            tooltip: 'Atualizar',
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildAnimalSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: EnhancedAnimalSelector(
        selectedAnimalId: _selectedAnimalId,
        autoSelectFirst: false,
        onAnimalChanged: (animalId) {
          setState(() => _selectedAnimalId = animalId);
        },
        hintText: 'Todos os pets',
      ),
    );
  }

  Widget _buildFilterChips(RemindersState state) {
    final overdueCount = state.overdueReminders.length;
    final todayCount = state.todayReminders.length;
    final totalCount = state.reminders.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Todos ($totalCount)',
              icon: Icons.list,
              isSelected: !_showOnlyOverdue,
              onTap: () => setState(() => _showOnlyOverdue = false),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Hoje ($todayCount)',
              icon: Icons.today,
              isSelected: false,
              color: Colors.blue,
              onTap: () {
                // Poderia filtrar apenas hoje, mas por simplicidade
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Atrasados ($overdueCount)',
              icon: Icons.warning,
              isSelected: _showOnlyOverdue,
              color: Colors.red,
              onTap: () => setState(() => _showOnlyOverdue = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? chipColor
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? chipColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? chipColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RemindersState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filtrar lembretes
    List<Reminder> reminders = _showOnlyOverdue
        ? state.overdueReminders
        : state.reminders;

    // Filtrar por animal se selecionado
    if (_selectedAnimalId != null) {
      reminders = reminders
          .where((r) => r.animalId == _selectedAnimalId)
          .toList();
    }

    if (reminders.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async => _loadReminders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReminderCard(reminder),
          );
        },
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final isOverdue = reminder.isOverdue;
    final isDueToday = reminder.isDueToday;
    final isCompleted = reminder.status == ReminderStatus.completed;
    final colorScheme = Theme.of(context).colorScheme;

    // Buscar nome do animal
    final animalsState = ref.watch(animalsProvider);
    final animal = animalsState.animals
        .where((a) => a.id == reminder.animalId)
        .firstOrNull;

    return Card(
      margin: EdgeInsets.zero,
      color: isOverdue
          ? colorScheme.errorContainer.withValues(alpha: 0.5)
          : isDueToday
              ? colorScheme.tertiaryContainer.withValues(alpha: 0.5)
              : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue
              ? colorScheme.error.withValues(alpha: 0.3)
              : isDueToday
                  ? colorScheme.tertiary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () => _showReminderOptions(reminder),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Type icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? colorScheme.error.withValues(alpha: 0.15)
                          : isDueToday
                              ? colorScheme.tertiary.withValues(alpha: 0.15)
                              : _getTypeColor(reminder.type).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getTypeIcon(reminder.type),
                      size: 20,
                      color: isOverdue
                          ? colorScheme.error
                          : isDueToday
                              ? colorScheme.tertiary
                              : _getTypeColor(reminder.type),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getTypeName(reminder.type),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  _buildStatusBadge(reminder, colorScheme),
                ],
              ),
              
              // Description
              if (reminder.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  reminder.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Info row
              Row(
                children: [
                  // Date/time
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: isOverdue
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(reminder.scheduledDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOverdue
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isOverdue ? FontWeight.w600 : null,
                    ),
                  ),
                  
                  // Recurring indicator
                  if (reminder.isRecurring) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.repeat,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'A cada ${reminder.recurringDays} dias',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Animal name
                  if (animal != null) ...[
                    Icon(
                      Icons.pets,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      animal.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              // Actions row (visible actions)
              if (reminder.status == ReminderStatus.active) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _completeReminder(reminder),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Concluir'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showSnoozeDialog(reminder),
                      icon: const Icon(Icons.snooze, size: 18),
                      label: const Text('Adiar'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Reminder reminder, ColorScheme colorScheme) {
    final isOverdue = reminder.isOverdue;
    final isDueToday = reminder.isDueToday;
    final isCompleted = reminder.status == ReminderStatus.completed;

    String label;
    Color color;
    IconData icon;

    if (isCompleted) {
      label = 'Concluído';
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (isOverdue) {
      label = 'Atrasado';
      color = colorScheme.error;
      icon = Icons.warning;
    } else if (isDueToday) {
      label = 'Hoje';
      color = colorScheme.tertiary;
      icon = Icons.today;
    } else {
      label = 'Agendado';
      color = colorScheme.primary;
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final message = _showOnlyOverdue
        ? 'Nenhum lembrete atrasado'
        : 'Nenhum lembrete cadastrado';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showOnlyOverdue ? Icons.check_circle : Icons.notifications_none,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showOnlyOverdue
                ? 'Parabéns! Você está em dia.'
                : 'Adicione lembretes para não esquecer de nada.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
        return Icons.monitor_weight;
      case ReminderType.general:
        return Icons.notifications;
    }
  }

  String _getTypeName(ReminderType type) {
    switch (type) {
      case ReminderType.vaccine:
        return 'Vacina';
      case ReminderType.medication:
        return 'Medicamento';
      case ReminderType.appointment:
        return 'Consulta';
      case ReminderType.weight:
        return 'Peso';
      case ReminderType.general:
        return 'Geral';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = reminderDate.difference(today).inDays;
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (difference == 0) {
      return 'Hoje às $time';
    } else if (difference == 1) {
      return 'Amanhã às $time';
    } else if (difference == -1) {
      return 'Ontem às $time';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às $time';
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

  void _showAddReminderDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AddReminderDialog(userId: widget.userId),
    );
  }

  void _showReminderOptions(Reminder reminder) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                _showEditReminderDialog(reminder);
              },
            ),
            if (reminder.status == ReminderStatus.active) ...[
              ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: const Text('Marcar como concluído'),
                onTap: () {
                  Navigator.pop(context);
                  _completeReminder(reminder);
                },
              ),
              ListTile(
                leading: const Icon(Icons.snooze),
                title: const Text('Adiar'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnoozeDialog(reminder);
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text('Excluir', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(reminder);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReminderDialog(Reminder reminder) {
    showDialog<void>(
      context: context,
      builder: (context) => AddReminderDialog(
        reminder: reminder,
        userId: widget.userId,
      ),
    );
  }

  Future<void> _completeReminder(Reminder reminder) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final success = await ref
          .read(remindersProvider.notifier)
          .completeReminder(reminder.id, widget.userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Lembrete concluído com sucesso'
                : 'Erro ao concluir lembrete'),
            backgroundColor: success
                ? Colors.green
                : Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnoozeDialog(Reminder reminder) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adiar Lembrete'),
        content: const Text('Por quanto tempo deseja adiar este lembrete?'),
        actions: [
          TextButton(
            onPressed: () => _snoozeReminder(reminder, const Duration(hours: 1)),
            child: const Text('1 hora'),
          ),
          TextButton(
            onPressed: () => _snoozeReminder(reminder, const Duration(hours: 4)),
            child: const Text('4 horas'),
          ),
          TextButton(
            onPressed: () => _snoozeReminder(reminder, const Duration(days: 1)),
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

  Future<void> _snoozeReminder(Reminder reminder, Duration duration) async {
    Navigator.of(context).pop();
    
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final snoozeUntil = DateTime.now().add(duration);
      final success = await ref
          .read(remindersProvider.notifier)
          .snoozeReminder(reminder.id, snoozeUntil, widget.userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Lembrete adiado com sucesso'
                : 'Erro ao adiar lembrete'),
            backgroundColor: success
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showDeleteConfirmation(Reminder reminder) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir o lembrete "${reminder.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteReminder(reminder);
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

  Future<void> _deleteReminder(Reminder reminder) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final success = await ref
          .read(remindersProvider.notifier)
          .deleteReminder(reminder.id, widget.userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Lembrete excluído com sucesso'
                : 'Erro ao excluir lembrete'),
            backgroundColor: success
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
