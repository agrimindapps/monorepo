// Flutter imports:
// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import '../../domain/usecases/calculate_emergency_reserve_usecase.dart';
import '../providers/emergency_reserve_calculator_provider.dart';
import '../widgets/emergency_reserve_input_form.dart';
import '../widgets/emergency_reserve_result_card.dart';

/// Page for calculating emergency reserve (Reserva de Emergência)
///
/// Follows Clean Architecture:
/// - Presentation layer only
/// - Uses Riverpod for state management
/// - Delegates business logic to use cases
class EmergencyReserveCalculatorPage extends ConsumerStatefulWidget {
  const EmergencyReserveCalculatorPage({super.key});

  @override
  ConsumerState<EmergencyReserveCalculatorPage> createState() =>
      _EmergencyReserveCalculatorPageState();
}

class _EmergencyReserveCalculatorPageState
    extends ConsumerState<EmergencyReserveCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emergencyReserveCalculatorProvider);

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
                      'Calculadora de Reserva de Emergência',
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
                            'Calcule sua reserva de emergência',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ShadcnStyle.textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input Form
                          EmergencyReserveInputForm(
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
                      child: EmergencyReserveResultCard(
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

  void _handleCalculate(CalculateEmergencyReserveParams params) {
    ref
        .read(emergencyReserveCalculatorProvider.notifier)
        .calculate(params);
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    ref
        .read(emergencyReserveCalculatorProvider.notifier)
        .clearCalculation();
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sobre a Reserva de Emergência'),
        content: const SingleChildScrollView(
          child: Text(
            'A reserva de emergência é um fundo destinado a cobrir despesas inesperadas e garantir segurança financeira.\n\n'
            'Recomendações por perfil:\n'
            '• Emprego estável: 3-6 meses de despesas\n'
            '• Autônomo/Freelancer: 6-12 meses\n'
            '• Família com dependentes: 6-12 meses\n'
            '• Alta incerteza: 12+ meses\n\n'
            'Onde investir:\n'
            '• Liquidez diária (Tesouro Selic, CDB/RDB)\n'
            '• Baixo risco\n'
            '• Rendimento acima da inflação\n\n'
            'Dicas:\n'
            '• Estabeleça meta mensal de economia\n'
            '• Automatize os aportes\n'
            '• Não utilize exceto em emergências reais\n'
            '• Reponha imediatamente após uso',
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
