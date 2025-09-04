import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reminder.dart';
import '../providers/reminders_provider.dart';
import '../../../../features/animals/presentation/providers/animals_provider.dart';
import '../../../../features/animals/domain/entities/animal.dart';

class AddReminderForm extends ConsumerStatefulWidget {
  final Reminder? reminder;
  final String? initialAnimalId;
  final String userId;

  const AddReminderForm({
    super.key,
    this.reminder,
    this.initialAnimalId,
    required this.userId,
  });

  @override
  ConsumerState<AddReminderForm> createState() => _AddReminderFormState();
}

class _AddReminderFormState extends ConsumerState<AddReminderForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _recurringDaysController = TextEditingController();

  ReminderType _selectedType = ReminderType.general;
  ReminderPriority _selectedPriority = ReminderPriority.medium;
  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _scheduledTime = TimeOfDay.now();
  String? _selectedAnimalId;
  bool _isRecurring = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    // Load animals when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(animalsProvider.notifier).loadAnimals();
    });
  }

  void _initializeForm() {
    if (widget.reminder != null) {
      final reminder = widget.reminder!;
      _titleController.text = reminder.title;
      _descriptionController.text = reminder.description;
      _selectedType = reminder.type;
      _selectedPriority = reminder.priority;
      _scheduledDate = reminder.scheduledDate;
      _scheduledTime = TimeOfDay.fromDateTime(reminder.scheduledDate);
      _selectedAnimalId = reminder.animalId;
      _isRecurring = reminder.isRecurring;
      if (reminder.recurringDays != null) {
        _recurringDaysController.text = reminder.recurringDays.toString();
      }
    } else {
      _selectedAnimalId = widget.initialAnimalId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _recurringDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalsState = ref.watch(animalsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder != null ? 'Editar Lembrete' : 'Novo Lembrete'),
        elevation: 0,
      ),
      body: animalsState.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : animalsState.error != null 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erro ao carregar animais: ${animalsState.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(animalsProvider.notifier).loadAnimals(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _buildForm(animalsState.animals),
    );
  }

  Widget _buildForm(List<Animal> animals) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimalSelector(animals),
            const SizedBox(height: 20),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildPrioritySelector(),
            const SizedBox(height: 16),
            _buildDateTimeSection(),
            const SizedBox(height: 16),
            _buildRecurringSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalSelector(List<Animal> animals) {
    if (animals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.pets, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text('Nenhum animal encontrado'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/animals/add'),
                child: const Text('Cadastrar Animal'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Animal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedAnimalId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Selecione um animal',
            prefixIcon: Icon(Icons.pets),
          ),
          items: animals.map((animal) {
            return DropdownMenuItem(
              value: animal.id,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getSpeciesColor(animal.species.name),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(animal.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedAnimalId = value),
          validator: (value) => value == null ? 'Selecione um animal' : null,
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Título do Lembrete',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
        hintText: 'Ex: Vacina da raiva, Consulta veterinária',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Título é obrigatório';
        }
        if (value.length < 3) {
          return 'Título deve ter pelo menos 3 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descrição',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
        hintText: 'Detalhes sobre o lembrete',
      ),
      maxLines: 3,
      maxLength: 500,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Descrição é obrigatória';
        }
        return null;
      },
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Lembrete',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ReminderType>(
          value: _selectedType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: ReminderType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Row(
                children: [
                  Icon(_getTypeIcon(type), size: 20),
                  const SizedBox(width: 8),
                  Text(_getTypeDisplayName(type)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedType = value!),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prioridade',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ReminderPriority>(
          value: _selectedPriority,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.priority_high),
          ),
          items: ReminderPriority.values.map((priority) {
            return DropdownMenuItem(
              value: priority,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(priority),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(_getPriorityDisplayName(priority)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedPriority = value!),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data e Hora',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildDateField()),
            const SizedBox(width: 12),
            Expanded(child: _buildTimeField()),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: _scheduledDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selectedDate != null) {
          setState(() => _scheduledDate = selectedDate);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          '${_scheduledDate.day.toString().padLeft(2, '0')}/${_scheduledDate.month.toString().padLeft(2, '0')}/${_scheduledDate.year}',
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return InkWell(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: _scheduledTime,
        );
        if (selectedTime != null) {
          setState(() => _scheduledTime = selectedTime);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Hora',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.access_time),
        ),
        child: Text(
          '${_scheduledTime.hour.toString().padLeft(2, '0')}:${_scheduledTime.minute.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  Widget _buildRecurringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('Lembrete recorrente'),
          subtitle: const Text('Repetir este lembrete periodicamente'),
          value: _isRecurring,
          onChanged: (value) => setState(() => _isRecurring = value!),
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _recurringDaysController,
            decoration: const InputDecoration(
              labelText: 'Repetir a cada (dias)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.repeat),
              hintText: 'Ex: 7 (semanal), 30 (mensal)',
            ),
            keyboardType: TextInputType.number,
            validator: _isRecurring
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o intervalo de dias';
                    }
                    final days = int.tryParse(value);
                    if (days == null || days < 1) {
                      return 'Informe um número válido de dias';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                widget.reminder != null ? 'Salvar Alterações' : 'Criar Lembrete',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Color _getSpeciesColor(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
      case 'cachorro':
        return Colors.blue;
      case 'cat':
      case 'gato':
        return Colors.orange;
      case 'bird':
      case 'pássaro':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getTypeDisplayName(ReminderType type) {
    switch (type) {
      case ReminderType.vaccine:
        return 'Vacina';
      case ReminderType.medication:
        return 'Medicamento';
      case ReminderType.appointment:
        return 'Consulta';
      case ReminderType.weight:
        return 'Pesagem';
      case ReminderType.general:
        return 'Geral';
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
        return Icons.notification_important;
    }
  }

  String _getPriorityDisplayName(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return 'Baixa';
      case ReminderPriority.medium:
        return 'Média';
      case ReminderPriority.high:
        return 'Alta';
      case ReminderPriority.urgent:
        return 'Urgente';
    }
  }

  Color _getPriorityColor(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return Colors.green;
      case ReminderPriority.medium:
        return Colors.orange;
      case ReminderPriority.high:
        return Colors.red;
      case ReminderPriority.urgent:
        return Colors.purple;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAnimalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um animal')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );

      final reminder = Reminder(
        id: widget.reminder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        animalId: _selectedAnimalId!,
        userId: widget.userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        scheduledDate: scheduledDateTime,
        type: _selectedType,
        priority: _selectedPriority,
        status: widget.reminder?.status ?? ReminderStatus.active,
        isRecurring: _isRecurring,
        recurringDays: _isRecurring && _recurringDaysController.text.isNotEmpty
            ? int.tryParse(_recurringDaysController.text)
            : null,
        createdAt: widget.reminder?.createdAt ?? now,
        updatedAt: now,
      );

      bool success;
      if (widget.reminder != null) {
        success = await ref.read(remindersProvider.notifier).updateReminder(reminder);
      } else {
        success = await ref.read(remindersProvider.notifier).addReminder(reminder);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.reminder != null 
                  ? 'Lembrete atualizado com sucesso!'
                  : 'Lembrete criado com sucesso!',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar lembrete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}