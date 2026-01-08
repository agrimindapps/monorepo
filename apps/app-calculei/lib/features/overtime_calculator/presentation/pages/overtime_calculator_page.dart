import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/usecases/calculate_overtime_usecase.dart';
import '../providers/overtime_calculator_provider.dart';
import '../widgets/overtime_input_form.dart';
import '../widgets/overtime_result_card.dart';

/// Page for calculating overtime (Horas Extras)
class OvertimeCalculatorPage extends ConsumerStatefulWidget {
  const OvertimeCalculatorPage({super.key});

  @override
  ConsumerState<OvertimeCalculatorPage> createState() =>
      _OvertimeCalculatorPageState();
}

class _OvertimeCalculatorPageState
    extends ConsumerState<OvertimeCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  Key _formKeyId = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(overtimeCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Horas Extras',
      subtitle: 'Horas Trabalhadas + Adicionais',
      icon: Icons.access_time_outlined,
      accentColor: CalculatorAccentColors.labor,
      categoryName: 'Trabalhista',
      instructions: 'Calcule o valor das horas extras trabalhadas. '
          'Informe seu salário base, horas trabalhadas e os adicionais aplicáveis. '
          'O cálculo inclui DSR, reflexos e descontos.',
      maxContentWidth: 700,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Form
            OvertimeInputForm(
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
              OvertimeResultCard(calculation: state.calculation!),
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

  void _handleCalculate(CalculateOvertimeParams params) {
    ref.read(overtimeCalculatorProvider.notifier).calculate(params);
  }

  void _handleClear() {
    setState(() {
      _formKeyId = UniqueKey();
    });
    ref.read(overtimeCalculatorProvider.notifier).clearCalculation();
  }
}
