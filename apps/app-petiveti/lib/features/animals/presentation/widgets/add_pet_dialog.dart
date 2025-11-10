import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/dialogs/pet_form_dialog.dart';
import '../../../../shared/widgets/form_components/form_components.dart';
import '../../../../shared/widgets/sections/form_section_widget.dart';
import '../../domain/entities/animal.dart';
import '../../domain/entities/animal_enums.dart';
import '../providers/animals_provider.dart';

class AddPetDialog extends ConsumerStatefulWidget {
  final Animal? animal;

  const AddPetDialog({super.key, this.animal});

  @override
  ConsumerState<AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends ConsumerState<AddPetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _notesController = TextEditingController();

  AnimalSpecies _selectedSpecies = AnimalSpecies.dog;
  AnimalGender _selectedGender = AnimalGender.male;
  DateTime _selectedBirthDate = DateTime.now().subtract(
    const Duration(days: 365),
  );
  bool _isLoading = false;

  bool get _isEditing => widget.animal != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.animal != null) {
      final animal = widget.animal!;
      _nameController.text = animal.name;
      _breedController.text = animal.breed ?? '';
      _weightController.text = animal.weight?.toString() ?? '';
      _colorController.text = animal.color ?? '';
      _notesController.text = animal.notes ?? '';
      _selectedSpecies = animal.species;
      _selectedGender = animal.gender;
      _selectedBirthDate =
          animal.birthDate ??
          DateTime.now().subtract(const Duration(days: 365));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PetFormDialog(
      title: 'Gerenciar Pets',
      subtitle: 'Adicione e gerencie informações dos seus pets',
      headerIcon: Icons.pets,
      isLoading: _isLoading,
      confirmButtonText: _isEditing ? 'Salvar Alterações' : 'Cadastrar Pet',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: null, // Substituído pelo botão na seção
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormTitle(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 20),
            _buildPhysicalInfoSection(),
            const SizedBox(height: 20),
            _buildAdditionalInfoSection(),
            const SizedBox(height: 20),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTitle() {
    return Center(
      child: Text(
        _isEditing ? 'Editar Pet' : 'Cadastrar Novo Pet',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return FormSectionWidget(
      title: 'Informações Básicas',
      icon: Icons.info_outline,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome do Pet *',
            hintText: 'Ex: Rex, Mimi, Bob...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.pets, color: AppColors.secondary),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nome é obrigatório';
            }
            if (value.trim().length < 2) {
              return 'Nome deve ter pelo menos 2 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<AnimalSpecies>(
                initialValue: _selectedSpecies,
                decoration: const InputDecoration(
                  labelText: 'Espécie *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: AnimalSpecies.values.map((species) {
                  return DropdownMenuItem(
                    value: species,
                    child: Text(species.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecies = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Espécie é obrigatória' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<AnimalGender>(
                initialValue: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gênero *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wc),
                ),
                items: AnimalGender.values.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Gênero é obrigatório' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PetiVetiFormComponents.birthDate(
          value: _selectedBirthDate,
          onChanged: (date) {
            if (date != null) {
              setState(() {
                _selectedBirthDate = date;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPhysicalInfoSection() {
    return FormSectionWidget(
      title: 'Características Físicas',
      icon: Icons.straighten,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Raça *',
                  hintText: 'Ex: Labrador, Persa...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Raça é obrigatória';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Cor *',
                  hintText: 'Ex: Marrom, Preto...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.color_lens),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Cor é obrigatória';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: 'Peso (kg) *',
            hintText: 'Ex: 15.5',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.monitor_weight),
            suffixText: 'kg',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}$')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Peso é obrigatório';
            }
            final weight = double.tryParse(value.replaceAll(',', '.'));
            if (weight == null || weight <= 0) {
              return 'Peso deve ser um número maior que zero';
            }
            if (weight > 150) {
              return 'Peso deve ser menor que 150kg';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return FormSectionWidget(
      title: 'Informações Adicionais',
      icon: Icons.more_horiz,
      children: [
        PetiVetiFormComponents.notesGeneral(
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
            isLoading: _isLoading,
          )
        : PetiVetiFormComponents.submitCreate(
            onSubmit: _submitForm,
            onCancel: () => Navigator.of(context).pop(),
            isLoading: _isLoading,
            itemName: 'Pet',
          );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final weightText = _weightController.text.trim().replaceAll(',', '.');
      final weight = weightText.isEmpty ? null : double.parse(weightText);
      final now = DateTime.now();

      final animal = Animal(
        id:
            widget.animal?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'temp_user_id',
        name: _nameController.text.trim(),
        species: _selectedSpecies,
        breed: _breedController.text.trim().isEmpty
            ? null
            : _breedController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
        weight: weight,
        photoUrl: widget.animal?.photoUrl,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.animal?.createdAt ?? now,
        updatedAt: now,
      );
      if (_isEditing) {
        await ref.read(animalsProvider.notifier).updateAnimal(animal);
      } else {
        await ref.read(animalsProvider.notifier).addAnimal(animal);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Pet atualizado com sucesso!'
                  : 'Pet cadastrado com sucesso!',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar pet: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
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
}
