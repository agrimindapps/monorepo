import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/dialogs/pet_form_dialog.dart';
import '../../../../shared/widgets/form_components/form_components.dart';
import '../../../../shared/widgets/sections/form_section_widget.dart';
import '../../../animals/domain/entities/animal.dart';
import '../../../animals/presentation/providers/animals_providers.dart';
import '../../domain/entities/medication.dart';
import '../providers/medications_provider.dart';

class AddMedicationDialog extends ConsumerStatefulWidget {
  final Medication? medication;
  final String? initialAnimalId;

  const AddMedicationDialog({super.key, this.medication, this.initialAnimalId});

  @override
  ConsumerState<AddMedicationDialog> createState() =>
      _AddMedicationDialogState();
}

class _AddMedicationDialogState extends ConsumerState<AddMedicationDialog> {
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

  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(animalsProvider.notifier).loadAnimals();
    });
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
      title: 'Medicamentos',
      subtitle: 'Controle os medicamentos do seu pet',
      headerIcon: Icons.medication,
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
            _buildDosageSection(),
            _buildPeriodSection(),
            _buildAdditionalInfoSection(),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTitle() {
    return Center(
      child: Text(
        _isEditing ? 'Editar Medicamento' : 'Novo Medicamento',
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
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nome do Medicamento *',
            hintText: 'Ex: Amoxicilina',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Nome é obrigatório';
            if (value.length < 2) {
              return 'Nome deve ter pelo menos 2 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        PetiVetiFormComponents.medicationTypeDropdown(
          value: _selectedType.name,
          onChanged: (value) {
            if (value is String) {
              final type = MedicationType.values.firstWhere(
                (t) => t.name == value,
              );
              setState(() => _selectedType = type);
            }
          },
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildDosageSection() {
    return FormSectionWidget(
      title: 'Dosagem e Frequência',
      icon: Icons.schedule,
      children: [
        TextFormField(
          controller: _dosageController,
          decoration: InputDecoration(
            labelText: 'Dosagem *',
            hintText: 'Ex: 250mg, 1 comprimido',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Dosagem é obrigatória';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _frequencyController,
          decoration: InputDecoration(
            labelText: 'Frequência *',
            hintText: 'Ex: 2x ao dia, A cada 8 horas',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Frequência é obrigatória';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _durationController,
          decoration: InputDecoration(
            labelText: 'Duração (opcional)',
            hintText: 'Ex: 7 dias, 2 semanas',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSection() {
    return FormSectionWidget(
      title: 'Período do Tratamento',
      icon: Icons.date_range,
      children: [
        Row(
          children: [
            Expanded(
              child: DateTimePickerField.date(
                value: _startDate,
                label: 'Data de Início',
                onChanged: (date) {
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                      if (_endDate.isBefore(_startDate)) {
                        _endDate = _startDate.add(const Duration(days: 1));
                      }
                    });
                  }
                },
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DateTimePickerField.date(
                value: _endDate,
                label: 'Data de Fim',
                onChanged: (date) {
                  if (date != null) setState(() => _endDate = date);
                },
                firstDate: _startDate.add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return FormSectionWidget(
      title: 'Informações Adicionais',
      icon: Icons.more_horiz,
      children: [
        TextFormField(
          controller: _prescribedByController,
          decoration: InputDecoration(
            labelText: 'Prescrito por (opcional)',
            hintText: 'Nome do veterinário',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        PetiVetiFormComponents.notesTreatment(
          controller: _notesController,
          isRequired: false,
        ),
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
            itemName: 'Medicamento',
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
      final medication = Medication(
        id: widget.medication?.id ??
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
        await ref.read(medicationsProvider.notifier).updateMedication(
          medication,
        );
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
