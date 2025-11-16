import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../../../animals/presentation/providers/animals_providers.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointments_providers.dart';

class AddAppointmentForm extends ConsumerStatefulWidget {
  final Appointment? initialAppointment;
  final bool isEditing;

  const AddAppointmentForm({
    super.key,
    this.initialAppointment,
    this.isEditing = false,
  });

  @override
  ConsumerState<AddAppointmentForm> createState() => _AddAppointmentFormState();
}

class _AddAppointmentFormState extends ConsumerState<AddAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _veterinarianController;
  late final TextEditingController _reasonController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _notesController;
  late final TextEditingController _costController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  AppointmentStatus _selectedStatus = AppointmentStatus.scheduled;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final appointment = widget.initialAppointment;

    _veterinarianController = TextEditingController(
      text: appointment?.veterinarianName ?? '',
    );

    _reasonController = TextEditingController(text: appointment?.reason ?? '');

    _diagnosisController = TextEditingController(
      text: appointment?.diagnosis ?? '',
    );

    _notesController = TextEditingController(text: appointment?.notes ?? '');

    _costController = TextEditingController(
      text: appointment?.cost?.toString() ?? '',
    );
    if (appointment != null) {
      _selectedDate = appointment.date;
      _selectedTime = TimeOfDay.fromDateTime(appointment.date);
      _selectedStatus = appointment.status;
    } else {
      final now = DateTime.now();
      _selectedDate = now;
      _selectedTime = TimeOfDay(hour: now.hour + 1, minute: 0);
    }
  }

  @override
  void dispose() {
    _veterinarianController.dispose();
    _reasonController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedAnimal = ref.watch(selectedAnimalProvider);

    if (selectedAnimal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Adicionar Consulta')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhum animal selecionado',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Text(
                'Selecione um animal primeiro',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Consulta' : 'Nova Consulta'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitForm,
            child: Text(
              widget.isEditing ? 'Salvar' : 'Adicionar',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    selectedAnimal.name.isNotEmpty
                        ? selectedAnimal.name[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAnimal.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${selectedAnimal.species} • ${selectedAnimal.breed}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data e Hora',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildDateField(context)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTimeField(context)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _veterinarianController,
                    decoration: const InputDecoration(
                      labelText: 'Veterinário',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome do veterinário é obrigatório';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Motivo da Consulta',
                      prefixIcon: Icon(Icons.medical_services),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Motivo da consulta é obrigatório';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),
                  if (widget.isEditing) ...[
                    DropdownButtonFormField<AppointmentStatus>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                      items: AppointmentStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(_getStatusDisplay(status)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _diagnosisController,
                    decoration: const InputDecoration(
                      labelText: 'Diagnóstico (opcional)',
                      prefixIcon: Icon(Icons.assignment),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Observações (opcional)',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Valor (opcional)',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final cost = double.tryParse(
                          value.replaceAll(',', '.'),
                        );
                        if (cost == null || cost < 0) {
                          return 'Valor inválido';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 8),
            Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20),
            const SizedBox(width: 8),
            Text(_selectedTime.format(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedAnimal = ref.read(selectedAnimalProvider);
      if (selectedAnimal == null) return;
      final appointmentDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      double? cost;
      if (_costController.text.isNotEmpty) {
        cost = double.tryParse(_costController.text.replaceAll(',', '.'));
      }

      final appointment = Appointment(
        id: widget.initialAppointment?.id ?? UuidGenerator.generate(),
        animalId: selectedAnimal.id,
        veterinarianName: _veterinarianController.text.trim(),
        date: appointmentDate,
        reason: _reasonController.text.trim(),
        diagnosis: _diagnosisController.text.trim().isEmpty
            ? null
            : _diagnosisController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: _selectedStatus,
        cost: cost,
        createdAt: widget.initialAppointment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.isEditing) {
        success = await ref
            .read(appointmentsNotifierProvider.notifier)
            .updateAppointment(appointment);
      } else {
        success = await ref
            .read(appointmentsNotifierProvider.notifier)
            .addAppointment(appointment);
      }

      if (success && mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Consulta atualizada com sucesso'
                  : 'Consulta agendada com sucesso',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        final errorMessage = ref.read(appointmentsNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Erro ao salvar consulta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getStatusDisplay(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Agendada';
      case AppointmentStatus.completed:
        return 'Realizada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.inProgress:
        return 'Em andamento';
    }
  }
}
