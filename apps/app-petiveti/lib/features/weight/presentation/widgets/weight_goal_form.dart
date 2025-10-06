import 'package:flutter/material.dart';

/// Widget responsible for weight goal creation form following SRP
/// 
/// Single responsibility: Handle new weight goal creation and configuration
class WeightGoalForm extends StatefulWidget {
  final VoidCallback onGoalSaved;
  final VoidCallback onVeterinaryConsultation;

  const WeightGoalForm({
    super.key,
    required this.onGoalSaved,
    required this.onVeterinaryConsultation,
  });

  @override
  State<WeightGoalForm> createState() => _WeightGoalFormState();
}

class _WeightGoalFormState extends State<WeightGoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _targetWeightController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _targetDate = DateTime.now().add(const Duration(days: 90));
  String _goalType = 'maintain';
  String _priority = 'medium';
  bool _enableProgressAlerts = true;
  bool _enableWeeklyReminders = true;

  @override
  void dispose() {
    _targetWeightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalTypeSection(),
            const SizedBox(height: 16),
            _buildGoalConfigurationSection(),
            const SizedBox(height: 16),
            _buildAdvancedSettingsSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTypeSection() {
    final theme = Theme.of(context);
    
    return Card(
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
                _buildGoalTypeChip('maintain', 'Manter Peso', Icons.balance),
                _buildGoalTypeChip('lose', 'Perder Peso', Icons.trending_down),
                _buildGoalTypeChip('gain', 'Ganhar Peso', Icons.trending_up),
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
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _goalType = value);
        }
      },
    );
  }

  Widget _buildGoalConfigurationSection() {
    final theme = Theme.of(context);
    
    return Card(
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
                      border: OutlineInputBorder(),
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
                      if (weight > 150) {
                        return 'Peso parece muito alto. Verifique o valor.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectTargetDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Data Alvo',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(_targetDate),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                hintText: 'Motivação, estratégias, recomendações veterinárias...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsSection() {
    final theme = Theme.of(context);
    
    return Card(
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
              value: _priority,
              decoration: const InputDecoration(
                labelText: 'Prioridade',
                prefixIcon: Icon(Icons.priority_high),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Baixa')),
                DropdownMenuItem(value: 'medium', child: Text('Média')),
                DropdownMenuItem(value: 'high', child: Text('Alta')),
              ],
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              title: const Text('Alertas de Progresso'),
              subtitle: const Text('Notificações sobre evolução da meta'),
              value: _enableProgressAlerts,
              onChanged: (value) => setState(() => _enableProgressAlerts = value),
              activeColor: theme.colorScheme.primary,
            ),
            SwitchListTile.adaptive(
              title: const Text('Lembretes Semanais'),
              subtitle: const Text('Lembrete para registrar peso semanalmente'),
              value: _enableWeeklyReminders,
              onChanged: (value) => setState(() => _enableWeeklyReminders = value),
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onVeterinaryConsultation,
            icon: const Icon(Icons.medical_services),
            label: const Text('Consultar Veterinário'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            onPressed: _saveGoal,
            icon: const Icon(Icons.save),
            label: const Text('Criar Meta'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTargetDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Selecione a data alvo',
    );
    
    if (date != null && mounted) {
      setState(() => _targetDate = date);
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final goalData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': _goalType,
        'targetWeight': double.parse(_targetWeightController.text.trim()),
        'targetDate': _targetDate,
        'priority': _priority,
        'notes': _notesController.text.trim(),
        'enableProgressAlerts': _enableProgressAlerts,
        'enableWeeklyReminders': _enableWeeklyReminders,
        'createdAt': DateTime.now(),
      };
      print('Saving goal: $goalData');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meta criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      widget.onGoalSaved();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
