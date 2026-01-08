import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
import '../providers/vacation_calculator_provider.dart';
import '../widgets/calculation_result_card.dart';

/// Vacation calculator page
class VacationCalculatorPage extends ConsumerStatefulWidget {
  const VacationCalculatorPage({super.key});

  @override
  ConsumerState<VacationCalculatorPage> createState() =>
      _VacationCalculatorPageState();
}

class _VacationCalculatorPageState
    extends ConsumerState<VacationCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _grossSalaryController = TextEditingController();
  final _vacationDaysController = TextEditingController();
  bool _sellVacationDays = false;

  @override
  void dispose() {
    _grossSalaryController.dispose();
    _vacationDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(vacationCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Férias',
      subtitle: 'Férias + 1/3 Constitucional',
      icon: Icons.beach_access_outlined,
      accentColor: CalculatorAccentColors.labor,
      categoryName: 'Trabalhista',
      instructions: 'Digite seu salário bruto e dias de férias para calcular o valor a receber. '
          'Você pode optar por vender até 1/3 das férias (abono pecuniário).',
      maxContentWidth: 700,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input fields
              _DarkInputField(
                label: 'Salário Bruto',
                controller: _grossSalaryController,
                prefix: 'R\$',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigatório';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _DarkInputField(
                label: 'Dias de Férias',
                controller: _vacationDaysController,
                suffix: 'dias',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigatório';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 1 || num > 30) {
                    return 'Entre 1 e 30 dias';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Sell vacation days checkbox
              Material(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    setState(() => _sellVacationDays = !_sellVacationDays);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _sellVacationDays
                            ? CalculatorAccentColors.labor
                            : Colors.white.withValues(alpha: 0.1),
                        width: _sellVacationDays ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _sellVacationDays,
                          onChanged: (value) {
                            setState(() => _sellVacationDays = value ?? false);
                          },
                          activeColor: CalculatorAccentColors.labor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vender 1/3 das férias',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Abono pecuniário',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Calculate button
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate_rounded),
                  label: const Text(
                    'Calcular Férias',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CalculatorAccentColors.labor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              // Result
              if (calculation.id.isNotEmpty) ...[
                const SizedBox(height: 32),
                CalculationResultCard(calculation: calculation),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref.read(vacationCalculatorProvider.notifier).calculate(
            grossSalary: double.parse(_grossSalaryController.text),
            vacationDays: int.parse(_vacationDaysController.text),
            sellVacationDays: _sellVacationDays,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Férias calculadas com sucesso!'),
            backgroundColor: CalculatorAccentColors.labor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Dark themed input field for the calculator
class _DarkInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? prefix;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _DarkInputField({
    required this.label,
    required this.controller,
    this.prefix,
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
            prefixText: prefix,
            prefixStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
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
              borderSide: const BorderSide(
                color: CalculatorAccentColors.labor,
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
