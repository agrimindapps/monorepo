import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/pregnancy_calculator.dart';
export '../../../../core/widgets/calculator_page_layout.dart' show CalculatorAccentColors;

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
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return CalculatorPageLayout(
          title: 'Gestação Pet',
          subtitle: 'Acompanhamento de Gestação',
          icon: Icons.child_friendly,
          accentColor: CalculatorAccentColors.pet,
          currentCategory: 'pet',
          maxContentWidth: 600,
          actions: [
            if (_result != null)
              IconButton(
                icon: Icon(
                  Icons.share_outlined,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                onPressed: () {
                  final dateFormat = DateFormat('dd/MM/yyyy');
                  Share.share(
                    ShareFormatter.formatPregnancyCalculation(
                      species: _isDog ? 'Cadela' : 'Gata',
                      gestationDays: _result!.gestationDays,
                      dueDate: dateFormat.format(_result!.estimatedDueDate),
                      daysRemaining: _result!.daysRemaining,
                      stage: PregnancyCalculator.getStageText(_result!.currentStage),
                    ),
                  );
                },
                tooltip: 'Compartilhar',
              ),
          ],
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

                const SizedBox(height: 24),

                // Mating date
                Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data do acasalamento',
                          style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                            fontSize: 13,
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
                              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: CalculatorAccentColors.pet,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _dateFormat.format(_matingDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Alterar',
                                  style: TextStyle(
                                    color: CalculatorAccentColors.pet,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                ),

                const SizedBox(height: 32),

                // Calculate button
                CalculatorActionButtons(
                  onCalculate: _calculate,
                  onClear: _clear,
                  accentColor: CalculatorAccentColors.pet,
                ),

                // Result
                if (_result != null) ...[
                  const SizedBox(height: 32),
                  _PregnancyResultCard(
                    result: _result!,
                    isDog: _isDog,
                    matingDate: _matingDate,
                  ),
                ],
              ],
            ),
          ),
        );
      }
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

  void _clear() {
    setState(() {
      _isDog = true;
      _matingDate = DateTime.now().subtract(const Duration(days: 30));
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = CalculatorAccentColors.pet;

    return Material(
      color: isSelected
          ? accentColor.withValues(alpha: 0.15)
          : isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
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
                  : isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
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
                      : isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = CalculatorAccentColors.pet;
    final stageColor = _getStageColor(result.currentStage);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
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
                'Acompanhamento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
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
                      style: TextStyle(
                        fontSize: 48,
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: stageColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                PregnancyCalculator.getStageText(result.currentStage),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.event,
                  label: 'Data prevista',
                  value: dateFormat.format(result.estimatedDueDate),
                  color: Colors.green,
                ),
                Divider(height: 16, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                _DetailRow(
                  icon: Icons.timer,
                  label: 'Dias restantes',
                  value: '${result.daysRemaining} dias',
                  color: Colors.blue,
                ),
                Divider(height: 16, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
                _DetailRow(
                  icon: Icons.date_range,
                  label: 'Janela de parto',
                  value:
                      '${dateFormat.format(result.earliestDueDate)} - ${dateFormat.format(result.latestDueDate)}',
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          // Warning for overdue
          if (result.isOverdue) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
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
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
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
          _ExpandableSection(
            title: 'Instruções de cuidado',
            icon: Icons.health_and_safety,
            items: result.careInstructions,
          ),

          // Nutritional recommendations
          const SizedBox(height: 8),
          _ExpandableSection(
            title: 'Alimentação',
            icon: Icons.restaurant,
            items: result.nutritionalRecommendations,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final milestoneDate = matingDate.add(Duration(days: milestone.day));
    final dateFormat = DateFormat('dd/MM');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: milestone.isImportant
            ? Colors.amber.withValues(alpha: 0.15)
            : isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: milestone.isImportant
              ? Colors.amber.withValues(alpha: 0.5)
              : isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
        ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  milestone.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            dateFormat.format(milestoneDate),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const _ExpandableSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 20,
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: CalculatorAccentColors.pet,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
