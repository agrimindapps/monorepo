import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';

/// Página da Calculadora de Idade Animal
class AnimalAgePage extends StatefulWidget {
  const AnimalAgePage({super.key});

  @override
  State<AnimalAgePage> createState() => _AnimalAgePageState();
}

class _AnimalAgePageState extends State<AnimalAgePage> {
  final _ageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedSpecies = 'dog';
  String _conversionType = 'to_human';
  String? _result;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Idade Animal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildSpeciesSelector(),
              const SizedBox(height: 16),
              _buildConversionTypeSelector(),
              const SizedBox(height: 16),
              _buildAgeInput(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_result != null) ...[
                const SizedBox(height: 24),
                _buildResultCard(),
              ],
              const SizedBox(height: 24),
              _buildInfoTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.pets,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Conversão de Idade Animal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Converta a idade entre animais e humanos usando fórmulas veterinárias científicas.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Espécie Animal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'dog',
                  child: Text('Cão'),
                ),
                DropdownMenuItem(
                  value: 'cat',
                  child: Text('Gato'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSpecies = value!;
                  _result = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Conversão',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _conversionType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.swap_horiz),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'to_human',
                  child: Text('Animal → Humano'),
                ),
                DropdownMenuItem(
                  value: 'to_animal',
                  child: Text('Humano → Animal'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _conversionType = value!;
                  _result = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeInput() {
    final isToHuman = _conversionType == 'to_human';
    final species = _selectedSpecies == 'dog' ? 'cão' : 'gato';
    final label = isToHuman
        ? 'Idade do $species (anos)'
        : 'Idade humana (anos)';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entrada de Idade',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: label,
                hintText: 'Digite a idade',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.cake),
                suffixText: 'anos',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite uma idade';
                }
                final age = double.tryParse(value);
                if (age == null || age <= 0) {
                  return 'Digite uma idade válida';
                }
                if (age > 100) {
                  return 'Idade muito alta';
                }
                return null;
              },
              onChanged: (_) {
                setState(() {
                  _result = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _calculateAge,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: const Text(
        'Calcular Idade',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.calculate,
              size: 48,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 12),
            Text(
              'Resultado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _result!,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _getResultExplanation(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tabela de Referência',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSpeciesTable('Cão', _getDogAgeTable()),
            const SizedBox(height: 16),
            _buildSpeciesTable('Gato', _getCatAgeTable()),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Estas são estimativas baseadas em fórmulas veterinárias. A idade biológica pode variar conforme raça, porte e saúde do animal.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeciesTable(String species, List<MapEntry<String, String>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          species,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Idade $species',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Idade Humana',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...data.map(
              (entry) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(entry.key),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(entry.value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<MapEntry<String, String>> _getDogAgeTable() {
    return [
      const MapEntry('1 ano', '15 anos'),
      const MapEntry('2 anos', '24 anos'),
      const MapEntry('3 anos', '28 anos'),
      const MapEntry('4 anos', '32 anos'),
      const MapEntry('5 anos', '36 anos'),
      const MapEntry('8 anos', '48 anos'),
      const MapEntry('10 anos', '56 anos'),
      const MapEntry('15 anos', '76 anos'),
    ];
  }

  List<MapEntry<String, String>> _getCatAgeTable() {
    return [
      const MapEntry('1 ano', '15 anos'),
      const MapEntry('2 anos', '24 anos'),
      const MapEntry('3 anos', '28 anos'),
      const MapEntry('4 anos', '32 anos'),
      const MapEntry('5 anos', '36 anos'),
      const MapEntry('8 anos', '48 anos'),
      const MapEntry('10 anos', '56 anos'),
      const MapEntry('15 anos', '76 anos'),
    ];
  }

  void _calculateAge() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inputAge = double.parse(_ageController.text);
    double resultAge;
    String resultText;

    if (_conversionType == 'to_human') {
      resultAge = _convertAnimalToHuman(inputAge, _selectedSpecies);
      final speciesName = _selectedSpecies == 'dog' ? 'cão' : 'gato';
      resultText = '${inputAge.toInt()} ano${inputAge != 1 ? 's' : ''} de $speciesName = ${resultAge.toInt()} anos humanos';
    } else {
      resultAge = _convertHumanToAnimal(inputAge, _selectedSpecies);
      final speciesName = _selectedSpecies == 'dog' ? 'cão' : 'gato';
      resultText = '${inputAge.toInt()} anos humanos = ${resultAge.toStringAsFixed(1)} anos de $speciesName';
    }

    setState(() {
      _result = resultText;
    });
  }

  double _convertAnimalToHuman(double animalAge, String species) {
    if (species == 'dog') {
      if (animalAge <= 1) {
        return animalAge * 15;
      } else if (animalAge <= 2) {
        return 15 + (animalAge - 1) * 9;
      } else {
        return 24 + (animalAge - 2) * 4;
      }
    } else { // cat
      if (animalAge <= 1) {
        return animalAge * 15;
      } else if (animalAge <= 2) {
        return 15 + (animalAge - 1) * 9;
      } else {
        return 24 + (animalAge - 2) * 4;
      }
    }
  }

  double _convertHumanToAnimal(double humanAge, String species) {
    if (species == 'dog') {
      if (humanAge <= 15) {
        return humanAge / 15;
      } else if (humanAge <= 24) {
        return 1 + (humanAge - 15) / 9;
      } else {
        return 2 + (humanAge - 24) / 4;
      }
    } else { // cat
      if (humanAge <= 15) {
        return humanAge / 15;
      } else if (humanAge <= 24) {
        return 1 + (humanAge - 15) / 9;
      } else {
        return 2 + (humanAge - 24) / 4;
      }
    }
  }

  String _getResultExplanation() {
    final species = _selectedSpecies == 'dog' ? 'cão' : 'gato';
    if (_conversionType == 'to_human') {
      return 'Idade equivalente em anos humanos para um $species';
    } else {
      return 'Idade equivalente em anos de $species';
    }
  }
}
