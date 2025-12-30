import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../../../../shared/widgets/dialogs/pet_form_dialog.dart';
import '../../../../shared/widgets/form_components/form_components.dart';
import '../../../../shared/widgets/sections/form_section_widget.dart';
import '../../../animals/domain/entities/animal.dart';
import '../../../animals/presentation/providers/animals_providers.dart';
import '../../domain/entities/vaccine.dart';
import '../providers/vaccines_provider.dart';

class AddVaccineDialog extends ConsumerStatefulWidget {
  final Vaccine? vaccine;
  final String? initialAnimalId;

  const AddVaccineDialog({super.key, this.vaccine, this.initialAnimalId});

  @override
  ConsumerState<AddVaccineDialog> createState() => _AddVaccineDialogState();
}

class _AddVaccineDialogState extends ConsumerState<AddVaccineDialog> {
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

  bool get _isEditing => widget.vaccine != null;

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
      ref.read(animalsProvider.notifier).loadAnimals();
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
    final animalsState = ref.watch(animalsProvider);

    // Set selected animal from initial data or widget parameter
    if (_selectedAnimal == null && animalsState.animals.isNotEmpty) {
      final initialId = widget.vaccine?.animalId ?? widget.initialAnimalId;
      if (initialId != null) {
        for (final animal in animalsState.animals) {
          if (animal.id == initialId) {
            _selectedAnimal = animal;
            break;
          }
        }
      }
    }

    return PetFormDialog(
      title: 'Vacinas',
      subtitle: 'Registre as vacinas do seu pet',
      headerIcon: Icons.vaccines,
      isLoading: _isLoading,
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
            _buildVaccineInfoSection(),
            _buildDatesSection(),
            _buildStatusSection(),
            _buildAdditionalInfoSection(),
            if (_nextDueDate != null) _buildReminderSection(),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTitle() {
    return Center(
      child: Text(
        _isEditing ? 'Editar Vacina' : 'Nova Vacina',
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
    
    if (animals.isEmpty) return const SizedBox.shrink();

    return FormSectionWidget(
      title: 'Animal',
      icon: Icons.pets,
      children: [
        DropdownButtonFormField<Animal>(
          initialValue: _selectedAnimal,
          decoration: InputDecoration(
            hintText: 'Selecione um animal',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: animals.map((animal) {
            return DropdownMenuItem(
              value: animal,
              child: Text(animal.name),
            );
          }).toList(),
          onChanged: (animal) => setState(() => _selectedAnimal = animal),
          validator: (value) => value == null ? 'Selecione um animal' : null,
        ),
      ],
    );
  }

  Widget _buildVaccineInfoSection() {
    return FormSectionWidget(
      title: 'Informações da Vacina',
      icon: Icons.vaccines,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nome da Vacina *',
            hintText: 'Ex: V10 (Múltipla)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: PopupMenuButton<String>(
              icon: const Icon(Icons.arrow_drop_down),
              onSelected: (value) => _nameController.text = value,
              itemBuilder: (context) => _commonVaccines
                  .map((v) => PopupMenuItem(value: v, child: Text(v)))
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
        TextFormField(
          controller: _veterinarianController,
          decoration: InputDecoration(
            labelText: 'Veterinário *',
            hintText: 'Dr. João Silva',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome do veterinário é obrigatório';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDatesSection() {
    return FormSectionWidget(
      title: 'Datas',
      icon: Icons.calendar_today,
      children: [
        DateTimePickerField.date(
          value: _selectedDate,
          label: 'Data de Aplicação',
          onChanged: (date) {
            if (date != null) {
              setState(() {
                _selectedDate = date;
                if (_nextDueDate != null && _nextDueDate!.isBefore(date)) {
                  _nextDueDate = null;
                }
              });
            }
          },
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        ),
        const SizedBox(height: 16),
        DateTimePickerField.date(
          value: _nextDueDate,
          label: 'Próxima Dose (Opcional)',
          onChanged: (date) => setState(() => _nextDueDate = date),
          firstDate: _selectedDate,
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return FormSectionWidget(
      title: 'Status',
      icon: Icons.info_outline,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<VaccineStatus>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
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
                  if (status != null) setState(() => _status = status);
                },
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                const Text('Obrigatória'),
                Switch(
                  value: _isRequired,
                  onChanged: (value) => setState(() => _isRequired = value),
                ),
              ],
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
          controller: _batchController,
          decoration: InputDecoration(
            labelText: 'Lote',
            hintText: 'Ex: 123456',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _manufacturerController,
          decoration: InputDecoration(
            labelText: 'Fabricante',
            hintText: 'Ex: Laboratório ABC',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dosageController,
          decoration: InputDecoration(
            labelText: 'Dosagem',
            hintText: 'Ex: 1ml subcutâneo',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        PetiVetiFormComponents.notesGeneral(
          controller: _notesController,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return FormSectionWidget(
      title: 'Lembrete',
      icon: Icons.notifications,
      children: [
        DateTimePickerField.date(
          value: _reminderDate,
          label: 'Data do Lembrete',
          onChanged: (date) => setState(() => _reminderDate = date),
          firstDate: DateTime.now(),
          lastDate: _nextDueDate,
        ),
      ],
    );
  }

  Widget _buildSubmitSection() {
    return _isEditing
        ? PetiVetiFormComponents.submitUpdate(
            onSubmit: _saveVaccine,
            onCancel: () => Navigator.of(context).pop(),
            isLoading: _isLoading,
          )
        : PetiVetiFormComponents.submitCreate(
            onSubmit: _saveVaccine,
            onCancel: () => Navigator.of(context).pop(),
            isLoading: _isLoading,
            itemName: 'Vacina',
          );
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
}
