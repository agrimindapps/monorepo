import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/body_condition_input.dart';
import '../providers/body_condition_provider.dart';

/// Formulário de entrada para cálculo de condição corporal
class BodyConditionInputForm extends ConsumerStatefulWidget {
  const BodyConditionInputForm({super.key});

  @override
  ConsumerState<BodyConditionInputForm> createState() => _BodyConditionInputFormState();
}

class _BodyConditionInputFormState extends ConsumerState<BodyConditionInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _idealWeightController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _observationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final input = ref.read(bodyConditionInputProvider);
      _weightController.text = input.currentWeight > 0 ? input.currentWeight.toString() : '';
      _idealWeightController.text = input.idealWeight?.toString() ?? '';
      _ageController.text = input.animalAge?.toString() ?? '';
      _breedController.text = input.animalBreed ?? '';
      _observationsController.text = input.observations ?? '';
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _idealWeightController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = ref.watch(bodyConditionInputProvider);
    final suggestions = ref.watch(bodyConditionSuggestionsProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (suggestions.isNotEmpty) _buildSuggestionPanel(suggestions),
          _buildSectionHeader('Dados do Animal', Icons.pets),
          const SizedBox(height: 12),
          
          _buildSpeciesDropdown(input.species),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildWeightField(
                  controller: _weightController,
                  label: 'Peso Atual *',
                  hint: 'Ex: 25.5',
                  onChanged: (value) {
                    final weight = double.tryParse(value);
                    if (weight != null) {
                      ref.read(bodyConditionProvider.notifier).updateCurrentWeight(weight);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWeightField(
                  controller: _idealWeightController,
                  label: 'Peso Ideal',
                  hint: 'Opcional',
                  onChanged: (value) {
                    final weight = value.isEmpty ? null : double.tryParse(value);
                    ref.read(bodyConditionProvider.notifier).updateIdealWeight(weight);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildAgeField(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBreedField(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Avaliação Física', Icons.touch_app),
          const SizedBox(height: 12),
          
          _buildRibPalpationDropdown(input.ribPalpation),
          const SizedBox(height: 16),
          
          _buildWaistVisibilityDropdown(input.waistVisibility),
          const SizedBox(height: 16),
          
          _buildAbdominalProfileDropdown(input.abdominalProfile),
          const SizedBox(height: 24),
          _buildSectionHeader('Informações Adicionais', Icons.info_outline),
          const SizedBox(height: 12),
          
          _buildAdditionalInfo(input),
          const SizedBox(height: 16),
          
          _buildObservationsField(),
          const SizedBox(height: 24),
          _buildInputSummary(input),
        ],
      ),
    );
  }

  Widget _buildSuggestionPanel(List<String> suggestions) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Dicas para melhorar a precisão:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text('• $suggestion', style: const TextStyle(fontSize: 12)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const Expanded(child: Divider(indent: 12)),
      ],
    );
  }

  Widget _buildSpeciesDropdown(AnimalSpecies currentSpecies) {
    return DropdownButtonFormField<AnimalSpecies>(
      value: currentSpecies,
      decoration: const InputDecoration(
        labelText: 'Espécie *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.pets),
      ),
      items: AnimalSpecies.values.map((species) {
        return DropdownMenuItem(
          value: species,
          child: Text(species.displayName),
        );
      }).toList(),
      onChanged: (species) {
        if (species != null) {
          ref.read(bodyConditionProvider.notifier).updateSpecies(species);
        }
      },
    );
  }

  Widget _buildWeightField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: 'kg',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.monitor_weight),
      ),
      onChanged: onChanged,
      validator: label.contains('*') ? (value) {
        if (value == null || value.isEmpty) return 'Campo obrigatório';
        final weight = double.tryParse(value);
        if (weight == null || weight <= 0) return 'Peso inválido';
        if (weight > 200) return 'Peso muito alto';
        return null;
      } : null,
    );
  }

  Widget _buildAgeField() {
    return TextFormField(
      controller: _ageController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'Idade',
        hintText: 'Em meses',
        suffixText: 'meses',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.cake),
      ),
      onChanged: (value) {
        final age = value.isEmpty ? null : int.tryParse(value);
        ref.read(bodyConditionProvider.notifier).updateAnimalAge(age);
      },
    );
  }

  Widget _buildBreedField() {
    return TextFormField(
      controller: _breedController,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Raça',
        hintText: 'Ex: Labrador',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      onChanged: (value) {
        ref.read(bodyConditionProvider.notifier).updateAnimalBreed(value.isEmpty ? null : value);
      },
    );
  }

  Widget _buildRibPalpationDropdown(RibPalpation current) {
    return DropdownButtonFormField<RibPalpation>(
      value: current,
      decoration: const InputDecoration(
        labelText: 'Palpação das Costelas *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.touch_app),
        helperText: 'Pressione suavemente as laterais do tórax',
      ),
      items: RibPalpation.values.map((rib) {
        return DropdownMenuItem(
          value: rib,
          child: Text(rib.description),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(bodyConditionProvider.notifier).updateRibPalpation(value);
        }
      },
    );
  }

  Widget _buildWaistVisibilityDropdown(WaistVisibility current) {
    return DropdownButtonFormField<WaistVisibility>(
      value: current,
      decoration: const InputDecoration(
        labelText: 'Cintura (Vista de Cima) *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.visibility),
        helperText: 'Observe o animal de cima para ver a "cintura"',
      ),
      items: WaistVisibility.values.map((waist) {
        return DropdownMenuItem(
          value: waist,
          child: Text(waist.description),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(bodyConditionProvider.notifier).updateWaistVisibility(value);
        }
      },
    );
  }

  Widget _buildAbdominalProfileDropdown(AbdominalProfile current) {
    return DropdownButtonFormField<AbdominalProfile>(
      value: current,
      decoration: const InputDecoration(
        labelText: 'Perfil Abdominal *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.straighten),
        helperText: 'Observe o animal de lado (perfil lateral)',
      ),
      items: AbdominalProfile.values.map((abdomen) {
        return DropdownMenuItem(
          value: abdomen,
          child: Text(abdomen.description),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(bodyConditionProvider.notifier).updateAbdominalProfile(value);
        }
      },
    );
  }

  Widget _buildAdditionalInfo(BodyConditionInput input) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Animal Castrado/Esterilizado'),
          subtitle: const Text('Animais castrados tendem a ganhar peso mais facilmente'),
          value: input.isNeutered,
          onChanged: (value) {
            ref.read(bodyConditionProvider.notifier).updateIsNeutered(value);
          },
        ),
        SwitchListTile(
          title: const Text('Possui Condições Metabólicas'),
          subtitle: const Text('Ex: diabetes, hipotireoidismo, etc.'),
          value: input.hasMetabolicConditions,
          onChanged: (value) {
            ref.read(bodyConditionProvider.notifier).updateHasMetabolicConditions(value);
          },
        ),
      ],
    );
  }

  Widget _buildObservationsField() {
    return TextFormField(
      controller: _observationsController,
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Observações',
        hintText: 'Comportamento alimentar, atividade física, outras observações...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.notes),
      ),
      onChanged: (value) {
        ref.read(bodyConditionProvider.notifier).updateObservations(value.isEmpty ? null : value);
      },
    );
  }

  Widget _buildInputSummary(BodyConditionInput input) {
    final canCalculate = ref.watch(bodyConditionCanCalculateProvider);
    
    return Card(
      color: canCalculate ? Colors.green.shade50 : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  canCalculate ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: canCalculate ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumo dos Dados',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canCalculate ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Espécie: ${input.species.displayName}'),
            Text('Peso: ${input.currentWeight > 0 ? "${input.currentWeight.toStringAsFixed(1)} kg" : "Não informado"}'),
            if (input.idealWeight != null)
              Text('Peso ideal: ${input.idealWeight!.toStringAsFixed(1)} kg'),
            Text('Costelas: ${input.ribPalpation.description}'),
            Text('Cintura: ${input.waistVisibility.description}'),
            Text('Abdome: ${input.abdominalProfile.description}'),
            const SizedBox(height: 8),
            Text(
              canCalculate 
                ? '✓ Pronto para calcular' 
                : '⚠ Preencha os campos obrigatórios',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: canCalculate ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}