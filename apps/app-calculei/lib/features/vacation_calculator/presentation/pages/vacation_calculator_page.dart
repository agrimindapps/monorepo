import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/calculator_content_repository.dart';
import '../../../../shared/widgets/educational_tabs.dart';
import '../../../../shared/widgets/share_button.dart';
import '../providers/vacation_calculator_provider.dart';
import '../widgets/calculation_result_card.dart';
import '../widgets/vacation_input_form.dart';

/// Vacation calculator page
class VacationCalculatorPage extends ConsumerWidget {
  const VacationCalculatorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculation = ref.watch(vacationCalculatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Férias'),
        actions: [
          if (calculation.id.isNotEmpty)
            ShareButton(
              text: ShareFormatter.formatVacationCalculation(
                grossSalary: calculation.grossSalary,
                vacationDays: calculation.vacationDays,
                totalGross: calculation.grossTotal,
                totalNet: calculation.netTotal,
              ),
              subject: 'Cálculo de Férias',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Como funciona',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Férias = (Salário / 30) × Dias\n'
                        '• Adicional 1/3 constitucional\n'
                        '• Abono pecuniário (venda até 1/3 das férias)\n'
                        '• Descontos de INSS e IR aplicados',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Input Form
              VacationInputForm(
                onCalculate: (grossSalary, vacationDays, sellVacationDays) {
                  _performCalculation(
                    ref,
                    context,
                    grossSalary: grossSalary,
                    vacationDays: vacationDays,
                    sellVacationDays: sellVacationDays,
                  );
                },
              ),

              const SizedBox(height: 24),

              // Result Card
              if (calculation.id.isNotEmpty)
                CalculationResultCard(calculation: calculation),

              const SizedBox(height: 32),

              // Educational Tabs
              if (CalculatorContentRepository.hasContent(
                  '/calculators/financial/vacation')) ...[
                Text(
                  'Saiba Mais',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                EducationalTabs(
                  content: CalculatorContentRepository.getContent(
                      '/calculators/financial/vacation')!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performCalculation(
    WidgetRef ref,
    BuildContext context, {
    required double grossSalary,
    required int vacationDays,
    required bool sellVacationDays,
  }) async {
    try {
      await ref.read(vacationCalculatorProvider.notifier).calculate(
            grossSalary: grossSalary,
            vacationDays: vacationDays,
            sellVacationDays: sellVacationDays,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cálculo realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
