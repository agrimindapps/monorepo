import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/usecases/calculate_concrete_usecase.dart';
import '../providers/concrete_calculator_provider.dart';
import '../widgets/concrete_input_form.dart';
import '../widgets/concrete_result_card.dart';

/// Page for calculating concrete materials
class ConcreteCalculatorPage extends ConsumerStatefulWidget {
  const ConcreteCalculatorPage({super.key});

  @override
  ConsumerState<ConcreteCalculatorPage> createState() =>
      _ConcreteCalculatorPageState();
}

class _ConcreteCalculatorPageState
    extends ConsumerState<ConcreteCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(concreteCalculatorProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/construction/selection'),
        ),
        title: const Row(
          children: [
            Icon(Icons.foundation, color: Colors.grey),
            SizedBox(width: 8),
            Text('Concreto'),
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
                            'Calcular quantidade de concreto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input Form
                          ConcreteInputForm(
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
                      child: ConcreteResultCard(
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

  void _handleCalculate(CalculateConcreteParams params) {
    // Execute the calculation through the notifier
    ref.read(concreteCalculatorProvider.notifier).calculate(params);
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    ref.read(concreteCalculatorProvider.notifier).clearCalculation();
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Concreto'),
        content: const SingleChildScrollView(
          child: Text(
            'Esta calculadora determina a quantidade de materiais necessários para produzir concreto.\n\n'
            'Como funciona:\n'
            '• Dimensões do volume (comprimento × largura × altura)\n'
            '• Tipo de concreto (fck - resistência característica)\n'
            '• Preços dos materiais (opcional)\n\n'
            'Materiais calculados:\n'
            '• Cimento (sacos de 50kg)\n'
            '• Areia (m³)\n'
            '• Brita (m³)\n'
            '• Água (litros)\n\n'
            'Tipos de concreto:\n'
            '• FCK 10-15: Estruturas simples\n'
            '• FCK 20: Lajes, vigas, pilares\n'
            '• FCK 25-30: Estruturas especiais\n\n'
            'Fatores importantes:\n'
            '• Volume em metros cúbicos\n'
            '• Traço baseado em normas brasileiras\n'
            '• Considere perdas no transporte\n'
            '• Cimento deve ser usado no prazo de validade\n\n'
            'O cálculo segue as normas da ABNT (NBR 6118).',
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
