import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/dialogs/pet_form_dialog.dart';
import '../../../../shared/widgets/form_components/form_components.dart';
import '../../../../shared/widgets/sections/form_section_widget.dart';
import '../../../animals/domain/entities/animal.dart';
import '../../../animals/presentation/providers/animals_providers.dart';
import '../../domain/entities/reminder.dart';
import '../providers/reminders_providers.dart';

class AddReminderDialog extends ConsumerStatefulWidget {
  final Reminder? reminder;
  final String? initialAnimalId;
  final String userId;

  const AddReminderDialog({
    super.key,
    this.reminder,
    this.initialAnimalId,
    required this.userId,
  });

  @override
  ConsumerState<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends ConsumerState<AddReminderDialog> {
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

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
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

    if (animalsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (animalsState.error != null) {
      return Center(
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
      );
    }

    return PetFormDialog(
      title: 'Lembretes',
      subtitle: 'Configure lembretes importantes',
      headerIcon: Icons.notifications,
      isLoading: _isSubmitting,
      confirmButtonText: _isEditing ? 'Salvar' : 'Cadastrar',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: null,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormTitle(),
            const SizedBox(height: 16),
            _buildAnimalSection(animalsState.animals),
            _buildBasicInfoSection(),
            _buildTypeAndPrioritySection(),
            _buildDateTimeSection(),
            _buildRecurringSection(),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTitle() {
    return Center(
      child: Text(
        _isEditing ? 'Editar Lembrete' : 'Novo Lembrete',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildAnimalSection(List<Animal> animals) {
    // Se já temos um animal pré-selecionado, não mostrar o seletor
    if (widget.initialAnimalId != null && !_isEditing) {
      return const SizedBox.shrink();
    }
    
    return FormSectionWidget(
      title: 'Animal',
      icon: Icons.pets,
      children: [
        PetiVetiFormComponents.animalRequired(
          value: _selectedAnimalId,
          onChanged: (value) => setState(() => _selectedAnimalId = value),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return FormSectionWidget(
      title: 'Informações Básicas',
      icon: Icons.info_outline,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Título do Lembrete *',
            hintText: 'Ex: Vacina da raiva, Consulta veterinária',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Título é obrigatório';
            if (value.length < 3) {
              return 'Título deve ter pelo menos 3 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            labelText: 'Descrição *',
            hintText: 'Detalhes sobre o lembrete',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Descrição é obrigatória';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeAndPrioritySection() {
    return FormSectionWidget(
      title: 'Tipo e Prioridade',
      icon: Icons.settings,
      children: [
        PetiVetiFormComponents.reminderTypeDropdown(
          value: _selectedType.name,
          onChanged: (value) {
            if (value is String) {
              final type = ReminderType.values.firstWhere(
                (t) => t.name == value,
              );
              setState(() => _selectedType = type);
            }
          },
          isRequired: true,
        ),
        const SizedBox(height: 16),
        PetiVetiFormComponents.priorityDropdown(
          value: _selectedPriority.name,
          onChanged: (value) {
            if (value is String) {
              final priority = ReminderPriority.values.firstWhere(
                (p) => p.name == value,
              );
              setState(() => _selectedPriority = priority);
            }
          },
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    final scheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );

    return FormSectionWidget(
      title: 'Data e Hora',
      icon: Icons.schedule,
      children: [
        PetiVetiFormComponents.appointment(
          value: scheduledDateTime,
          onChanged: (dateTime) {
            if (dateTime != null) {
              setState(() {
                _scheduledDate = dateTime;
                _scheduledTime = TimeOfDay.fromDateTime(dateTime);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildRecurringSection() {
    return FormSectionWidget(
      title: 'Recorrência',
      icon: Icons.repeat,
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
            decoration: InputDecoration(
              labelText: 'Repetir a cada (dias)',
              hintText: 'Ex: 7 (semanal), 30 (mensal)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

  Widget _buildSubmitSection() {
    return _isEditing
        ? PetiVetiFormComponents.submitUpdate(
            onSubmit: _submitForm,
            onCancel: () => Navigator.of(context).pop(),
            isLoading: _isSubmitting,
          )
        : PetiVetiFormComponents.submitCreate(
            onSubmit: _submitForm,
            onCancel: () => Navigator.of(context).pop(),
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
        id: widget.reminder?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
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
        success = await ref.read(remindersProvider.notifier).updateReminder(
          reminder,
        );
      } else {
        success = await ref.read(remindersProvider.notifier).addReminder(
          reminder,
        );
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
