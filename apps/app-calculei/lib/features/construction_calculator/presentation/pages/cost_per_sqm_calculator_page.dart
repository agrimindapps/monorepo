import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/cost_per_sqm_calculator_provider.dart';
import '../widgets/cost_per_sqm_input_form.dart';
import '../widgets/cost_per_sqm_result_card.dart';
import '../../domain/usecases/calculate_cost_per_sqm_usecase.dart';

/// Page for calculating cost per square meter
class CostPerSqmCalculatorPage extends ConsumerStatefulWidget {
  const CostPerSqmCalculatorPage({super.key});

  @override
  ConsumerState<CostPerSqmCalculatorPage> createState() =>
      _CostPerSqmCalculatorPageState();
}

class _CostPerSqmCalculatorPageState
    extends ConsumerState<CostPerSqmCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(costPerSqmCalculatorProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/construction/selection'),
        ),
        title: const Row(
          children: [
            Icon(Icons.attach_money, color: Colors.green),
            SizedBox(width: 8),
            Text('Custo por m²'),
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
                          Text(
                            'Calcular custo por m²',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input Form
                          CostPerSqmInputForm(
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
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: state.isLoading
                                    ? null
                                    : _handleSubmit,
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
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
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error,
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
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
                      child: CostPerSqmResultCard(
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

  void _handleCalculate(CalculateCostPerSqmParams params) {
    // Execute the calculation through the notifier
    ref.read(costPerSqmCalculatorProvider.notifier).calculate(params);
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    ref.read(costPerSqmCalculatorProvider.notifier).clearCalculation();
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custo por m²'),
        content: const SingleChildScrollView(
          child: Text(
            'Esta calculadora determina o custo total de uma obra baseado na área e no valor por metro quadrado.\n\n'
            'Como usar:\n'
            '• Informe a área total em metros quadrados\n'
            '• Digite o custo por m² (valor médio da região)\n'
            '• O resultado mostrará o custo total estimado\n\n'
            'Dicas importantes:\n'
            '• Considere variações regionais no custo por m²\n'
            '• Inclua margem para imprevistos (10-20%)\n'
            '• Compare preços de diferentes fornecedores\n'
            '• Consulte profissionais para orçamentos precisos\n\n'
            'Este cálculo é uma estimativa e não substitui um orçamento profissional.',
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
