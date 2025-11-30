// Flutter imports:
// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/usecases/calculate_cash_vs_installment_usecase.dart';
import '../providers/cash_vs_installment_calculator_provider.dart';
import '../widgets/cash_vs_installment_input_form.dart';
import '../widgets/cash_vs_installment_result_card.dart';

/// Page for calculating cash vs installment (À vista ou Parcelado)
///
/// Follows Clean Architecture:
/// - Presentation layer only
/// - Uses Riverpod for state management
/// - Delegates business logic to use cases
class CashVsInstallmentCalculatorPage extends ConsumerStatefulWidget {
  const CashVsInstallmentCalculatorPage({super.key});

  @override
  ConsumerState<CashVsInstallmentCalculatorPage> createState() =>
      _CashVsInstallmentCalculatorPageState();
}

class _CashVsInstallmentCalculatorPageState
    extends ConsumerState<CashVsInstallmentCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashVsInstallmentCalculatorProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Row(
          children: [
            Icon(Icons.payment, color: Colors.indigo),
            SizedBox(width: 8),
            Text('À vista ou Parcelado'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Input Form Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Compare à vista vs parcelado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ShadcnStyle.textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input Form
                          CashVsInstallmentInputForm(
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
                                style: ShadcnStyle.textButtonStyle,
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed:
                                    state.isLoading ? null : _handleSubmit,
                                icon: state.isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.calculate),
                                label: Text(
                                  state.isLoading
                                      ? 'Calculando...'
                                      : 'Calcular',
                                ),
                                style: ShadcnStyle.primaryButtonStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Error Message
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
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
                    ),
                  ],

                  // Result Card
                  if (state.calculation != null) ...[
                    const SizedBox(height: 24),
                    AnimatedOpacity(
                      opacity: state.calculation != null ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: CashVsInstallmentResultCard(
                        calculation: state.calculation!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // The form's onSaved callbacks will trigger _submitForm()
      // which calls the onCalculate callback from the form widget
      _formKey.currentState!.save();
    }
  }

  void _handleCalculate(CalculateCashVsInstallmentParams params) {
    // Execute the calculation through the notifier
    ref
        .read(cashVsInstallmentCalculatorProvider.notifier)
        .calculate(params);
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    ref
        .read(cashVsInstallmentCalculatorProvider.notifier)
        .clearCalculation();
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À vista ou Parcelado?'),
        content: const SingleChildScrollView(
          child: Text(
            'Esta calculadora compara o custo real de pagar à vista versus parcelado, considerando o valor do dinheiro no tempo.\n\n'
            'O que é calculado:\n'
            '• Valor total parcelado\n'
            '• Taxa de juros implícita\n'
            '• Valor presente das parcelas\n'
            '• Melhor opção financeira\n\n'
            'Taxa de juros:\n'
            'Informe a taxa que você conseguiria ao aplicar o dinheiro (geralmente Selic ou CDI).\n\n'
            'Valor presente:\n'
            'É quanto as parcelas futuras valem hoje, descontadas pela taxa de juros.\n\n'
            'Recomendação:\n'
            '• Se valor presente < preço à vista: parcelar é melhor\n'
            '• Se valor presente > preço à vista: à vista é melhor\n\n'
            'Considere também sua situação de liquidez e reserva de emergência ao decidir.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
