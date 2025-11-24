import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';

import '../../../../features/animals/domain/entities/animal.dart';
import '../../../../features/animals/presentation/providers/animals_providers.dart';
import '../../../../shared/widgets/form_components/form_components.dart';
import '../../domain/entities/medication.dart';
import '../providers/medications_provider.dart';

class AddMedicationForm extends ConsumerStatefulWidget {
  final Medication? medication;
  final String? initialAnimalId;

  const AddMedicationForm({super.key, this.medication, this.initialAnimalId});

  @override
  ConsumerState<AddMedicationForm> createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends ConsumerState<AddMedicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  final _prescribedByController = TextEditingController();

  MedicationType _selectedType = MedicationType.other;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String? _selectedAnimalId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.medication != null) {
      final medication = widget.medication!;
      _nameController.text = medication.name;
      _dosageController.text = medication.dosage;
      _frequencyController.text = medication.frequency;
      _durationController.text = medication.duration ?? '';
      _notesController.text = medication.notes ?? '';
      _prescribedByController.text = medication.prescribedBy ?? '';
      _selectedType = medication.type;
      _startDate = medication.startDate;
      _endDate = medication.endDate;
      _selectedAnimalId = medication.animalId;
    } else {
      _selectedAnimalId = widget.initialAnimalId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    _prescribedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalsState = ref.watch(animalsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.medication != null ? 'Editar Medicamento' : 'Novo Medicamento',
        ),
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
                    onPressed: () => ref
                        .read(animalsNotifierProvider.notifier)
                        .loadAnimals(),
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
            _buildNameField(),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildDosageField(),
            const SizedBox(height: 16),
            _buildFrequencyField(),
            const SizedBox(height: 16),
            _buildDurationField(),
            const SizedBox(height: 16),
            _buildDateSection(),
            const SizedBox(height: 16),
            _buildPrescribedByField(),
            const SizedBox(height: 16),
            _buildNotesField(),
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

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nome do Medicamento',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.medication),
        hintText: 'Ex: Amoxicilina',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nome é obrigatório';
        }
        if (value.length < 2) {
          return 'Nome deve ter pelo menos 2 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildTypeSelector() {
    return PetiVetiFormComponents.medicationTypeDropdown(
      value: _selectedType.name,
      onChanged: (dynamic value) {
        if (value is String) {
          final type = MedicationType.values.firstWhere((t) => t.name == value);
          setState(() => _selectedType = type);
        }
      },
      isRequired: true,
    );
  }

  Widget _buildDosageField() {
    return TextFormField(
      controller: _dosageController,
      decoration: const InputDecoration(
        labelText: 'Dosagem',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.colorize),
        hintText: 'Ex: 250mg, 1 comprimido',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Dosagem é obrigatória';
        }
        return null;
      },
    );
  }

  Widget _buildFrequencyField() {
    return TextFormField(
      controller: _frequencyController,
      decoration: const InputDecoration(
        labelText: 'Frequência',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.schedule),
        hintText: 'Ex: 2x ao dia, A cada 8 horas',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Frequência é obrigatória';
        }
        return null;
      },
    );
  }

  Widget _buildDurationField() {
    return TextFormField(
      controller: _durationController,
      decoration: const InputDecoration(
        labelText: 'Duração (opcional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.timer),
        hintText: 'Ex: 7 dias, 2 semanas',
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Período do Tratamento',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'Data de Início',
                _startDate,
                (date) => setState(() {
                  _startDate = date;
                  if (_endDate.isBefore(_startDate)) {
                    _endDate = _startDate.add(const Duration(days: 1));
                  }
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                'Data de Fim',
                _endDate,
                (date) => setState(() => _endDate = date),
                minDate: _startDate.add(const Duration(days: 1)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime date,
    void Function(DateTime) onChanged, {
    DateTime? minDate,
  }) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate:
              minDate ?? DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selectedDate != null) {
          onChanged(selectedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        ),
      ),
    );
  }

  Widget _buildPrescribedByField() {
    return TextFormField(
      controller: _prescribedByController,
      decoration: const InputDecoration(
        labelText: 'Prescrito por (opcional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
        hintText: 'Nome do veterinário',
      ),
    );
  }

  Widget _buildNotesField() {
    return PetiVetiFormComponents.notesTreatment(
      controller: _notesController,
      isRequired: false,
    );
  }

  Widget _buildSubmitButton() {
    return widget.medication != null
        ? PetiVetiFormComponents.submitUpdate(
            onSubmit: _submitForm,
            isLoading: _isSubmitting,
          )
        : PetiVetiFormComponents.submitCreate(
            onSubmit: _submitForm,
            isLoading: _isSubmitting,
            itemName: 'Medicamento',
          );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAnimalId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um animal')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final medication = Medication(
        id:
            widget.medication?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        animalId: _selectedAnimalId!,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        duration: _durationController.text.isNotEmpty
            ? _durationController.text.trim()
            : null,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text.trim()
            : null,
        prescribedBy: _prescribedByController.text.isNotEmpty
            ? _prescribedByController.text.trim()
            : null,
        type: _selectedType,
        createdAt: widget.medication?.createdAt ?? now,
        updatedAt: now,
        isDeleted: false,
      );

      if (widget.medication != null) {
        await ref
            .read(medicationsProvider.notifier)
            .updateMedication(medication);
      } else {
        await ref.read(medicationsProvider.notifier).addMedication(medication);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.medication != null
                  ? 'Medicamento atualizado com sucesso!'
                  : 'Medicamento cadastrado com sucesso!',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar medicamento: $e'),
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
