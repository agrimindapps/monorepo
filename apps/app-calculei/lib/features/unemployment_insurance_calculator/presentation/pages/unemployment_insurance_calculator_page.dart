import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/usecases/calculate_unemployment_insurance_usecase.dart';
import '../providers/unemployment_insurance_calculator_provider.dart';
import '../widgets/unemployment_insurance_input_form.dart';
import '../widgets/unemployment_insurance_result_card.dart';

/// Page for calculating unemployment insurance (Seguro Desemprego)
class UnemploymentInsuranceCalculatorPage extends ConsumerStatefulWidget {
  const UnemploymentInsuranceCalculatorPage({super.key});

  @override
  ConsumerState<UnemploymentInsuranceCalculatorPage> createState() =>
      _UnemploymentInsuranceCalculatorPageState();
}

class _UnemploymentInsuranceCalculatorPageState
    extends ConsumerState<UnemploymentInsuranceCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _inputFormKey = GlobalKey<UnemploymentInsuranceInputFormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unemploymentInsuranceCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Seguro Desemprego',
      subtitle: 'Benefício Assistencial',
      icon: Icons.health_and_safety_outlined,
      accentColor: CalculatorAccentColors.labor,
      categoryName: 'Trabalhista',
      instructions: 'Calcule o valor e parcelas do seguro-desemprego. '
          'Informe os últimos 3 salários, tempo trabalhado e se já recebeu antes. '
          'O benefício é pago ao trabalhador demitido sem justa causa.',
      maxContentWidth: 700,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Form
            UnemploymentInsuranceInputForm(
              key: _inputFormKey,
              formKey: _formKey,
              onCalculate: _handleCalculate,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            CalculatorActionButtons(
              onCalculate: _handleSubmit,
              onClear: _handleClear,
              accentColor: CalculatorAccentColors.labor,
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
              UnemploymentInsuranceResultCard(calculation: state.calculation!),
            ],
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _inputFormKey.currentState?.submit();
    }
  }

  void _handleCalculate(CalculateUnemploymentInsuranceParams params) {
    ref
        .read(unemploymentInsuranceCalculatorProvider.notifier)
        .calculate(params);
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    ref
        .read(unemploymentInsuranceCalculatorProvider.notifier)
        .clearCalculation();
  }
}
