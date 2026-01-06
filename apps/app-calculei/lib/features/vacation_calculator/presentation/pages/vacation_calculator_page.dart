import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/calculator_content_repository.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import '../../../../shared/widgets/educational_tabs.dart';
import '../../../../shared/widgets/share_button.dart';
import '../providers/vacation_calculator_provider.dart';
import '../widgets/calculation_result_card.dart';
import '../widgets/vacation_input_form.dart';

/// Vacation calculator page
class VacationCalculatorPage extends ConsumerStatefulWidget {
  const VacationCalculatorPage({super.key});

  @override
  ConsumerState<VacationCalculatorPage> createState() =>
      _VacationCalculatorPageState();
}

class _VacationCalculatorPageState
    extends ConsumerState<VacationCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(vacationCalculatorProvider);

    return Scaffold(
      appBar: CalculatorAppBar(
        actions: [
          InfoAppBarAction(
            onPressed: () => _showEducationalDialog(context),
          ),
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
              // Page Title
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Calculadora de Férias',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              // Info Card (Quick Reference)
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
                              .withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Input Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Result Card
              if (calculation.id.isNotEmpty)
                CalculationResultCard(calculation: calculation),
            ],
          ),
        ),
      ),
    );
  }

  void _showEducationalDialog(BuildContext context) {
    if (!CalculatorContentRepository.hasContent(
        '/calculators/financial/vacation')) {
      return;
    }

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
                      '/calculators/financial/vacation')!,
                ),
              ),
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
