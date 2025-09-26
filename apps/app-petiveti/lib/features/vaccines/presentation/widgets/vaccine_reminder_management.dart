import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';

/// Advanced vaccine reminder management with smart notifications
class VaccineReminderManagement extends ConsumerStatefulWidget {
  final String? animalId;
  final VoidCallback? onRemindersUpdated;

  const VaccineReminderManagement({
    super.key,
    this.animalId,
    this.onRemindersUpdated,
  });

  @override
  ConsumerState<VaccineReminderManagement> createState() => _VaccineReminderManagementState();
}

class _VaccineReminderManagementState extends ConsumerState<VaccineReminderManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Reminder settings
  bool _enableSmartReminders = true;
  bool _enablePushNotifications = true;
  bool _enableEmailReminders = false;
  bool _enableSmsReminders = false;
  
  // Smart reminder configuration
  int _daysBeforeReminder = 7;
  int _urgentReminderDays = 3;
  String _reminderFrequency = 'daily';
  bool _weekendReminders = true;
  TimeOfDay _preferredTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vaccinesState = ref.watch(vaccinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Lembretes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.notifications), text: 'Ativos'),
            Tab(icon: Icon(Icons.settings), text: 'Configurações'),
            Tab(icon: Icon(Icons.analytics), text: 'Histórico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveRemindersTab(theme, vaccinesState),
          _buildSettingsTab(theme),
          _buildHistoryTab(theme, vaccinesState),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context),
        tooltip: 'Adicionar Lembrete',
        child: const Icon(Icons.add_alert),
      ),
    );
  }

  Widget _buildActiveRemindersTab(ThemeData theme, VaccinesState state) {
    final activeReminders = _getActiveReminders(state.vaccines);
    final upcomingReminders = _getUpcomingReminders(state.vaccines);
    final overdueReminders = _getOverdueReminders(state.vaccines);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReminderOverview(theme, state.vaccines),
          const SizedBox(height: 24),
          
          if (overdueReminders.isNotEmpty) ...[
            _buildReminderSection(
              theme,
              'Atenção Urgente',
              overdueReminders,
              Icons.warning,
              Colors.red,
              isUrgent: true,
            ),
            const SizedBox(height: 16),
          ],
          
          if (upcomingReminders.isNotEmpty) ...[
            _buildReminderSection(
              theme,
              'Próximos Lembretes',
              upcomingReminders,
              Icons.schedule,
              Colors.orange,
            ),
            const SizedBox(height: 16),
          ],
          
          if (activeReminders.isNotEmpty) ...[
            _buildReminderSection(
              theme,
              'Todos os Lembretes',
              activeReminders,
              Icons.notifications,
              theme.colorScheme.primary,
            ),
          ],
          
          if (activeReminders.isEmpty && upcomingReminders.isEmpty && overdueReminders.isEmpty)
            _buildEmptyRemindersState(theme),
        ],
      ),
    );
  }

  Widget _buildReminderOverview(ThemeData theme, List<Vaccine> vaccines) {
    final stats = _calculateReminderStatistics(vaccines);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo de Lembretes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Total',
                    stats['total'].toString(),
                    Icons.notifications,
                    theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Urgentes',
                    stats['urgent'].toString(),
                    Icons.priority_high,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Próximos',
                    stats['upcoming'].toString(),
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    theme,
                    'Inteligentes',
                    stats['smart'].toString(),
                    Icons.auto_awesome,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReminderSection(
    ThemeData theme,
    String title,
    List<Vaccine> vaccines,
    IconData icon,
    Color color, {
    bool isUrgent = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (isUrgent) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'URGENTE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        ...vaccines.map((vaccine) => _buildReminderCard(theme, vaccine, color, isUrgent)),
      ],
    );
  }

  Widget _buildReminderCard(ThemeData theme, Vaccine vaccine, Color accentColor, bool isUrgent) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: isUrgent ? 4 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isUrgent ? Border.all(color: Colors.red, width: 2) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccine.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Veterinário: ${vaccine.veterinarian}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          vaccine.nextDoseInfo,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (vaccine.reminderDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(vaccine.reminderDate!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pet ID: ${vaccine.animalId}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_notifications),
                        onPressed: () => _editReminder(vaccine),
                        iconSize: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.snooze),
                        onPressed: () => _snoozeReminder(vaccine),
                        iconSize: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () => _markAsCompleted(vaccine),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configurações de Notificação',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Lembretes Inteligentes'),
                    subtitle: const Text('Sistema automático baseado no tipo de vacina'),
                    value: _enableSmartReminders,
                    onChanged: (value) => setState(() => _enableSmartReminders = value),
                  ),
                  SwitchListTile(
                    title: const Text('Notificações Push'),
                    subtitle: const Text('Receber notificações no dispositivo'),
                    value: _enablePushNotifications,
                    onChanged: (value) => setState(() => _enablePushNotifications = value),
                  ),
                  SwitchListTile(
                    title: const Text('Lembretes por E-mail'),
                    subtitle: const Text('Receber lembretes por e-mail'),
                    value: _enableEmailReminders,
                    onChanged: (value) => setState(() => _enableEmailReminders = value),
                  ),
                  SwitchListTile(
                    title: const Text('Lembretes por SMS'),
                    subtitle: const Text('Receber lembretes por SMS'),
                    value: _enableSmsReminders,
                    onChanged: (value) => setState(() => _enableSmsReminders = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configurações Avançadas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Antecedência dos Lembretes'),
                    subtitle: Text('$_daysBeforeReminder dias antes'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectReminderDays(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.priority_high),
                    title: const Text('Lembretes Urgentes'),
                    subtitle: Text('$_urgentReminderDays dias antes'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectUrgentReminderDays(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Horário Preferencial'),
                    subtitle: Text(_preferredTime.format(context)),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectPreferredTime(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.repeat),
                    title: const Text('Frequência'),
                    subtitle: Text(_getFrequencyDisplayName(_reminderFrequency)),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectFrequency(),
                  ),
                  SwitchListTile(
                    title: const Text('Lembretes em Fins de Semana'),
                    subtitle: const Text('Enviar lembretes aos sábados e domingos'),
                    value: _weekendReminders,
                    onChanged: (value) => setState(() => _weekendReminders = value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ThemeData theme, VaccinesState state) {
    // This would show reminder history and analytics
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Histórico de Lembretes'),
          Text('Em desenvolvimento...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyRemindersState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum lembrete ativo',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure lembretes para não perder nenhuma vacina',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showAddReminderDialog(context),
            icon: const Icon(Icons.add_alert),
            label: const Text('Adicionar Lembrete'),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  List<Vaccine> _getActiveReminders(List<Vaccine> vaccines) {
    return vaccines.where((v) => 
        !v.isCompleted && 
        v.reminderDate != null && 
        v.reminderDate!.isAfter(DateTime.now())
    ).toList();
  }

  List<Vaccine> _getUpcomingReminders(List<Vaccine> vaccines) {
    final now = DateTime.now();
    final next7Days = now.add(const Duration(days: 7));
    
    return vaccines.where((v) => 
        !v.isCompleted && 
        v.nextDueDate != null &&
        v.nextDueDate!.isAfter(now) &&
        v.nextDueDate!.isBefore(next7Days)
    ).toList();
  }

  List<Vaccine> _getOverdueReminders(List<Vaccine> vaccines) {
    return vaccines.where((v) => v.isOverdue).toList();
  }

  Map<String, int> _calculateReminderStatistics(List<Vaccine> vaccines) {
    final active = _getActiveReminders(vaccines);
    final urgent = _getOverdueReminders(vaccines);
    final upcoming = _getUpcomingReminders(vaccines);
    final smart = vaccines.where((v) => _enableSmartReminders && !v.isCompleted).length;

    return {
      'total': active.length,
      'urgent': urgent.length,
      'upcoming': upcoming.length,
      'smart': smart,
    };
  }

  void _showAddReminderDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Lembrete'),
        content: const Text('Funcionalidade em desenvolvimento...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _editReminder(Vaccine vaccine) {
    // Edit reminder functionality
  }

  void _snoozeReminder(Vaccine vaccine) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adiar Lembrete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('1 hora'),
              onTap: () => _performSnooze(vaccine, 1),
            ),
            ListTile(
              title: const Text('1 dia'),
              onTap: () => _performSnooze(vaccine, 24),
            ),
            ListTile(
              title: const Text('3 dias'),
              onTap: () => _performSnooze(vaccine, 72),
            ),
            ListTile(
              title: const Text('1 semana'),
              onTap: () => _performSnooze(vaccine, 168),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _performSnooze(Vaccine vaccine, int hours) {
    Navigator.pop(context);
    final newReminderDate = DateTime.now().add(Duration(hours: hours));
    
    ref.read(vaccinesProvider.notifier).scheduleReminder(vaccine.id, newReminderDate);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lembrete adiado para ${_formatDateTime(newReminderDate)}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _markAsCompleted(Vaccine vaccine) {
    ref.read(vaccinesProvider.notifier).markAsCompleted(vaccine.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vacina marcada como concluída'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _selectReminderDays() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dias de Antecedência'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [3, 5, 7, 10, 14, 21, 30].map((days) {
            return RadioListTile<int>(
              title: Text('$days dias'),
              value: days,
              groupValue: _daysBeforeReminder,
              onChanged: (value) {
                setState(() => _daysBeforeReminder = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _selectUrgentReminderDays() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dias para Lembretes Urgentes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 3, 5, 7].map((days) {
            return RadioListTile<int>(
              title: Text('$days dias'),
              value: days,
              groupValue: _urgentReminderDays,
              onChanged: (value) {
                setState(() => _urgentReminderDays = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _selectPreferredTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _preferredTime,
    );
    
    if (time != null) {
      setState(() => _preferredTime = time);
    }
  }

  void _selectFrequency() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequência dos Lembretes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            {'value': 'once', 'name': 'Uma vez'},
            {'value': 'daily', 'name': 'Diariamente'},
            {'value': 'weekly', 'name': 'Semanalmente'},
          ].map((freq) {
            return RadioListTile<String>(
              title: Text(freq['name']!),
              value: freq['value']!,
              groupValue: _reminderFrequency,
              onChanged: (value) {
                setState(() => _reminderFrequency = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case 'once':
        return 'Uma vez';
      case 'daily':
        return 'Diariamente';
      case 'weekly':
        return 'Semanalmente';
      default:
        return 'Uma vez';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}