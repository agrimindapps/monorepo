import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';

/// Advanced vaccine scheduling interface with comprehensive features
class VaccineSchedulingInterface extends ConsumerStatefulWidget {
  final Vaccine? existingVaccine;
  final String? animalId;
  final VoidCallback? onScheduled;

  const VaccineSchedulingInterface({
    super.key,
    this.existingVaccine,
    this.animalId,
    this.onScheduled,
  });

  @override
  ConsumerState<VaccineSchedulingInterface> createState() => _VaccineSchedulingInterfaceState();
}

class _VaccineSchedulingInterfaceState extends ConsumerState<VaccineSchedulingInterface>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _batchController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _scheduledDate = DateTime.now();
  DateTime? _nextDueDate;
  DateTime? _reminderDate;
  bool _isRequired = true;
  bool _enableSmartReminders = true;
  VaccineStatus _status = VaccineStatus.scheduled;
  
  // Advanced scheduling options
  bool _isSeriesVaccine = false;
  int _seriesCount = 1;
  int _seriesIntervalDays = 30;
  bool _enableSeasonalReminders = false;
  String? _selectedSeason;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.existingVaccine != null) {
      final vaccine = widget.existingVaccine!;
      _nameController.text = vaccine.name;
      _veterinarianController.text = vaccine.veterinarian;
      _batchController.text = vaccine.batch ?? '';
      _manufacturerController.text = vaccine.manufacturer ?? '';
      _dosageController.text = vaccine.dosage ?? '';
      _notesController.text = vaccine.notes ?? '';
      _scheduledDate = vaccine.date;
      _nextDueDate = vaccine.nextDueDate;
      _reminderDate = vaccine.reminderDate;
      _isRequired = vaccine.isRequired;
      _status = vaccine.status;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _veterinarianController.dispose();
    _batchController.dispose();
    _manufacturerController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingVaccine == null ? 'Agendar Vacina' : 'Editar Vacina'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Básico'),
            Tab(icon: Icon(Icons.schedule), text: 'Agendamento'),
            Tab(icon: Icon(Icons.notifications), text: 'Lembretes'),
            Tab(icon: Icon(Icons.analytics), text: 'Avançado'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: _saveVaccine,
            child: const Text('Salvar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(theme),
            _buildSchedulingTab(theme),
            _buildRemindersTab(theme),
            _buildAdvancedTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab(ThemeData theme) {
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
                    'Informações da Vacina',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Vacina *',
                      prefixIcon: Icon(Icons.vaccines),
                      hintText: 'Ex: V10, Antirrábica, FeLV',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome da vacina é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _veterinarianController,
                    decoration: const InputDecoration(
                      labelText: 'Veterinário *',
                      prefixIcon: Icon(Icons.medical_services),
                      hintText: 'Nome do veterinário responsável',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veterinário é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _batchController,
                          decoration: const InputDecoration(
                            labelText: 'Lote',
                            prefixIcon: Icon(Icons.qr_code),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _manufacturerController,
                          decoration: const InputDecoration(
                            labelText: 'Fabricante',
                            prefixIcon: Icon(Icons.business),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosagem',
                      prefixIcon: Icon(Icons.medication),
                      hintText: 'Ex: 1ml, 0.5ml subcutâneo',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      prefixIcon: Icon(Icons.notes),
                      hintText: 'Reações, recomendações especiais...',
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
                    'Configurações',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Vacina Obrigatória'),
                    subtitle: const Text('Marca como essencial para a saúde do pet'),
                    value: _isRequired,
                    onChanged: (value) => setState(() => _isRequired = value),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<VaccineStatus>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status Atual',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: VaccineStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.displayText),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulingTab(ThemeData theme) {
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
                    'Agendamento da Vacina',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Data da Aplicação'),
                    subtitle: Text(_formatDate(_scheduledDate)),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectDate(context, _scheduledDate, (date) {
                      setState(() => _scheduledDate = date);
                    }),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.event_repeat),
                    title: const Text('Próxima Dose'),
                    subtitle: Text(_nextDueDate != null 
                        ? _formatDate(_nextDueDate!) 
                        : 'Dose única - sem reforço'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectNextDueDate(context),
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
                    'Série de Vacinas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Vacina em Série'),
                    subtitle: const Text('Múltiplas doses programadas automaticamente'),
                    value: _isSeriesVaccine,
                    onChanged: (value) => setState(() => _isSeriesVaccine = value),
                  ),
                  if (_isSeriesVaccine) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _seriesCount.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Número de Doses',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final count = int.tryParse(value) ?? 1;
                              setState(() => _seriesCount = count);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _seriesIntervalDays.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Intervalo (dias)',
                              prefixIcon: Icon(Icons.schedule),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final interval = int.tryParse(value) ?? 30;
                              setState(() => _seriesIntervalDays = interval);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cronograma Previsto:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(_seriesCount, (index) {
                            final doseDate = _scheduledDate.add(
                              Duration(days: index * _seriesIntervalDays),
                            );
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '${index + 1}ª dose: ${_formatDate(doseDate)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersTab(ThemeData theme) {
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
                    'Sistema de Lembretes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Lembretes Inteligentes'),
                    subtitle: const Text('Sistema automático baseado no tipo de vacina'),
                    value: _enableSmartReminders,
                    onChanged: (value) => setState(() => _enableSmartReminders = value),
                  ),
                  const SizedBox(height: 16),
                  if (_enableSmartReminders) 
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Lembretes Automáticos Ativados',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• 7 dias antes do vencimento\n• 3 dias antes (lembrete urgente)\n• No dia do vencimento\n• Notificação de atraso',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.notification_add),
                    title: const Text('Lembrete Personalizado'),
                    subtitle: Text(_reminderDate != null 
                        ? 'Agendado para ${_formatDateTime(_reminderDate!)}'
                        : 'Nenhum lembrete personalizado'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectReminderDate(context),
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
                    'Lembretes Sazonais',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Ativar Lembretes Sazonais'),
                    subtitle: const Text('Para vacinas anuais como antirrábica'),
                    value: _enableSeasonalReminders,
                    onChanged: (value) => setState(() => _enableSeasonalReminders = value),
                  ),
                  if (_enableSeasonalReminders) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedSeason,
                      decoration: const InputDecoration(
                        labelText: 'Época Preferencial',
                        prefixIcon: Icon(Icons.wb_sunny),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'spring', child: Text('Primavera')),
                        DropdownMenuItem(value: 'summer', child: Text('Verão')),
                        DropdownMenuItem(value: 'autumn', child: Text('Outono')),
                        DropdownMenuItem(value: 'winter', child: Text('Inverno')),
                      ],
                      onChanged: (value) => setState(() => _selectedSeason = value),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTab(ThemeData theme) {
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
                    'Configurações Avançadas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildVaccineTemplateSelector(theme),
                  const SizedBox(height: 16),
                  _buildEffectivenessTracker(theme),
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
                    'Integração com Calendário',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Sincronizar com Calendário do Sistema'),
                    subtitle: const Text('Adiciona eventos automaticamente'),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // Implement calendar sync
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineTemplateSelector(ThemeData theme) {
    final commonVaccines = [
      {'name': 'V10 (Cães)', 'interval': 365, 'series': 3},
      {'name': 'Antirrábica', 'interval': 365, 'series': 1},
      {'name': 'FeLV (Gatos)', 'interval': 365, 'series': 2},
      {'name': 'Tríplice Viral', 'interval': 365, 'series': 2},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Templates de Vacinas Comuns',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonVaccines.map((vaccine) {
            return ActionChip(
              label: Text(vaccine['name'] as String),
              onPressed: () => _applyVaccineTemplate(vaccine),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEffectivenessTracker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rastreamento de Eficácia',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.science, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Monitoramento Científico',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'O sistema acompanhará:\n• Duração da proteção\n• Reações adversas\n• Necessidade de reforços\n• Eficácia comparativa entre lotes',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.amber[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _applyVaccineTemplate(Map<String, dynamic> template) {
    setState(() {
      _nameController.text = template['name'] as String;
      _isSeriesVaccine = (template['series'] as int) > 1;
      _seriesCount = template['series'] as int;
      
      if (template['interval'] != null) {
        _nextDueDate = _scheduledDate.add(Duration(days: template['interval'] as int));
      }
    });
  }

  void _selectDate(BuildContext context, DateTime initialDate, void Function(DateTime) onDateSelected) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (date != null) {
      onDateSelected(date);
    }
  }

  void _selectNextDueDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? _scheduledDate.add(const Duration(days: 365)),
      firstDate: _scheduledDate,
      lastDate: DateTime(2030),
    );
    
    if (date != null) {
      setState(() => _nextDueDate = date);
    }
  }

  void _selectReminderDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? _scheduledDate.subtract(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    
    if (date != null && mounted) {
      final localContext = context;
      final time = await showTimePicker(
        context: localContext,
        initialTime: TimeOfDay.fromDateTime(_reminderDate ?? DateTime.now()),
      );
      
      if (time != null && mounted) {
        setState(() {
          _reminderDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveVaccine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vaccine = Vaccine(
      id: widget.existingVaccine?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      animalId: widget.animalId ?? widget.existingVaccine!.animalId,
      name: _nameController.text.trim(),
      veterinarian: _veterinarianController.text.trim(),
      date: _scheduledDate,
      nextDueDate: _nextDueDate,
      batch: _batchController.text.trim().isEmpty ? null : _batchController.text.trim(),
      manufacturer: _manufacturerController.text.trim().isEmpty ? null : _manufacturerController.text.trim(),
      dosage: _dosageController.text.trim().isEmpty ? null : _dosageController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isRequired: _isRequired,
      reminderDate: _reminderDate,
      status: _status,
      createdAt: widget.existingVaccine?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.existingVaccine == null) {
        await ref.read(vaccinesProvider.notifier).addVaccine(vaccine);
        
        // If it's a series vaccine, create additional doses
        if (_isSeriesVaccine && _seriesCount > 1) {
          for (int i = 1; i < _seriesCount; i++) {
            final seriesDose = vaccine.copyWith(
              id: '${vaccine.id}_series_${i + 1}',
              date: _scheduledDate.add(Duration(days: i * _seriesIntervalDays)),
              nextDueDate: i == _seriesCount - 1 ? null : _scheduledDate.add(Duration(days: (i + 1) * _seriesIntervalDays)),
              notes: '${vaccine.notes ?? ''}\nDose ${i + 1} de $_seriesCount da série'.trim(),
            );
            await ref.read(vaccinesProvider.notifier).addVaccine(seriesDose);
          }
        }
      } else {
        await ref.read(vaccinesProvider.notifier).updateVaccine(vaccine);
      }

      if (mounted) {
        widget.onScheduled?.call();
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingVaccine == null 
                ? 'Vacina agendada com sucesso!' 
                : 'Vacina atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar vacina: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}