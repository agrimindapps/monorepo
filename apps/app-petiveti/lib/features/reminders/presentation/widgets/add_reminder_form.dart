import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

import '../../../../features/animals/domain/entities/animal.dart';
import '../../../../features/animals/presentation/providers/animals_provider.dart';
import '../../../../shared/widgets/form_components/form_components.dart';
import '../../domain/entities/reminder.dart';
import '../providers/reminders_provider.dart';

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
    return PetiVetiFormComponents.animalRequired(
      value: _selectedAnimalId,
      onChanged: (String? value) => setState(() => _selectedAnimalId = value),
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
    return PetiVetiFormComponents.reminderTypeDropdown(
      value: _selectedType.name,
      onChanged: (dynamic value) {
        // Converter string de volta para enum
        if (value is String) {
          final type = ReminderType.values.firstWhere((t) => t.name == value);
          setState(() => _selectedType = type);
        }
      },
      isRequired: true,
    );
  }

  Widget _buildPrioritySelector() {
    return PetiVetiFormComponents.priorityDropdown(
      value: _selectedPriority.name,
      onChanged: (dynamic value) {
        // Converter string de volta para enum
        if (value is String) {
          final priority = ReminderPriority.values.firstWhere((p) => p.name == value);
          setState(() => _selectedPriority = priority);
        }
      },
      isRequired: true,
    );
  }

  Widget _buildDateTimeSection() {
    // Combinar data e hora atuais em um DateTime
    final scheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    return PetiVetiFormComponents.appointment(
      value: scheduledDateTime,
      onChanged: (DateTime? dateTime) {
        if (dateTime != null) {
          setState(() {
            _scheduledDate = dateTime;
            _scheduledTime = TimeOfDay.fromDateTime(dateTime);
          });
        }
      },
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
    return widget.reminder != null
        ? PetiVetiFormComponents.submitUpdate(
            onSubmit: _submitForm,
            isLoading: _isSubmitting,
          )
        : PetiVetiFormComponents.submitCreate(
            onSubmit: _submitForm,
            isLoading: _isSubmitting,
            itemName: 'Lembrete',
          );
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