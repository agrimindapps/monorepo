import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/breeding_cycle_calculator.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Ciclo Reprodutivo')),
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
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.pregnant_woman,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                              const SizedBox(width: 8),
                              Text('Ciclo Reprodutivo Animal',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      )),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Calcule a data prevista de parto e acompanhe os marcos '
                            'importantes do ciclo gestacional.',
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Espécie',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: Species.values.map((species) {
                              return ChoiceChip(
                                label: Text(BreedingCycleCalculator
                                    .getSpeciesName(species)),
                                selected: _species == species,
                                onSelected: (_) =>
                                    setState(() => _species = species),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Text('Data da Cobertura/Inseminação',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(
                              DateFormat('dd/MM/yyyy').format(_breedingDate),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            trailing: const Icon(Icons.edit),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _breedingDate,
                                firstDate:
                                    DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _breedingDate = date);
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          CalculatorButton(
                            label: 'Calcular Ciclo',
                            icon: Icons.calculate,
                            onPressed: _calculate,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_result != null)
                    _BreedingCycleResultCard(
                        result: _result!, species: _species),
                ],
              ),
            ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.event_available, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Previsão de Parto',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                ShareButton(text: _formatShareText(dateFormatter)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _ResultRow(
                    label: 'Data prevista do parto',
                    value: dateFormatter.format(result.birthDate),
                    highlight: true,
                  ),
                  const Divider(height: 24),
                  _ResultRow(
                    label: 'Período de gestação',
                    value: '${result.gestationDays} dias',
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: 'Dias restantes',
                    value: '${result.daysRemaining} dias',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Marcos do Ciclo',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
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
            ExpansionTile(
              title: const Text('Cuidados Recomendados'),
              leading: const Icon(Icons.health_and_safety),
              children: result.careTips
                  .map((tip) => ListTile(
                        leading: const Icon(Icons.check, size: 20),
                        title: Text(tip, style: const TextStyle(fontSize: 14)),
                        dense: true,
                      ))
                  .toList(),
            ),
          ],
        ),
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
    return ExpansionTile(
      title: Text(title),
      leading: const Icon(Icons.timeline, size: 20),
      children: milestones
          .map((milestone) => ListTile(
                leading: Icon(Icons.circle,
                    size: 8,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(milestone.event,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                    '${dateFormatter.format(milestone.date)} - ${milestone.description}'),
                dense: true,
              ))
          .toList(),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ResultRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: highlight ? 16 : 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: highlight ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
