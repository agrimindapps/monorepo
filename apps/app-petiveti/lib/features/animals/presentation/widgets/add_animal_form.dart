import 'package:flutter/material.dart';

import '../../domain/entities/animal.dart';

class AddAnimalForm extends StatefulWidget {
  final Animal? animal;
  final Function(Animal) onSave;

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

  String _selectedSpecies = 'Cachorro';
  String _selectedGender = 'Macho';
  DateTime _selectedBirthDate = DateTime.now().subtract(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    
    if (widget.animal != null) {
      _nameController.text = widget.animal!.name;
      _breedController.text = widget.animal!.breed;
      _weightController.text = widget.animal!.currentWeight.toString();
      _colorController.text = widget.animal!.color;
      _notesController.text = widget.animal!.notes ?? '';
      _selectedSpecies = widget.animal!.species;
      _selectedGender = widget.animal!.gender;
      _selectedBirthDate = widget.animal!.birthDate;
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
                  child: DropdownButtonFormField<String>(
                    value: _selectedSpecies,
                    decoration: const InputDecoration(
                      labelText: 'Espécie *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Cachorro', child: Text('Cachorro')),
                      DropdownMenuItem(value: 'Gato', child: Text('Gato')),
                      DropdownMenuItem(value: 'Pássaro', child: Text('Pássaro')),
                      DropdownMenuItem(value: 'Outro', child: Text('Outro')),
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
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gênero *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                      DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
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
      final weight = double.parse(_weightController.text);
      final now = DateTime.now();
      
      final animal = Animal(
        id: widget.animal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        species: _selectedSpecies,
        breed: _breedController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        color: _colorController.text.trim(),
        currentWeight: weight,
        photo: widget.animal?.photo,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: widget.animal?.createdAt ?? now,
        updatedAt: now,
        isDeleted: false,
      );
      
      widget.onSave(animal);
    }
  }
}