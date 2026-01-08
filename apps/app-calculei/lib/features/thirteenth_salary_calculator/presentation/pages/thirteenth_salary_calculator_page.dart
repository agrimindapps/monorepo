import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/usecases/calculate_thirteenth_salary_usecase.dart';
import '../providers/thirteenth_salary_calculator_provider.dart';
import '../widgets/thirteenth_salary_input_form.dart';
import '../widgets/thirteenth_salary_result_card.dart';

/// Page for calculating 13th salary (Décimo Terceiro)
class ThirteenthSalaryCalculatorPage extends ConsumerStatefulWidget {
  const ThirteenthSalaryCalculatorPage({super.key});

  @override
  ConsumerState<ThirteenthSalaryCalculatorPage> createState() =>
      _ThirteenthSalaryCalculatorPageState();
}

class _ThirteenthSalaryCalculatorPageState
    extends ConsumerState<ThirteenthSalaryCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  Key _formKeyId = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(thirteenthSalaryCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de 13º Salário',
      subtitle: 'Gratificação Natalina',
      icon: Icons.card_giftcard_outlined,
      accentColor: CalculatorAccentColors.labor,
      categoryName: 'Trabalhista',
      instructions: 'Calcule o valor do seu 13º salário (gratificação natalina). '
          'Informe seu salário bruto, meses trabalhados e dependentes. '
          'O cálculo considera as duas parcelas e os descontos aplicáveis.',
      maxContentWidth: 700,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Form
            ThirteenthSalaryInputForm(
              key: _formKeyId,
              formKey: _formKey,
              onCalculate: _handleCalculate,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _handleClear,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading ? null : _handleSubmit,
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.calculate_rounded),
                    label: Text(
                      state.isLoading ? 'Calculando...' : 'Calcular',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CalculatorAccentColors.labor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: CalculatorAccentColors.labor
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),

            // Error Message
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Result Card
            if (state.calculation != null) ...[
              const SizedBox(height: 32),
              ThirteenthSalaryResultCard(calculation: state.calculation!),
            ],
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }

  void _handleCalculate(CalculateThirteenthSalaryParams params) {
    ref.read(thirteenthSalaryCalculatorProvider.notifier).calculate(params);
  }

  void _handleClear() {
    setState(() {
      _formKeyId = UniqueKey();
    });
    ref.read(thirteenthSalaryCalculatorProvider.notifier).clearCalculation();
  }
}
