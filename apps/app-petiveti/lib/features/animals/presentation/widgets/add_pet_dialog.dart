import 'package:core/core.dart' hide FormState, Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/dialogs/pet_form_dialog.dart';
import '../../../../shared/widgets/form_components/form_components.dart';
import '../../../../shared/widgets/sections/form_section_widget.dart';
import '../../data/breed_suggestions.dart';
import '../../domain/entities/animal.dart';
import '../../domain/entities/animal_enums.dart';
import '../providers/animals_providers.dart';

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
  final _microchipController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _allergyInputController = TextEditingController();

  AnimalSpecies _selectedSpecies = AnimalSpecies.dog;
  AnimalGender _selectedGender = AnimalGender.male;
  DateTime _selectedBirthDate = DateTime.now().subtract(
    const Duration(days: 365),
  );
  bool _isLoading = false;
  bool _isCastrated = false;
  String? _selectedBloodType;
  List<String> _allergies = [];

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
      _microchipController.text = animal.microchipNumber ?? '';
      _veterinarianController.text = animal.preferredVeterinarian ?? '';
      _insuranceController.text = animal.insuranceInfo ?? '';
      _selectedSpecies = animal.species;
      _selectedGender = animal.gender;
      _selectedBirthDate =
          animal.birthDate ??
          DateTime.now().subtract(const Duration(days: 365));
      _isCastrated = animal.isCastrated;
      _selectedBloodType = animal.bloodType;
      _allergies = animal.allergies?.toList() ?? [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    _microchipController.dispose();
    _veterinarianController.dispose();
    _insuranceController.dispose();
    _allergyInputController.dispose();
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
            _buildHealthInfoSection(),
            const SizedBox(height: 20),
            _buildCareSection(),
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
    final breeds = getBreedsForSpecies(_selectedSpecies);

    return FormSectionWidget(
      title: 'Características Físicas',
      icon: Icons.straighten,
      children: [
        Row(
          children: [
            Expanded(
              child: Autocomplete<String>(
                initialValue: TextEditingValue(text: _breedController.text),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return breeds.take(10);
                  }
                  return breeds.where((breed) => breed
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selection) {
                  _breedController.text = selection;
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  if (fieldController.text.isEmpty &&
                      _breedController.text.isNotEmpty) {
                    fieldController.text = _breedController.text;
                  }
                  return TextFormField(
                    controller: fieldController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Raça *',
                      hintText: 'Digite para buscar...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pets),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (value) {
                      _breedController.text = value;
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Raça é obrigatória';
                      }
                      return null;
                    },
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 200,
                          maxWidth: 300,
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              dense: true,
                              title: Text(option),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
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

  Widget _buildHealthInfoSection() {
    final bloodTypeOptions = getBloodTypesForSpecies(_selectedSpecies);

    return FormSectionWidget(
      title: 'Informações de Saúde',
      icon: Icons.local_hospital,
      children: [
        // Castrated toggle
        SwitchListTile(
          title: const Text('Castrado(a)'),
          subtitle: Text(
            _isCastrated ? 'Pet castrado' : 'Pet não castrado',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          value: _isCastrated,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return null;
          }),
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            setState(() {
              _isCastrated = value;
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _microchipController,
                decoration: const InputDecoration(
                  labelText: 'Microchip',
                  hintText: 'Número do microchip',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.memory),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedBloodType,
                decoration: const InputDecoration(
                  labelText: 'Tipo Sanguíneo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.bloodtype),
                ),
                items: bloodTypeOptions.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodType = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Allergies section
        _buildAllergiesSection(),
      ],
    );
  }

  Widget _buildAllergiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber, size: 20, color: AppColors.warning),
            const SizedBox(width: 8),
            Text(
              'Alergias',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Allergy chips
        if (_allergies.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergies.map((allergy) {
              return Chip(
                label: Text(allergy),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _allergies.remove(allergy);
                  });
                },
                backgroundColor:
                    AppColors.warning.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        // Add allergy autocomplete
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return commonAllergies
                  .where((a) => !_allergies.contains(a))
                  .take(5);
            }
            return commonAllergies
                .where((allergy) =>
                    allergy
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()) &&
                    !_allergies.contains(allergy))
                .take(10);
          },
          onSelected: (String selection) {
            setState(() {
              _allergies.add(selection);
              _allergyInputController.clear();
            });
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              controller: fieldController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Digite para adicionar alergia...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.add),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    final text = fieldController.text.trim();
                    if (text.isNotEmpty && !_allergies.contains(text)) {
                      setState(() {
                        _allergies.add(text);
                        fieldController.clear();
                      });
                    }
                  },
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              onFieldSubmitted: (value) {
                final text = value.trim();
                if (text.isNotEmpty && !_allergies.contains(text)) {
                  setState(() {
                    _allergies.add(text);
                    fieldController.clear();
                  });
                }
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                    maxWidth: 300,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.add, size: 16),
                        title: Text(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCareSection() {
    return FormSectionWidget(
      title: 'Cuidados',
      icon: Icons.medical_services,
      children: [
        TextFormField(
          controller: _veterinarianController,
          decoration: const InputDecoration(
            labelText: 'Veterinário Preferencial',
            hintText: 'Nome ou clínica veterinária',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _insuranceController,
          decoration: const InputDecoration(
            labelText: 'Plano de Saúde Pet',
            hintText: 'Operadora / número do plano',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.health_and_safety),
          ),
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
        // New health fields
        isCastrated: _isCastrated,
        microchipNumber: _microchipController.text.trim().isEmpty
            ? null
            : _microchipController.text.trim(),
        bloodType: _selectedBloodType,
        allergies: _allergies.isEmpty ? null : _allergies,
        preferredVeterinarian: _veterinarianController.text.trim().isEmpty
            ? null
            : _veterinarianController.text.trim(),
        insuranceInfo: _insuranceController.text.trim().isEmpty
            ? null
            : _insuranceController.text.trim(),
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
