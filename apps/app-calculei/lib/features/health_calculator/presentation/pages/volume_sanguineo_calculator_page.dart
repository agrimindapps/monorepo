import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../../domain/calculators/bmi_calculator.dart';
import '../../domain/calculators/volume_sanguineo_calculator.dart';

/// Página da calculadora de volume sanguíneo
class VolumeSanguineoCalculatorPage extends StatefulWidget {
  const VolumeSanguineoCalculatorPage({super.key});

  @override
  State<VolumeSanguineoCalculatorPage> createState() =>
      _VolumeSanguineoCalculatorPageState();
}

class _VolumeSanguineoCalculatorPageState
    extends State<VolumeSanguineoCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  Gender _gender = Gender.male;
  bool _useSimplified = false;
  BloodVolumeResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Volume Sanguíneo',
      subtitle: 'Estimativa de volume total',
      icon: Icons.water_drop_outlined,
      accentColor: CalculatorAccentColors.health,
      currentCategory: 'saude',
      maxContentWidth: 600,
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = isDark ? Colors.white : Colors.black87;
          final subtleTextColor = isDark 
              ? Colors.white.withValues(alpha: 0.8) 
              : Colors.black.withValues(alpha: 0.6);

          return Padding(
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
                      color: subtleTextColor,
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

                  // Input fields
                  Row(
                    children: [
                      Expanded(
                        child: AdaptiveInputField(
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AdaptiveInputField(
                          label: 'Altura',
                          controller: _heightController,
                          suffix: 'cm',
                          enabled: !_useSimplified,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (_useSimplified) {
                              return null;
                            }
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório';
                            }
                            final num = int.tryParse(value);
                            if (num == null || num < 50 || num > 300) {
                              return 'Valor inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Method selection
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Usar método simplificado',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Mais rápido, mas menos preciso (não usa altura)',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.black.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      value: _useSimplified,
                      onChanged: (value) {
                        setState(() => _useSimplified = value);
                      },
                      activeThumbColor: CalculatorAccentColors.health,
                    ),
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
                    _BloodVolumeResultCard(result: _result!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = VolumeSanguineoCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      heightCm: _useSimplified
          ? 170.0
          : double.parse(_heightController.text),
      gender: _gender,
      useSimplified: _useSimplified,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _weightController.clear();
    _heightController.clear();
    setState(() {
      _gender = Gender.male;
      _useSimplified = false;
      _result = null;
    });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isSelected 
          ? accentColor.withValues(alpha: 0.15)
          : isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
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
                  : isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
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
                    : isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                  color: isSelected
                      ? accentColor
                      : isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BloodVolumeResultCard extends StatelessWidget {
  final BloodVolumeResult result;

  const _BloodVolumeResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    const bloodColor = Color(0xFFE91E63); // Pink/Rose matching health accent
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bloodColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Blood volume
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: bloodColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: bloodColor, width: 2),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.water_drop,
                  size: 48,
                  color: bloodColor,
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.volumeLiters}L',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: bloodColor,
                  ),
                ),
                Text(
                  '${result.volumeMl.toStringAsFixed(0)} ml',
                  style: const TextStyle(
                    color: bloodColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Method chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: bloodColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.method,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Interpretation
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.interpretation,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

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
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.black.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Fun facts
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      size: 18,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Você sabia?',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '• O sangue representa 7-8% do peso corporal\n'
                  '• Um adulto tem cerca de 5-6 litros de sangue\n'
                  '• O corpo repõe sangue doado em 24-48h',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.6),
                    height: 1.5,
                    fontSize: 13,
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
