import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/medication_dosage_calculator.dart';

/// Página da calculadora de Dosagem de Medicamentos
class MedicationDosageCalculatorPage extends StatefulWidget {
  const MedicationDosageCalculatorPage({super.key});

  @override
  State<MedicationDosageCalculatorPage> createState() =>
      _MedicationDosageCalculatorPageState();
}

class _MedicationDosageCalculatorPageState
    extends State<MedicationDosageCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  PetSpecies _species = PetSpecies.dog;
  MedicationType _medicationType = MedicationType.amoxicillin;
  DosageFrequency _frequency = DosageFrequency.twiceDailyBID;
  MedicationDosageResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosagem de Medicamentos'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warning Card
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AVISO IMPORTANTE',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Este cálculo é apenas informativo. NUNCA medique seu pet sem prescrição veterinária.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info Card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.medication,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cálculo de Dosagem',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Calcule dosagens de medicamentos comuns baseadas no peso do pet.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Dados do pet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Species
                            Row(
                              children: [
                                Expanded(
                                  child: _SpeciesButton(
                                    label: 'Cachorro',
                                    emoji: '🐕',
                                    isSelected: _species == PetSpecies.dog,
                                    onTap: () =>
                                        setState(() => _species = PetSpecies.dog),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SpeciesButton(
                                    label: 'Gato',
                                    emoji: '🐈',
                                    isSelected: _species == PetSpecies.cat,
                                    onTap: () =>
                                        setState(() => _species = PetSpecies.cat),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Weight
                            StandardInputField(
                              label: 'Peso do pet',
                              controller: _weightController,
                              suffix: 'kg',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Obrigatório';
                                }
                                final num = double.tryParse(value);
                                if (num == null || num <= 0 || num > 100) {
                                  return 'Entre 0 e 100 kg';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Medication Type
                            Text(
                              'Medicamento',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            ...MedicationType.values.map((type) {
                              return RadioListTile<MedicationType>(
                                title: Text(
                                  MedicationDosageCalculator
                                      .getMedicationDescription(type),
                                ),
                                value: type,
                                groupValue: _medicationType,
                                onChanged: (value) =>
                                    setState(() => _medicationType = value!),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              );
                            }).toList(),

                            const SizedBox(height: 16),

                            // Frequency
                            Text(
                              'Frequência',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: DosageFrequency.values.map((freq) {
                                return ChoiceChip(
                                  label: Text(_getFrequencyLabel(freq)),
                                  selected: _frequency == freq,
                                  onSelected: (_) =>
                                      setState(() => _frequency = freq),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular Dosagem',
                              icon: Icons.calculate,
                              onPressed: _calculate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Result
                  if (_result != null)
                    _MedicationDosageResultCard(
                      result: _result!,
                      species: _species,
                      weight: double.parse(_weightController.text),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getFrequencyLabel(DosageFrequency freq) {
    return switch (freq) {
      DosageFrequency.onceDailyBID => '1x/dia',
      DosageFrequency.twiceDailyBID => '2x/dia',
      DosageFrequency.threeDailyTID => '3x/dia',
    };
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final result = MedicationDosageCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      medicationType: _medicationType,
      species: _species,
      frequency: _frequency,
    );

    setState(() => _result = result);
  }
}

class _SpeciesButton extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpeciesButton({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicationDosageResultCard extends StatelessWidget {
  final MedicationDosageResult result;
  final PetSpecies species;
  final double weight;

  const _MedicationDosageResultCard({
    required this.result,
    required this.species,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Resultado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                ShareButton(
                  text: '''
📋 Dosagem de Medicamentos - Calculei App

💊 Medicamento: ${result.medicationName}
🐾 Pet: ${species == PetSpecies.dog ? 'Cachorro' : 'Gato'}
⚖️ Peso: ${weight.toStringAsFixed(1)} kg

💉 Dose por administração: ${result.dosePerAdministration.toStringAsFixed(1)} mg
📅 Frequência: ${result.frequencyText}
🔄 Dose diária total: ${result.dailyDose.toStringAsFixed(1)} mg

⚠️ ESTE CÁLCULO É APENAS INFORMATIVO
Consulte sempre um veterinário antes de medicar!

_________________
Calculado por Calculei
by Agrimind
https://calculei.com.br''',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main result
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('💊', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    result.medicationName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        result.dosePerAdministration.toStringAsFixed(1),
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          ' mg',
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'por administração',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Frequência',
                    value: result.frequencyText,
                  ),
                  const Divider(height: 16),
                  _DetailRow(
                    label: 'Administrações/dia',
                    value: '${result.administrationsPerDay}x',
                  ),
                  const Divider(height: 16),
                  _DetailRow(
                    label: 'Dose diária total',
                    value: '${result.dailyDose.toStringAsFixed(1)} mg',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Observations
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.observations,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Warnings
            Text(
              'Avisos Importantes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
            ),
            const SizedBox(height: 8),
            ...result.warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning,
                      size: 18,
                      color: warning.startsWith('⚠️') || warning.startsWith('🚨')
                          ? Colors.red.shade700
                          : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
