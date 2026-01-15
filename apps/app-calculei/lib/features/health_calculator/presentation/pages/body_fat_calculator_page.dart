import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/body_fat_calculator.dart';

/// Página da calculadora de Gordura Corporal
class BodyFatCalculatorPage extends StatefulWidget {
  const BodyFatCalculatorPage({super.key});

  @override
  State<BodyFatCalculatorPage> createState() => _BodyFatCalculatorPageState();
}

class _BodyFatCalculatorPageState extends State<BodyFatCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _waistController = TextEditingController();
  final _neckController = TextEditingController();
  final _hipController = TextEditingController();

  bool _isMale = true;
  BodyFatResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _waistController.dispose();
    _neckController.dispose();
    _hipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Gordura Corporal',
      subtitle: 'Método US Navy',
      icon: Icons.pie_chart,
      accentColor: CalculatorAccentColors.health,
      currentCategory: 'saude',
      maxContentWidth: 700,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () => Share.share(
              ShareFormatter.formatBodyFatCalculation(
                gender: _isMale ? 'Masculino' : 'Feminino',
                weight: double.parse(_weightController.text),
                height: double.parse(_heightController.text),
                waist: double.parse(_waistController.text),
                neck: double.parse(_neckController.text),
                hip: !_isMale ? double.tryParse(_hipController.text) : null,
                bodyFatPercentage: _result!.bodyFatPercentage,
                category: _result!.categoryText,
                fatMassKg: _result!.fatMassKg,
                leanMassKg: _result!.leanMassKg,
              ),
            ),
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
              // Gender selection
              Text(
                'Selecione o gênero',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withValues(alpha: 0.8) 
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _GenderButton(
                      label: 'Masculino',
                      icon: Icons.male,
                      isSelected: _isMale,
                      onTap: () => setState(() => _isMale = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderButton(
                      label: 'Feminino',
                      icon: Icons.female,
                      isSelected: !_isMale,
                      onTap: () => setState(() => _isMale = false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Basic measurements
              Text(
                'Medidas básicas',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DarkInputField(
                      label: 'Peso',
                      controller: _weightController,
                      suffix: 'kg',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Obrigatório';
                        final num = double.tryParse(value);
                        if (num == null || num <= 0 || num > 500) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DarkInputField(
                      label: 'Altura',
                      controller: _heightController,
                      suffix: 'cm',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Obrigatório';
                        final num = int.tryParse(value);
                        if (num == null || num < 50 || num > 300) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Circumference measurements
              Text(
                'Circunferências',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 150,
                    child: _DarkInputField(
                      label: 'Cintura',
                      controller: _waistController,
                      suffix: 'cm',
                      hintText: 'No umbigo',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Obrigatório';
                        final num = double.tryParse(value);
                        if (num == null || num < 40 || num > 200) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: _DarkInputField(
                      label: 'Pescoço',
                      controller: _neckController,
                      suffix: 'cm',
                      hintText: 'Abaixo do pomo',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Obrigatório';
                        final num = double.tryParse(value);
                        if (num == null || num < 20 || num > 80) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  if (!_isMale)
                    SizedBox(
                      width: 150,
                      child: _DarkInputField(
                        label: 'Quadril',
                        controller: _hipController,
                        suffix: 'cm',
                        hintText: 'Parte mais larga',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (!_isMale) {
                            if (value == null || value.isEmpty) return 'Obrigatório';
                            final num = double.tryParse(value);
                            if (num == null || num < 50 || num > 200) return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Action buttons
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: CalculatorAccentColors.health,
              ),

              // Result
              if (_result != null) ...[
                const SizedBox(height: 32),
                _BodyFatResultCard(result: _result!, isMale: _isMale),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    double? hipCm;
    if (!_isMale && _hipController.text.isNotEmpty) {
      hipCm = double.tryParse(_hipController.text);
    }

    final result = BodyFatCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      heightCm: double.parse(_heightController.text),
      waistCm: double.parse(_waistController.text),
      neckCm: double.parse(_neckController.text),
      hipCm: hipCm,
      isMale: _isMale,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _weightController.clear();
    _heightController.clear();
    _waistController.clear();
    _neckController.clear();
    _hipController.clear();
    setState(() {
      _isMale = true;
      _result = null;
    });
  }
}

/// Dark themed input field for the calculator
class _DarkInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _DarkInputField({
    required this.label,
    required this.controller,
    this.suffix,
    this.hintText,
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
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 14,
            ),
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
                color: Theme.of(context).colorScheme.primary,
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

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = CalculatorAccentColors.health;

    return Material(
      color: isSelected 
          ? accentColor.withValues(alpha: 0.15)
          : (isDark ? Colors.white.withValues(alpha: 0.05) : theme.colorScheme.surfaceContainerHighest),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : (isDark ? Colors.white.withValues(alpha: 0.1) : theme.colorScheme.outline.withValues(alpha: 0.3)),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? accentColor
                    : (isDark ? Colors.white.withValues(alpha: 0.6) : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                  color: isSelected
                      ? accentColor
                      : (isDark ? Colors.white.withValues(alpha: 0.7) : theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyFatResultCard extends StatelessWidget {
  final BodyFatResult result;
  final bool isMale;

  const _BodyFatResultCard({required this.result, required this.isMale});

  Color _getCategoryColor(BodyFatCategory category) {
    return switch (category) {
      BodyFatCategory.essential => Colors.red,
      BodyFatCategory.athlete => Colors.blue,
      BodyFatCategory.fitness => Colors.green,
      BodyFatCategory.average => Colors.orange,
      BodyFatCategory.obese => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    final classificationColor = _getCategoryColor(result.category);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: classificationColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.assessment, color: CalculatorAccentColors.health),
              const SizedBox(width: 8),
              Text(
                'Resultado',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main result
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: classificationColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: classificationColor, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  '${result.bodyFatPercentage}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: classificationColor,
                  ),
                ),
                Text(
                  'Gordura Corporal',
                  style: TextStyle(
                    color: classificationColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Classification chip
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: classificationColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                result.categoryText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Body composition
          Row(
            children: [
              Expanded(
                child: _CompositionCard(
                  label: 'Massa Gorda',
                  value: '${result.fatMassKg} kg',
                  icon: Icons.water_drop,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompositionCard(
                  label: 'Massa Magra',
                  value: '${result.leanMassKg} kg',
                  icon: Icons.fitness_center,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reference ranges
          Text(
            'Faixas de referência (${isMale ? 'Homens' : 'Mulheres'})',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _BodyFatRangeChart(
            ranges: BodyFatCalculator.getRanges(isMale),
            currentValue: result.bodyFatPercentage,
          ),

          const SizedBox(height: 16),

          // Recommendation
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Colors.amber.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.recommendation,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompositionCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _CompositionCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyFatRangeChart extends StatelessWidget {
  final Map<String, (double, double)> ranges;
  final double currentValue;

  const _BodyFatRangeChart({
    required this.ranges,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red.shade300,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: List.generate(ranges.length, (index) {
              final entry = ranges.entries.elementAt(index);
              final range = entry.value;
              final width = (range.$2 - range.$1).clamp(5.0, 30.0);
              
              return Expanded(
                flex: width.toInt(),
                child: Container(
                  height: 24,
                  color: colors[index],
                  child: Center(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0%', style: TextStyle(fontSize: 10)),
            Text('Você: ${currentValue}%',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Text('50%', style: TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
