import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/usecases/calculate_net_salary_usecase.dart';
import '../providers/net_salary_calculator_provider.dart';
import '../widgets/net_salary_input_form.dart';
import '../widgets/net_salary_result_card.dart';

/// Page for calculating net salary (Salário Líquido)
class NetSalaryCalculatorPage extends ConsumerStatefulWidget {
  const NetSalaryCalculatorPage({super.key});

  @override
  ConsumerState<NetSalaryCalculatorPage> createState() =>
      _NetSalaryCalculatorPageState();
}

class _NetSalaryCalculatorPageState
    extends ConsumerState<NetSalaryCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _inputFormKey = GlobalKey<NetSalaryInputFormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(netSalaryCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Salário Líquido',
      subtitle: 'Descontos e Valor Líquido',
      icon: Icons.account_balance_wallet_outlined,
      accentColor: CalculatorAccentColors.financial,
      currentCategory: 'financeiro',
      maxContentWidth: 700,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Form
            NetSalaryInputForm(
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

            // Result Card or Empty State
            const SizedBox(height: 32),
            if (state.calculation != null)
              NetSalaryResultCard(calculation: state.calculation!),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    // Call the form's submit method which validates and calculates
    _inputFormKey.currentState?.submit();
  }

  void _handleCalculate(CalculateNetSalaryParams params) {
    ref.read(netSalaryCalculatorProvider.notifier).calculate(params);
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    _inputFormKey.currentState?.clear();
    ref.read(netSalaryCalculatorProvider.notifier).clearCalculation();
  }
}
