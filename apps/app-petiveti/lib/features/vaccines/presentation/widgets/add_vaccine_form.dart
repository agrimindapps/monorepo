import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../../../animals/domain/entities/animal.dart';
import '../../../animals/presentation/providers/animals_provider.dart';
import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';

class AddVaccineForm extends ConsumerStatefulWidget {
  final Vaccine? vaccine; // For editing
  final String? initialAnimalId;

  const AddVaccineForm({super.key, this.vaccine, this.initialAnimalId});

  @override
  ConsumerState<AddVaccineForm> createState() => _AddVaccineFormState();
}

class _AddVaccineFormState extends ConsumerState<AddVaccineForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _batchController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  Animal? _selectedAnimal;
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextDueDate;
  DateTime? _reminderDate;
  bool _isRequired = true;
  VaccineStatus _status = VaccineStatus.scheduled;
  bool _isLoading = false;
  final List<String> _commonVaccines = [
    'V10 (Múltipla)',
    'V8 (Múltipla)',
    'Antirrábica',
    'Giárdia',
    'Gripe Canina',
    'Leishmaniose',
    'FeLV (Leucemia Felina)',
    'FIV (AIDS Felina)',
    'Tríplice Felina',
    'Quíntupla Felina',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.vaccine != null) {
      final vaccine = widget.vaccine!;
      _nameController.text = vaccine.name;
      _veterinarianController.text = vaccine.veterinarian;
      _batchController.text = vaccine.batch ?? '';
      _manufacturerController.text = vaccine.manufacturer ?? '';
      _dosageController.text = vaccine.dosage ?? '';
      _notesController.text = vaccine.notes ?? '';
      _selectedDate = vaccine.date;
      _nextDueDate = vaccine.nextDueDate;
      _reminderDate = vaccine.reminderDate;
      _isRequired = vaccine.isRequired;
      _status = vaccine.status;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(animalsNotifierProvider.notifier).loadAnimals();
    });
  }

  @override
  void dispose() {
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
    final animalsState = ref.watch(animalsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vaccine != null ? 'Editar Vacina' : 'Nova Vacina'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveVaccine,
            child: Text(
              'Salvar',
              style: TextStyle(
                color: _isLoading
                    ? theme.disabledColor
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (animalsState.animals.isNotEmpty) ...[
              Text(
                'Animal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Animal>(
                initialValue: _selectedAnimal,
                decoration: InputDecoration(
                  hintText: 'Selecione um animal',
                  prefixIcon: const Icon(Icons.pets),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: animalsState.animals.map((animal) {
                  return DropdownMenuItem(
                    value: animal,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primary.withAlpha(
                            51,
                          ),
                          child: Text(
                            animal.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                animal.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${animal.species} • ${animal.breed}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    153,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (animal) {
                  setState(() {
                    _selectedAnimal = animal;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione um animal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Nome da Vacina',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Ex: V10 (Múltipla)',
                prefixIcon: const Icon(Icons.vaccines),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (value) {
                    _nameController.text = value;
                  },
                  itemBuilder: (context) => _commonVaccines
                      .map(
                        (vaccine) =>
                            PopupMenuItem(value: vaccine, child: Text(vaccine)),
                      )
                      .toList(),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome da vacina é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Veterinário',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _veterinarianController,
              decoration: InputDecoration(
                hintText: 'Dr. João Silva',
                prefixIcon: const Icon(Icons.medical_services),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome do veterinário é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Data de Aplicação',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(_formatDate(_selectedDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectDate(context, isApplicationDate: true),
            ),
            const SizedBox(height: 16),
            Text(
              'Próxima Dose (Opcional)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
              leading: const Icon(Icons.schedule),
              title: Text(
                _nextDueDate != null
                    ? _formatDate(_nextDueDate!)
                    : 'Sem próxima dose',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_nextDueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _nextDueDate = null),
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => _selectDate(context, isApplicationDate: false),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<VaccineStatus>(
                        initialValue: _status,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: VaccineStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.displayText),
                          );
                        }).toList(),
                        onChanged: (status) {
                          if (status != null) {
                            setState(() => _status = status);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      'Obrigatória',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Switch(
                      value: _isRequired,
                      onChanged: (value) {
                        setState(() => _isRequired = value);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Informações Adicionais',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _batchController,
              decoration: InputDecoration(
                labelText: 'Lote',
                hintText: 'Ex: 123456',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _manufacturerController,
              decoration: InputDecoration(
                labelText: 'Fabricante',
                hintText: 'Ex: Laboratório ABC',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosageController,
              decoration: InputDecoration(
                labelText: 'Dosagem',
                hintText: 'Ex: 1ml subcutâneo',
                prefixIcon: const Icon(Icons.medical_information),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Observações',
                hintText: 'Informações adicionais sobre a vacina...',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_nextDueDate != null) ...[
              Text(
                'Lembrete',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
                leading: const Icon(Icons.notifications),
                title: Text(
                  _reminderDate != null
                      ? _formatDate(_reminderDate!)
                      : 'Sem lembrete',
                ),
                subtitle: _reminderDate != null
                    ? const Text('Você será notificado nesta data')
                    : const Text('Toque para agendar um lembrete'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_reminderDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _reminderDate = null),
                      ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => _selectReminderDate(context),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveVaccine,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.vaccine != null
                            ? 'Atualizar Vacina'
                            : 'Salvar Vacina',
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isApplicationDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isApplicationDate
          ? _selectedDate
          : (_nextDueDate ?? _selectedDate.add(const Duration(days: 30))),
      firstDate: isApplicationDate
          ? DateTime.now().subtract(const Duration(days: 365))
          : _selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isApplicationDate) {
          _selectedDate = picked;
          if (_nextDueDate != null && _nextDueDate!.isBefore(picked)) {
            _nextDueDate = null;
          }
        } else {
          _nextDueDate = picked;
        }
      });
    }
  }

  Future<void> _selectReminderDate(BuildContext context) async {
    if (_nextDueDate == null) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _reminderDate ?? _nextDueDate!.subtract(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: _nextDueDate!,
    );

    if (picked != null) {
      setState(() {
        _reminderDate = picked;
      });
    }
  }

  Future<void> _saveVaccine() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAnimal == null) return;

    setState(() => _isLoading = true);

    try {
      final vaccine = Vaccine(
        id: widget.vaccine?.id ?? UuidGenerator.generate(),
        animalId: _selectedAnimal!.id,
        name: _nameController.text.trim(),
        veterinarian: _veterinarianController.text.trim(),
        date: _selectedDate,
        nextDueDate: _nextDueDate,
        batch: _batchController.text.trim().isEmpty
            ? null
            : _batchController.text.trim(),
        manufacturer: _manufacturerController.text.trim().isEmpty
            ? null
            : _manufacturerController.text.trim(),
        dosage: _dosageController.text.trim().isEmpty
            ? null
            : _dosageController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isRequired: _isRequired,
        isCompleted:
            _status == VaccineStatus.applied ||
            _status == VaccineStatus.completed,
        reminderDate: _reminderDate,
        status: _status,
        createdAt: widget.vaccine?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.vaccine != null) {
        await ref.read(vaccinesProvider.notifier).updateVaccine(vaccine);
      } else {
        await ref.read(vaccinesProvider.notifier).addVaccine(vaccine);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.vaccine != null
                  ? 'Vacina atualizada com sucesso'
                  : 'Vacina adicionada com sucesso',
            ),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
