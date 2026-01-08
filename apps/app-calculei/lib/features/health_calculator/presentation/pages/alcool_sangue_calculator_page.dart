import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/alcool_sangue_calculator.dart';
import '../../domain/calculators/bmi_calculator.dart' show Gender;

/// Página da calculadora de álcool no sangue
class AlcoolSangueCalculatorPage extends StatefulWidget {
  const AlcoolSangueCalculatorPage({super.key});

  @override
  State<AlcoolSangueCalculatorPage> createState() =>
      _AlcoolSangueCalculatorPageState();
}

class _AlcoolSangueCalculatorPageState
    extends State<AlcoolSangueCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _drinksController = TextEditingController();
  final _hoursController = TextEditingController();

  Gender _gender = Gender.male;
  DrinkType _drinkType = DrinkType.beer;
  BloodAlcoholResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    _drinksController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Álcool no Sangue',
      subtitle: 'Blood Alcohol Concentration (BAC)',
      icon: Icons.local_bar,
      accentColor: CalculatorAccentColors.health,
      categoryName: 'Saúde',
      instructions: 'Estima o BAC usando a fórmula de Widmark. '
          'ATENÇÃO: Esta é apenas uma estimativa. Não dirija após consumir qualquer quantidade de álcool.',
      maxContentWidth: 700,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {
              // Share is handled in result card
            },
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'NUNCA dirija após consumir álcool. Lei Seca: 0 tolerância no Brasil.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Gender selection
              Text(
                'Selecione o gênero',
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
                    child: _GenderButton(
                      label: 'Masculino',
                      icon: Icons.male,
                      isSelected: _gender == Gender.male,
                      onTap: () => setState(() => _gender = Gender.male),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderButton(
                      label: 'Feminino',
                      icon: Icons.female,
                      isSelected: _gender == Gender.female,
                      onTap: () => setState(() => _gender = Gender.female),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Weight input
              _DarkInputField(
                label: 'Peso',
                controller: _weightController,
                suffix: 'kg',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigatório';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num <= 0 || num > 500) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Drink type selection
              Text(
                'Tipo de bebida',
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
                children: [
                  _DrinkTypeChip(
                    type: DrinkType.beer,
                    label: '🍺 Cerveja (350ml)',
                    isSelected: _drinkType == DrinkType.beer,
                    onTap: () => setState(() => _drinkType = DrinkType.beer),
                  ),
                  _DrinkTypeChip(
                    type: DrinkType.wine,
                    label: '🍷 Vinho (150ml)',
                    isSelected: _drinkType == DrinkType.wine,
                    onTap: () => setState(() => _drinkType = DrinkType.wine),
                  ),
                  _DrinkTypeChip(
                    type: DrinkType.spirits,
                    label: '🥃 Destilado (45ml)',
                    isSelected: _drinkType == DrinkType.spirits,
                    onTap: () => setState(() => _drinkType = DrinkType.spirits),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Inputs Row
              Row(
                children: [
                  Expanded(
                    child: _DarkInputField(
                      label: 'Número de doses',
                      controller: _drinksController,
                      suffix: 'doses',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num <= 0 || num > 50) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DarkInputField(
                      label: 'Horas desde 1ª dose',
                      controller: _hoursController,
                      suffix: 'horas',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final num = double.tryParse(value);
                        if (num == null || num < 0 || num > 48) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Calculate button
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate_rounded),
                  label: const Text(
                    'Calcular BAC',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CalculatorAccentColors.health,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              // Result
              if (_result != null) ...[
                const SizedBox(height: 32),
                _BacResultCard(result: _result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = AlcoolSangueCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      drinksCount: int.parse(_drinksController.text),
      drinkType: _drinkType,
      hoursSinceDrinking: double.parse(_hoursController.text),
      gender: _gender,
    );

    setState(() => _result = result);
  }
}

/// Dark themed input field for the calculator
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
                color: CalculatorAccentColors.health,
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
    const accentColor = CalculatorAccentColors.health;

    return Material(
      color: isSelected 
          ? accentColor.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.05),
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
                  : Colors.white.withValues(alpha: 0.1),
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
                    : Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
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

class _DrinkTypeChip extends StatelessWidget {
  final DrinkType type;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrinkTypeChip({
    required this.type,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.health;

    return Material(
      color: isSelected
          ? accentColor.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: CalculatorAccentColors.health,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? accentColor
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BacResultCard extends StatelessWidget {
  final BloodAlcoholResult result;

  const _BacResultCard({required this.result});

  Color _getLevelColor(BacLevel level) {
    return switch (level) {
      BacLevel.sober => Colors.green,
      BacLevel.mild => Colors.amber,
      BacLevel.moderate => Colors.orange,
      BacLevel.high => Colors.red,
      BacLevel.veryHigh => Colors.red.shade900,
    };
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor(result.level);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: levelColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with share
          Row(
            children: [
              const Icon(Icons.assessment, color: CalculatorAccentColors.health),
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
                text: ShareFormatter.formatGeneric(
                  title: 'Álcool no Sangue',
                  data: {
                    '📊 BAC': '${result.bac.toStringAsFixed(3)} g/dL',
                    '🏷️ Nível': result.levelText,
                    '⚠️ Pode dirigir?': result.canDrive ? 'Sim' : 'NÃO',
                    '💡 Aviso': result.warning,
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // BAC Value
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: levelColor, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    result.bac.toStringAsFixed(3),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
                  ),
                  Text(
                    'g/dL',
                    style: TextStyle(
                      color: levelColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Level chip
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: levelColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                result.levelText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Can drive indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: result.canDrive
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: result.canDrive ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  result.canDrive ? Icons.check_circle : Icons.cancel,
                  color: result.canDrive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.canDrive
                        ? 'Abaixo do limite legal'
                        : 'PROIBIDO DIRIGIR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: result.canDrive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Effects
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Efeitos esperados',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  result.effects,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Warning
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
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: Colors.amber.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.warning,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
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
