import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';

import '../../../animals/presentation/providers/animals_provider.dart';
import '../providers/weights_provider.dart';

/// Advanced weight goal management with veterinary guidelines
class WeightGoalManagement extends ConsumerStatefulWidget {
  final String? animalId;
  final VoidCallback? onGoalsUpdated;

  const WeightGoalManagement({super.key, this.animalId, this.onGoalsUpdated});

  @override
  ConsumerState<WeightGoalManagement> createState() =>
      _WeightGoalManagementState();
}

class _WeightGoalManagementState extends ConsumerState<WeightGoalManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _targetWeightController = TextEditingController();
  final _timelineController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _targetDate = DateTime.now().add(const Duration(days: 90));
  String _goalType = 'maintain'; // maintain, lose, gain
  String _priority = 'medium'; // low, medium, high
  bool _enableProgressAlerts = true;
  bool _enableWeeklyReminders = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _targetWeightController.dispose();
    _timelineController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weightsState = ref.watch(weightsProvider);
    final animalsState = ref.watch(animalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Metas de Peso'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.track_changes), text: 'Metas Ativas'),
            Tab(icon: Icon(Icons.add_task), text: 'Nova Meta'),
            Tab(icon: Icon(Icons.medical_information), text: 'Diretrizes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveGoalsTab(theme, weightsState, animalsState),
          _buildNewGoalTab(theme, animalsState),
          _buildVeterinaryGuidelinesTab(theme, animalsState),
        ],
      ),
    );
  }

  Widget _buildActiveGoalsTab(
    ThemeData theme,
    WeightsState weightsState,
    AnimalsState animalsState,
  ) {
    final activeGoals = _getMockActiveGoals();

    if (activeGoals.isEmpty) {
      return _buildEmptyGoalsState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeGoals.length,
      itemBuilder: (context, index) {
        final goal = activeGoals[index];
        return _buildGoalCard(theme, goal, weightsState);
      },
    );
  }

  Widget _buildGoalCard(
    ThemeData theme,
    Map<String, dynamic> goal,
    WeightsState weightsState,
  ) {
    final progress = goal['progress'] as double;
    final progressColor = progress >= 0.8
        ? Colors.green
        : progress >= 0.5
        ? Colors.orange
        : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getGoalTypeColor(
                      goal['type'] as String,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getGoalTypeIcon(goal['type'] as String),
                    color: _getGoalTypeColor(goal['type'] as String),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        goal['animal'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(
                      goal['priority'] as String,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityLabel(goal['priority'] as String),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getPriorityColor(goal['priority'] as String),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progresso', style: theme.textTheme.titleSmall),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Atual: ${goal['currentWeight']} kg',
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        'Meta: ${goal['targetWeight']} kg',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Prazo: ${_formatDate(goal['targetDate'] as DateTime)}',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editGoal(goal),
                      iconSize: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.analytics),
                      onPressed: () => _showGoalAnalytics(goal),
                      iconSize: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () => _completeGoal(goal),
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewGoalTab(ThemeData theme, AnimalsState animalsState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
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
                      'Tipo de Meta',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildGoalTypeChip(
                          'maintain',
                          'Manter Peso',
                          Icons.balance,
                        ),
                        _buildGoalTypeChip(
                          'lose',
                          'Perder Peso',
                          Icons.trending_down,
                        ),
                        _buildGoalTypeChip(
                          'gain',
                          'Ganhar Peso',
                          Icons.trending_up,
                        ),
                      ],
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
                      'Configuração da Meta',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _targetWeightController,
                            decoration: const InputDecoration(
                              labelText: 'Peso Alvo (kg)',
                              prefixIcon: Icon(Icons.monitor_weight),
                              suffixText: 'kg',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Peso alvo é obrigatório';
                              }
                              final weight = double.tryParse(value);
                              if (weight == null || weight <= 0) {
                                return 'Peso deve ser um número válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Data Alvo'),
                            subtitle: Text(_formatDate(_targetDate)),
                            onTap: () => _selectTargetDate(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        prefixIcon: Icon(Icons.notes),
                        hintText:
                            'Motivação, estratégias, recomendações veterinárias...',
                      ),
                      maxLines: 3,
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
                    DropdownButtonFormField<String>(
                      initialValue: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Prioridade',
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Baixa')),
                        DropdownMenuItem(value: 'medium', child: Text('Média')),
                        DropdownMenuItem(value: 'high', child: Text('Alta')),
                      ],
                      onChanged: (value) => setState(() => _priority = value!),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Alertas de Progresso'),
                      subtitle: const Text(
                        'Notificações sobre evolução da meta',
                      ),
                      value: _enableProgressAlerts,
                      onChanged: (value) =>
                          setState(() => _enableProgressAlerts = value),
                    ),
                    SwitchListTile(
                      title: const Text('Lembretes Semanais'),
                      subtitle: const Text(
                        'Lembrete para registrar peso semanalmente',
                      ),
                      value: _enableWeeklyReminders,
                      onChanged: (value) =>
                          setState(() => _enableWeeklyReminders = value),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showVeterinaryConsultation(),
                    child: const Text('Consultar Veterinário'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveGoal,
                    child: const Text('Criar Meta'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTypeChip(String value, String label, IconData icon) {
    final isSelected = _goalType == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _goalType = value);
        }
      },
    );
  }

  Widget _buildVeterinaryGuidelinesTab(
    ThemeData theme,
    AnimalsState animalsState,
  ) {
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
                  Row(
                    children: [
                      Icon(
                        Icons.medical_information,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Diretrizes Veterinárias',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildGuidelineItem(
                    theme,
                    'Cães Adultos',
                    'Perda de peso saudável: 1-2% do peso corporal por semana',
                    Icons.pets,
                    Colors.blue,
                  ),
                  _buildGuidelineItem(
                    theme,
                    'Gatos Adultos',
                    'Perda de peso saudável: 0.5-1% do peso corporal por semana',
                    Icons.pets,
                    Colors.orange,
                  ),
                  _buildGuidelineItem(
                    theme,
                    'Filhotes',
                    'Crescimento rápido até 6 meses, monitoramento semanal',
                    Icons.child_care,
                    Colors.green,
                  ),
                  _buildGuidelineItem(
                    theme,
                    'Idosos (+7 anos)',
                    'Monitoramento mais frequente, atenção à massa muscular',
                    Icons.elderly,
                    Colors.purple,
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
                    'Calculadora de Peso Ideal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWeightCalculator(theme),
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
                    'Sinais de Alerta',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAlertItem(
                    theme,
                    'Perda de peso > 10% em 3 meses',
                    Colors.red,
                  ),
                  _buildAlertItem(
                    theme,
                    'Ganho de peso > 15% em 6 meses',
                    Colors.orange,
                  ),
                  _buildAlertItem(
                    theme,
                    'Flutuações frequentes (>5% por semana)',
                    Colors.yellow,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        color: color.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCalculator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Raça',
                    prefixIcon: Icon(Icons.pets),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Idade (anos)',
                    prefixIcon: Icon(Icons.cake),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _calculateIdealWeight(),
            icon: const Icon(Icons.calculate),
            label: const Text('Calcular Peso Ideal'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(ThemeData theme, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.warning, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGoalsState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.track_changes, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma meta ativa',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie uma meta de peso para acompanhar o progresso',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: const Icon(Icons.add),
            label: const Text('Criar Meta'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockActiveGoals() {
    return [
      {
        'id': '1',
        'title': 'Redução de peso saudável',
        'animal': 'Bobby - Labrador',
        'type': 'lose',
        'currentWeight': '32.5',
        'targetWeight': '28.0',
        'targetDate': DateTime.now().add(const Duration(days: 45)),
        'priority': 'high',
        'progress': 0.6,
      },
      {
        'id': '2',
        'title': 'Manutenção do peso ideal',
        'animal': 'Mimi - Persa',
        'type': 'maintain',
        'currentWeight': '4.2',
        'targetWeight': '4.2',
        'targetDate': DateTime.now().add(const Duration(days: 180)),
        'priority': 'medium',
        'progress': 0.9,
      },
    ];
  }

  Color _getGoalTypeColor(String type) {
    switch (type) {
      case 'lose':
        return Colors.red;
      case 'gain':
        return Colors.blue;
      case 'maintain':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getGoalTypeIcon(String type) {
    switch (type) {
      case 'lose':
        return Icons.trending_down;
      case 'gain':
        return Icons.trending_up;
      case 'maintain':
        return Icons.balance;
      default:
        return Icons.track_changes;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'ALTA';
      case 'medium':
        return 'MÉDIA';
      case 'low':
        return 'BAIXA';
      default:
        return 'NORMAL';
    }
  }

  void _selectTargetDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _targetDate = date);
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meta criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onGoalsUpdated?.call();
      Navigator.of(context).pop();
    }
  }

  void _editGoal(Map<String, dynamic> goal) {}

  void _completeGoal(Map<String, dynamic> goal) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Concluir Meta'),
        content: const Text(
          'Parabéns! Você atingiu sua meta de peso. Deseja marcá-la como concluída?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meta concluída com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  void _showGoalAnalytics(Map<String, dynamic> goal) {}

  void _showVeterinaryConsultation() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consulta Veterinária'),
        content: const Text(
          'Recomendamos consultar um veterinário para definir metas de peso adequadas para seu pet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Agendar Consulta'),
          ),
        ],
      ),
    );
  }

  void _calculateIdealWeight() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Peso Ideal Calculado'),
        content: const Text(
          'Com base nas informações fornecidas, o peso ideal estimado é entre 25-30kg. Consulte um veterinário para confirmação.',
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
