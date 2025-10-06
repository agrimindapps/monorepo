import 'package:flutter/material.dart';
import '../../domain/entities/calorie_input.dart';

/// Widget para o primeiro step: informações básicas do animal
class CalorieBasicInfoStep extends StatefulWidget {
  const CalorieBasicInfoStep({
    super.key,
    required this.input,
    required this.validationErrors,
    required this.onInputChanged,
  });

  final CalorieInput input;
  final List<String> validationErrors;
  final void Function(CalorieInput) onInputChanged;

  @override
  State<CalorieBasicInfoStep> createState() => _CalorieBasicInfoStepState();
}

class _CalorieBasicInfoStepState extends State<CalorieBasicInfoStep> {
  late TextEditingController _weightController;
  late TextEditingController _idealWeightController;
  late TextEditingController _ageController;
  late TextEditingController _breedController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.input.weight > 0 ? widget.input.weight.toString() : '',
    );
    _idealWeightController = TextEditingController(
      text: widget.input.idealWeight?.toString() ?? '',
    );
    _ageController = TextEditingController(
      text: widget.input.age > 0 ? widget.input.age.toString() : '',
    );
    _breedController = TextEditingController(
      text: widget.input.breed ?? '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _idealWeightController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações Básicas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vamos começar com as informações básicas do seu animal.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSpeciesSelector(),
                  const SizedBox(height: 24),
                  _buildWeightField(),
                  const SizedBox(height: 16),
                  _buildIdealWeightField(),
                  const SizedBox(height: 16),
                  _buildAgeField(),
                  const SizedBox(height: 16),
                  _buildBreedField(),
                  const SizedBox(height: 24),
                  _buildTipsCard(),
                ],
              ),
            ),
          ),
          if (widget.validationErrors.isNotEmpty)
            _buildValidationErrors(),
        ],
      ),
    );
  }

  Widget _buildSpeciesSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Espécie *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: AnimalSpecies.values.map((species) {
                final isSelected = widget.input.species == species;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () => _updateSpecies(species),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Theme.of(context).primaryColor
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              species == AnimalSpecies.dog 
                                  ? Icons.pets 
                                  : Icons.pets,
                              size: 32,
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              species.displayName,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      decoration: const InputDecoration(
        labelText: 'Peso Atual *',
        hintText: 'Ex: 25.5',
        suffixText: 'kg',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.scale),
        helperText: 'Peso atual do animal em quilogramas',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {
        final weight = double.tryParse(value) ?? 0;
        _updateWeight(weight);
      },
    );
  }

  Widget _buildIdealWeightField() {
    return TextFormField(
      controller: _idealWeightController,
      decoration: const InputDecoration(
        labelText: 'Peso Ideal',
        hintText: 'Ex: 23.0',
        suffixText: 'kg',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.favorite),
        helperText: 'Peso ideal/alvo (opcional)',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {
        final idealWeight = value.isEmpty ? null : double.tryParse(value);
        _updateIdealWeight(idealWeight);
      },
    );
  }

  Widget _buildAgeField() {
    return TextFormField(
      controller: _ageController,
      decoration: const InputDecoration(
        labelText: 'Idade *',
        hintText: 'Ex: 36',
        suffixText: 'meses',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.cake),
        helperText: 'Idade do animal em meses',
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final age = int.tryParse(value) ?? 0;
        _updateAge(age);
      },
    );
  }

  Widget _buildBreedField() {
    return TextFormField(
      controller: _breedController,
      decoration: const InputDecoration(
        labelText: 'Raça',
        hintText: 'Ex: Golden Retriever',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.info_outline),
        helperText: 'Raça específica (opcional)',
      ),
      onChanged: (value) {
        _updateBreed(value.isEmpty ? null : value);
      },
    );
  }

  Widget _buildTipsCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Dicas Importantes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('• Pese o animal em jejum pela manhã'),
            const Text('• Use balança digital para maior precisão'),
            const Text('• Para gatos, considere o peso ideal entre 3-6kg'),
            const Text('• Para cães, varia muito por raça'),
            const Text('• Se não souber o peso ideal, deixe em branco'),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationErrors() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Correções necessárias:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...widget.validationErrors.map((error) => Text(
            '• $error',
            style: TextStyle(color: Colors.red[600]),
          )),
        ],
      ),
    );
  }

  void _updateSpecies(AnimalSpecies species) {
    widget.onInputChanged(widget.input.copyWith(species: species));
  }

  void _updateWeight(double weight) {
    widget.onInputChanged(widget.input.copyWith(weight: weight));
  }

  void _updateIdealWeight(double? idealWeight) {
    widget.onInputChanged(widget.input.copyWith(idealWeight: idealWeight));
  }

  void _updateAge(int age) {
    widget.onInputChanged(widget.input.copyWith(age: age));
  }

  void _updateBreed(String? breed) {
    widget.onInputChanged(widget.input.copyWith(breed: breed));
  }
}
