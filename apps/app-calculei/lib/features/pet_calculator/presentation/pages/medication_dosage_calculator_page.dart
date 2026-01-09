import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/medication_dosage_calculator.dart';
export '../../../../core/widgets/calculator_page_layout.dart' show CalculatorAccentColors;

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
    return CalculatorPageLayout(
      title: 'Dosagem de Medicamentos',
      subtitle: 'Cálculo de Dosagem',
      icon: Icons.medication,
      accentColor: CalculatorAccentColors.pet,
      currentCategory: 'pet',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {},
            tooltip: 'Compartilhar',
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AVISO IMPORTANTE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Este cálculo é apenas informativo. NUNCA medique seu pet sem prescrição veterinária.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 24),

              // Weight
              _DarkInputField(
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

              const SizedBox(height: 24),

              // Medication Type
              Text(
                'Medicamento',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...MedicationType.values.map((type) {
                return RadioListTile<MedicationType>(
                  title: Text(
                    MedicationDosageCalculator
                        .getMedicationDescription(type),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  value: type,
                  groupValue: _medicationType,
                  onChanged: (value) =>
                      setState(() => _medicationType = value!),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: CalculatorAccentColors.pet,
                );
              }).toList(),

              const SizedBox(height: 24),

              // Frequency
              Text(
                'Frequência',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DosageFrequency.values.map((freq) {
                  final isSelected = _frequency == freq;
                  return DarkChoiceChip(
                    label: _getFrequencyLabel(freq),
                    isSelected: isSelected,
                    onSelected: () =>
                        setState(() => _frequency = freq),
                    accentColor: CalculatorAccentColors.pet,
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Calculate button
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: CalculatorAccentColors.pet,
              ),

              if (_result != null) ...[
                const SizedBox(height: 32),
                _MedicationDosageResultCard(
                  result: _result!,
                  species: _species,
                  weight: double.parse(_weightController.text),
                ),
              ],
            ],
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

  void _clear() {
    _weightController.clear();
    setState(() {
      _species = PetSpecies.dog;
      _medicationType = MedicationType.amoxicillin;
      _frequency = DosageFrequency.twiceDailyBID;
      _result = null;
    });
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
    const accentColor = CalculatorAccentColors.pet;

    return Material(
      color: isSelected
          ? accentColor.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.2),
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
                      ? accentColor
                      : Colors.white.withValues(alpha: 0.7),
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
    const accentColor = CalculatorAccentColors.pet;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: accentColor),
              const SizedBox(width: 8),
              Text(
                'Resultado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.9),
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
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('💊', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  result.medicationName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      result.dosePerAdministration.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        ' mg',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'por administração',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
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
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: 'Frequência',
                  value: result.frequencyText,
                ),
                Divider(height: 16, color: Colors.white.withValues(alpha: 0.1)),
                _DetailRow(
                  label: 'Administrações/dia',
                  value: '${result.administrationsPerDay}x',
                ),
                Divider(height: 16, color: Colors.white.withValues(alpha: 0.1)),
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
              color: Colors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.observations,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade400,
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
                        ? Colors.red.shade400
                        : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

/// Dark theme input field widget
class _DarkInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _DarkInputField({
    required this.label,
    required this.controller,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: CalculatorAccentColors.pet,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
