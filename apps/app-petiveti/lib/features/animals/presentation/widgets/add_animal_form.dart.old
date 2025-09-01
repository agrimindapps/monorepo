import 'package:flutter/material.dart';

import '../../domain/entities/animal.dart';
import '../../domain/entities/animal_enums.dart';

class AddAnimalForm extends StatefulWidget {
  final Animal? animal;
  final void Function(Animal) onSave;

  const AddAnimalForm({
    super.key,
    this.animal,
    required this.onSave,
  });

  @override
  State<AddAnimalForm> createState() => _AddAnimalFormState();
}

class _AddAnimalFormState extends State<AddAnimalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _notesController = TextEditingController();

  AnimalSpecies _selectedSpecies = AnimalSpecies.dog;
  AnimalGender _selectedGender = AnimalGender.male;
  DateTime _selectedBirthDate = DateTime.now().subtract(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    
    if (widget.animal != null) {
      _nameController.text = widget.animal!.name;
      _breedController.text = widget.animal!.breed ?? '';
      _weightController.text = widget.animal!.weight?.toString() ?? '';
      _colorController.text = widget.animal!.color ?? '';
      _notesController.text = widget.animal!.notes ?? '';
      _selectedSpecies = widget.animal!.species;
      _selectedGender = widget.animal!.gender;
      _selectedBirthDate = widget.animal!.birthDate ?? DateTime.now().subtract(const Duration(days: 365));
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
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.animal != null ? 'Editar Pet' : 'Novo Pet',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Nome
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Pet *',
                hintText: 'Ex: Rex, Mimi, Bob...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Espécie e Gênero
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<AnimalSpecies>(
                    value: _selectedSpecies,
                    decoration: const InputDecoration(
                      labelText: 'Espécie *',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: AnimalSpecies.dog, child: Text(AnimalSpecies.dog.displayName)),
                      DropdownMenuItem(value: AnimalSpecies.cat, child: Text(AnimalSpecies.cat.displayName)),
                      DropdownMenuItem(value: AnimalSpecies.bird, child: Text(AnimalSpecies.bird.displayName)),
                      DropdownMenuItem(value: AnimalSpecies.rabbit, child: Text(AnimalSpecies.rabbit.displayName)),
                      DropdownMenuItem(value: AnimalSpecies.other, child: Text(AnimalSpecies.other.displayName)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSpecies = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<AnimalGender>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gênero *',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: AnimalGender.male, child: Text(AnimalGender.male.displayName)),
                      DropdownMenuItem(value: AnimalGender.female, child: Text(AnimalGender.female.displayName)),
                      DropdownMenuItem(value: AnimalGender.neuteredMale, child: Text(AnimalGender.neuteredMale.displayName)),
                      DropdownMenuItem(value: AnimalGender.spayedFemale, child: Text(AnimalGender.spayedFemale.displayName)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Raça e Cor
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _breedController,
                    decoration: const InputDecoration(
                      labelText: 'Raça *',
                      hintText: 'Ex: Labrador, Persa...',
                      border: OutlineInputBorder(),
                    ),
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
                    ),
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
            
            // Data de nascimento
            InkWell(
              onTap: _selectBirthDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_selectedBirthDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedBirthDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedBirthDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Peso
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Peso (kg) *',
                hintText: 'Ex: 15.5',
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Peso é obrigatório';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return 'Peso deve ser um número maior que zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Observações
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações',
                hintText: 'Informações adicionais...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAnimal,
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)), // 30 years ago
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _saveAnimal() {
    if (_formKey.currentState!.validate()) {
      final weightText = _weightController.text.trim();
      final weight = weightText.isEmpty ? null : double.parse(weightText);
      final now = DateTime.now();
      
      final animal = Animal(
        id: widget.animal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id', // TODO: Get from auth service
        name: _nameController.text.trim(),
        species: _selectedSpecies,
        breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
        weight: weight,
        photoUrl: widget.animal?.photoUrl,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: widget.animal?.createdAt ?? now,
        updatedAt: now,
      );
      
      widget.onSave(animal);
    }
  }
}