import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/pregnancy_calculator.dart';

/// Página da calculadora de Gestação de Pets
class PregnancyCalculatorPage extends StatefulWidget {
  const PregnancyCalculatorPage({super.key});

  @override
  State<PregnancyCalculatorPage> createState() =>
      _PregnancyCalculatorPageState();
}

class _PregnancyCalculatorPageState extends State<PregnancyCalculatorPage> {
  bool _isDog = true;
  DateTime _matingDate = DateTime.now().subtract(const Duration(days: 30));
  PregnancyResult? _result;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestação Pet'),
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
                                Icons.child_friendly,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Acompanhamento de Gestação',
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
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Acompanhe a gestação da sua pet, desde o acasalamento '
                            'até o nascimento dos filhotes. Receba orientações '
                            'para cada fase.',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Dados da gestação',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),

                          // Species selection
                          Row(
                            children: [
                              Expanded(
                                child: _SpeciesButton(
                                  label: 'Cadela',
                                  emoji: '🐕',
                                  isSelected: _isDog,
                                  onTap: () => setState(() => _isDog = true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SpeciesButton(
                                  label: 'Gata',
                                  emoji: '🐈',
                                  isSelected: !_isDog,
                                  onTap: () => setState(() => _isDog = false),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Mating date
                          Text(
                            'Data do acasalamento',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _selectMatingDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.5),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _dateFormat.format(_matingDate),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Alterar',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          CalculatorButton(
                            label: 'Calcular',
                            icon: Icons.calculate,
                            onPressed: _calculate,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Result
                  if (_result != null)
                    _PregnancyResultCard(
                      result: _result!,
                      isDog: _isDog,
                      matingDate: _matingDate,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectMatingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _matingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 100)),
      lastDate: DateTime.now(),
      helpText: 'Data do acasalamento',
    );

    if (picked != null) {
      setState(() => _matingDate = picked);
    }
  }

  void _calculate() {
    final result = PregnancyCalculator.calculate(
      isDog: _isDog,
      matingDate: _matingDate,
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

class _PregnancyResultCard extends StatelessWidget {
  final PregnancyResult result;
  final bool isDog;
  final DateTime matingDate;

  _PregnancyResultCard({
    required this.result,
    required this.isDog,
    required this.matingDate,
  });

  final _dateFormat = DateFormat('dd/MM/yyyy');

  Color _getStageColor(PregnancyStage stage) {
    return switch (stage) {
      PregnancyStage.implantation => Colors.blue,
      PregnancyStage.earlyDevelopment => Colors.teal,
      PregnancyStage.midDevelopment => Colors.green,
      PregnancyStage.lateDevelopment => Colors.orange,
      PregnancyStage.term => Colors.purple,
      PregnancyStage.overdue => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stageColor = _getStageColor(result.currentStage);
    final dateFormat = DateFormat('dd/MM/yyyy');

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
                  'Acompanhamento',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                ShareButton(
                  text: ShareFormatter.formatPregnancyCalculation(
                    species: isDog ? 'Cadela' : 'Gata',
                    gestationDays: result.gestationDays,
                    dueDate: dateFormat.format(result.estimatedDueDate),
                    daysRemaining: result.daysRemaining,
                    stage: PregnancyCalculator.getStageText(result.currentStage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress circle
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: result.progressPercent / 100,
                      strokeWidth: 12,
                      backgroundColor: stageColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(stageColor),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${result.gestationDays}',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: stageColor,
                                ),
                      ),
                      Text(
                        'dias',
                        style: TextStyle(color: stageColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stage chip
            Center(
              child: Chip(
                label: Text(
                  PregnancyCalculator.getStageText(result.currentStage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: stageColor,
              ),
            ),

            const SizedBox(height: 8),

            // Stage description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stageColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: stageColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                result.stageDescription,
                textAlign: TextAlign.center,
                style: TextStyle(color: stageColor),
              ),
            ),

            const SizedBox(height: 16),

            // Due dates
            _InfoRow(
              icon: Icons.event,
              label: 'Data prevista',
              value: dateFormat.format(result.estimatedDueDate),
              color: Colors.green,
            ),
            _InfoRow(
              icon: Icons.timer,
              label: 'Dias restantes',
              value: '${result.daysRemaining} dias',
              color: Colors.blue,
            ),
            _InfoRow(
              icon: Icons.date_range,
              label: 'Janela de parto',
              value:
                  '${dateFormat.format(result.earliestDueDate)} - ${dateFormat.format(result.latestDueDate)}',
              color: Colors.orange,
            ),

            // Warning for overdue
            if (result.isOverdue) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ Gestação prolongada! Consulte o veterinário imediatamente.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Upcoming milestones
            if (result.upcomingMilestones.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Próximos marcos',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...result.upcomingMilestones.map(
                (milestone) => _MilestoneItem(
                  milestone: milestone,
                  matingDate: matingDate,
                ),
              ),
            ],

            // Care instructions
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text('Instruções de cuidado'),
              leading: const Icon(Icons.health_and_safety),
              children: result.careInstructions
                  .map(
                    (instruction) => ListTile(
                      leading: const Icon(Icons.check, size: 20),
                      title: Text(instruction, style: const TextStyle(fontSize: 14)),
                      dense: true,
                    ),
                  )
                  .toList(),
            ),

            // Nutritional recommendations
            ExpansionTile(
              title: const Text('Alimentação'),
              leading: const Icon(Icons.restaurant),
              children: result.nutritionalRecommendations
                  .map(
                    (rec) => ListTile(
                      leading: const Icon(Icons.restaurant_menu, size: 20),
                      title: Text(rec, style: const TextStyle(fontSize: 14)),
                      dense: true,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final PregnancyMilestone milestone;
  final DateTime matingDate;

  const _MilestoneItem({
    required this.milestone,
    required this.matingDate,
  });

  @override
  Widget build(BuildContext context) {
    final milestoneDate = matingDate.add(Duration(days: milestone.day));
    final dateFormat = DateFormat('dd/MM');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: milestone.isImportant
            ? Colors.amber.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: milestone.isImportant
            ? Border.all(color: Colors.amber.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: milestone.isImportant ? Colors.amber : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Dia ${milestone.day}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  milestone.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            dateFormat.format(milestoneDate),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
