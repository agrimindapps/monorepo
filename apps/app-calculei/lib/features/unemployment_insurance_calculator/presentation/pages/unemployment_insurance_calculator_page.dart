// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';

import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import '../../domain/usecases/calculate_unemployment_insurance_usecase.dart';
import '../providers/unemployment_insurance_calculator_provider.dart';
import '../widgets/unemployment_insurance_input_form.dart';
import '../widgets/unemployment_insurance_result_card.dart';

/// Page for calculating unemployment insurance (Seguro Desemprego)
///
/// Follows Clean Architecture:
/// - Presentation layer only
/// - Uses Riverpod for state management
/// - Delegates business logic to use cases
class UnemploymentInsuranceCalculatorPage extends ConsumerStatefulWidget {
  const UnemploymentInsuranceCalculatorPage({super.key});

  @override
  ConsumerState<UnemploymentInsuranceCalculatorPage> createState() =>
      _UnemploymentInsuranceCalculatorPageState();
}

class _UnemploymentInsuranceCalculatorPageState
    extends ConsumerState<UnemploymentInsuranceCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unemploymentInsuranceCalculatorProvider);

    return Scaffold(
      appBar: CalculatorAppBar(
        actions: [
          InfoAppBarAction(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Calculadora de Seguro Desemprego',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
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
                            'Calcule seu seguro desemprego',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ShadcnStyle.textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input Form
                          UnemploymentInsuranceInputForm(
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
                                  state.isLoading ? 'Calculando...' : 'Calcular',
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
                      child: UnemploymentInsuranceResultCard(
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
      _formKey.currentState!.save();
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

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sobre o Seguro Desemprego'),
        content: const SingleChildScrollView(
          child: Text(
            'O seguro-desemprego é um benefício pago ao trabalhador demitido sem justa causa.\n\n'
            'Requisitos:\n'
            '• Demissão sem justa causa\n'
            '• Estar desempregado\n'
            '• Não ter renda própria\n'
            '• Não receber BPC (benefício assistencial)\n\n'
            'Carência (tempo mínimo trabalhado):\n'
            '• 1ª solicitação: 12 meses\n'
            '• 2ª solicitação: 9 meses\n'
            '• 3ª+ solicitação: 6 meses\n\n'
            'Número de parcelas:\n'
            '• Varia de 3 a 5 parcelas\n'
            '• Depende do tempo trabalhado\n'
            '• Considera se já recebeu antes\n\n'
            'Prazo para solicitar:\n'
            '• De 7 a 120 dias após a demissão\n\n'
            'Valores:\n'
            '• Baseado nos últimos 3 salários\n'
            '• Mínimo: 1 salário mínimo\n'
            '• Máximo: R\$ 2.230,97 (2024)\n\n'
            'Este cálculo é uma estimativa baseada nas regras de 2024.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
