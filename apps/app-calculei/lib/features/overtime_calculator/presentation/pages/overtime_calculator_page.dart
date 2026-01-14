import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
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
  final _inputFormKey = GlobalKey<OvertimeInputFormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(overtimeCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Horas Extras',
      subtitle: 'Horas Trabalhadas + Adicionais',
      icon: Icons.access_time_outlined,
      accentColor: CalculatorAccentColors.financial,
      currentCategory: 'financeiro',
      maxContentWidth: 700,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Form
            OvertimeInputForm(
              key: _inputFormKey,
              formKey: _formKey,
              onCalculate: _handleCalculate,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            CalculatorActionButtons(
              onCalculate: _handleSubmit,
              onClear: _handleClear,
              accentColor: CalculatorAccentColors.financial,
              isLoading: state.isLoading,
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
    _inputFormKey.currentState?.submit();
  }

  void _handleCalculate(CalculateOvertimeParams params) {
    ref.read(overtimeCalculatorProvider.notifier).calculate(params);
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    _inputFormKey.currentState?.clear();
    ref.read(overtimeCalculatorProvider.notifier).clearCalculation();
  }
}
