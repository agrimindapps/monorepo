import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/breeding_cycle_calculator.dart';

/// Página da calculadora de Ciclo Reprodutivo Animal
class BreedingCycleCalculatorPage extends StatefulWidget {
  const BreedingCycleCalculatorPage({super.key});

  @override
  State<BreedingCycleCalculatorPage> createState() =>
      _BreedingCycleCalculatorPageState();
}

class _BreedingCycleCalculatorPageState
    extends State<BreedingCycleCalculatorPage> {
  Species _species = Species.cattle;
  DateTime _breedingDate = DateTime.now();
  BreedingCycleResult? _result;

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Ciclo Reprodutivo',
      subtitle: 'Gestão de Reprodução Animal',
      icon: Icons.pregnant_woman,
      accentColor: CalculatorAccentColors.agriculture,
      categoryName: 'Agricultura',
      categoryRoute: '/calculators/agriculture/selection',
      instructions: 'Calcule datas importantes do ciclo reprodutivo de animais '
          'para melhor manejo.',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {
              // Share handled by ShareButton in result card
            },
            tooltip: 'Compartilhar',
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Species selection
              Text(
                'Espécie',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Species.values.map((species) {
                  return ChoiceChip(
                    label: Text(BreedingCycleCalculator.getSpeciesName(species)),
                    selected: _species == species,
                    onSelected: (_) {
                      setState(() => _species = species);
                    },
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    selectedColor:
                        CalculatorAccentColors.agriculture.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: _species == species
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Breeding date
              Text(
                'Data da Cobertura/Inseminação',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              _DarkDateSelector(
                selectedDate: _breedingDate,
                onDateChanged: (date) {
                  setState(() => _breedingDate = date);
                },
              ),

              const SizedBox(height: 32),

              // Calculate button
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular Ciclo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CalculatorAccentColors.agriculture,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (_result != null)
                _BreedingCycleResultCard(result: _result!, species: _species),
            ],
          ),
        ),
      ),
    );
  }

  void _calculate() {
    final result = BreedingCycleCalculator.calculate(
      species: _species,
      breedingDate: _breedingDate,
    );

    setState(() => _result = result);
  }
}

class _BreedingCycleResultCard extends StatelessWidget {
  final BreedingCycleResult result;
  final Species species;

  const _BreedingCycleResultCard({
    required this.result,
    required this.species,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.event_available,
                  color: CalculatorAccentColors.agriculture),
              const SizedBox(width: 8),
              Text(
                'Previsão de Parto',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ShareButton(
                text: _formatShareText(dateFormatter),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main result
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CalculatorAccentColors.agriculture.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CalculatorAccentColors.agriculture.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                _ResultRow(
                  label: 'Data prevista do parto',
                  value: dateFormatter.format(result.birthDate),
                  highlight: true,
                  color: CalculatorAccentColors.agriculture,
                ),
                const SizedBox(height: 16),
                Divider(
                  color: Colors.white.withValues(alpha: 0.1),
                  height: 16,
                ),
                const SizedBox(height: 16),
                _ResultRow(
                  label: 'Período de gestação',
                  value: '${result.gestationDays} dias',
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                _ResultRow(
                  label: 'Dias restantes',
                  value: '${result.daysRemaining} dias',
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Milestones
          Text(
            'Marcos do Ciclo',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _MilestonesSection(
            title: '1º Trimestre',
            milestones: result.firstTrimester,
            dateFormatter: dateFormatter,
          ),
          const SizedBox(height: 8),
          _MilestonesSection(
            title: '2º Trimestre',
            milestones: result.secondTrimester,
            dateFormatter: dateFormatter,
          ),
          const SizedBox(height: 8),
          _MilestonesSection(
            title: '3º Trimestre',
            milestones: result.thirdTrimester,
            dateFormatter: dateFormatter,
          ),

          const SizedBox(height: 16),

          // Care tips
          _CareTipsSection(careTips: result.careTips),
        ],
      ),
    );
  }

  String _formatShareText(DateFormat formatter) {
    final speciesName = BreedingCycleCalculator.getSpeciesName(species);
    return '''
📋 Ciclo Reprodutivo - Calculei App

🐄 Espécie: $speciesName

📅 Previsão:
• Data do parto: ${formatter.format(result.birthDate)}
• Gestação: ${result.gestationDays} dias
• Dias restantes: ${result.daysRemaining}

💡 Mantenha acompanhamento veterinário regular.

_________________
Calculado por Calculei
by Agrimind''';
  }
}

class _MilestonesSection extends StatelessWidget {
  final String title;
  final List<CycleMilestone> milestones;
  final DateFormat dateFormatter;

  const _MilestonesSection({
    required this.title,
    required this.milestones,
    required this.dateFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...milestones.map((milestone) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.circle,
                    size: 8,
                    color: CalculatorAccentColors.agriculture,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          milestone.event,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${dateFormatter.format(milestone.date)} - ${milestone.description}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CareTipsSection extends StatelessWidget {
  final List<String> careTips;

  const _CareTipsSection({required this.careTips});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: Colors.amber.withValues(alpha: 0.8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Cuidados Recomendados',
                style: TextStyle(
                  color: Colors.amber.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...careTips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color color;

  const _ResultRow({
    required this.label,
    required this.value,
    this.highlight = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: highlight ? 0.9 : 0.7),
            fontSize: highlight ? 16 : 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? color : Colors.white.withValues(alpha: 0.9),
            fontSize: highlight ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Dark theme input field widget
// Provided as a reusable pattern for future form fields, matching seed_rate_calculator_page.dart
// ignore: unused_element
class _DarkInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  // ignore: unused_element
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
              borderSide: BorderSide(
                color: CalculatorAccentColors.agriculture,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Dark theme date selector widget
class _DarkDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DarkDateSelector({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onDateChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: CalculatorAccentColors.agriculture,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateFormatter.format(selectedDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.edit,
              color: Colors.white.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
