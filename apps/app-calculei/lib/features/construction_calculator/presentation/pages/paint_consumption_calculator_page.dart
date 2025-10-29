import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/paint_consumption_calculator_provider.dart';
import '../widgets/paint_consumption_input_form.dart';
import '../widgets/paint_consumption_result_card.dart';
import '../../domain/usecases/calculate_paint_consumption_usecase.dart';

/// Page for calculating paint consumption
class PaintConsumptionCalculatorPage extends ConsumerStatefulWidget {
  const PaintConsumptionCalculatorPage({super.key});

  @override
  ConsumerState<PaintConsumptionCalculatorPage> createState() =>
      _PaintConsumptionCalculatorPageState();
}

class _PaintConsumptionCalculatorPageState
    extends ConsumerState<PaintConsumptionCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paintConsumptionCalculatorNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/construction/selection'),
        ),
        title: const Row(
          children: [
            Icon(Icons.format_paint, color: Colors.blue),
            SizedBox(width: 8),
            Text('Consumo de Tinta'),
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
                            'Calcular consumo de tinta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input Form
                          PaintConsumptionInputForm(
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
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
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
                      child: PaintConsumptionResultCard(
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

  void _handleCalculate(CalculatePaintConsumptionParams params) {
    // Execute the calculation through the notifier
    ref
        .read(paintConsumptionCalculatorNotifierProvider.notifier)
        .calculate(params);
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    ref
        .read(paintConsumptionCalculatorNotifierProvider.notifier)
        .clearCalculation();
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consumo de Tinta'),
        content: const SingleChildScrollView(
          child: Text(
            'Esta calculadora determina a quantidade de tinta necessária para pintar uma superfície.\n\n'
            'Fatores considerados:\n'
            '• Área da superfície em metros quadrados\n'
            '• Preparo da superfície (parede nova, repintura, etc.)\n'
            '• Número de demãos necessárias\n\n'
            'Preparo da superfície:\n'
            '• Parede nova: 1.0 (superfície lisa)\n'
            '• Repintura: 1.2 (superfície já pintada)\n'
            '• Superfície irregular: 1.5 (textura, reboco novo)\n'
            '• Superfície muito irregular: 2.0 (cimento, concreto)\n\n'
            'Demãos recomendadas:\n'
            '• Pintura nova: 2 demãos\n'
            '• Repintura: 1-2 demãos\n'
            '• Cores escuras sobre claras: 2-3 demãos\n\n'
            'Rendimento médio: 10-12 m² por litro (depende da tinta e superfície).\n\n'
            'Considere comprar 10-15% a mais para compensar perdas.',
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
