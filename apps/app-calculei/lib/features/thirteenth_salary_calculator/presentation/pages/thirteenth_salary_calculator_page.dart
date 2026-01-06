// Flutter imports:
// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/calculator_content_repository.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import '../../../../shared/widgets/educational_tabs.dart';
import '../../domain/usecases/calculate_thirteenth_salary_usecase.dart';
import '../providers/thirteenth_salary_calculator_provider.dart';
import '../widgets/thirteenth_salary_input_form.dart';
import '../widgets/thirteenth_salary_result_card.dart';

/// Page for calculating 13th salary (Décimo Terceiro)
///
/// Follows Clean Architecture:
/// - Presentation layer only
/// - Uses Riverpod for state management
/// - Delegates business logic to use cases
class ThirteenthSalaryCalculatorPage extends ConsumerStatefulWidget {
  const ThirteenthSalaryCalculatorPage({super.key});

  @override
  ConsumerState<ThirteenthSalaryCalculatorPage> createState() =>
      _ThirteenthSalaryCalculatorPageState();
}

class _ThirteenthSalaryCalculatorPageState
    extends ConsumerState<ThirteenthSalaryCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(thirteenthSalaryCalculatorProvider);

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
                      'Calculadora de 13º Salário',
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
                            'Calcule seu 13º salário',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ShadcnStyle.textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Input Form
                          ThirteenthSalaryInputForm(
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
                      child: ThirteenthSalaryResultCard(
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

  void _handleCalculate(CalculateThirteenthSalaryParams params) {
    ref
        .read(thirteenthSalaryCalculatorProvider.notifier)
        .calculate(params);
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    ref
        .read(thirteenthSalaryCalculatorProvider.notifier)
        .clearCalculation();
  }

  void _showInfo(BuildContext context) {
    // Check if educational content exists
    if (CalculatorContentRepository.hasContent(
        '/calculators/financial/thirteenth-salary')) {
      _showEducationalDialog(context);
    } else {
      _showSimpleInfoDialog(context);
    }
  }

  void _showEducationalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Saiba Mais',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),

              // Educational Content
              Expanded(
                child: EducationalTabs(
                  content: CalculatorContentRepository.getContent(
                      '/calculators/financial/thirteenth-salary')!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSimpleInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sobre o 13º Salário'),
        content: const SingleChildScrollView(
          child: Text(
            'O 13º salário (ou gratificação natalina) é um direito de todos os trabalhadores com carteira assinada.\n\n'
            'Características:\n'
            '• Valor: 1/12 do salário por mês trabalhado\n'
            '• Período: Janeiro a dezembro do ano\n'
            '• Faltas: 15 faltas não justificadas = 1 mês descontado\n'
            '• Descontos: INSS e IRRF (se aplicável)\n\n'
            'Parcelas:\n'
            '• 1ª parcela: 50% do salário bruto (até 30 de novembro)\n'
            '• 2ª parcela: Valor líquido - 1ª parcela (até 20 de dezembro)\n\n'
            'Observações:\n'
            '• Descontos (INSS/IRRF) aplicados apenas na 2ª parcela\n'
            '• Dependentes reduzem a base de cálculo do IRRF\n'
            '• Valores baseados na legislação de 2024',
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
