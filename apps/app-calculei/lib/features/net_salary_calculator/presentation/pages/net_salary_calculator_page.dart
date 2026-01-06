// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Project imports:
import 'package:app_calculei/core/presentation/widgets/calculator_layout.dart';
import 'package:app_calculei/core/style/shadcn_style.dart';

import '../../../../core/data/calculator_content_repository.dart';
import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/educational_tabs.dart';
import '../../domain/usecases/calculate_net_salary_usecase.dart';
import '../providers/net_salary_calculator_provider.dart';
import '../widgets/net_salary_input_form.dart';
import '../widgets/net_salary_result_card.dart';

/// Page for calculating net salary (Salário Líquido)
class NetSalaryCalculatorPage extends ConsumerStatefulWidget {
  const NetSalaryCalculatorPage({super.key});

  @override
  ConsumerState<NetSalaryCalculatorPage> createState() =>
      _NetSalaryCalculatorPageState();
}

class _NetSalaryCalculatorPageState
    extends ConsumerState<NetSalaryCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(netSalaryCalculatorProvider);

    return CalculatorLayout(
      pageTitle: 'Calculadora de Salário Líquido',
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showInfo(context),
        ),
      ],
      inputForm: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dados do Cálculo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Input Form
              NetSalaryInputForm(
                formKey: _formKey,
                onCalculate: _handleCalculate,
              ),

              const SizedBox(height: 24),

              // Calculator Button
              CalculatorButton(
                label: 'Calcular salário líquido',
                icon: Icons.calculate,
                onPressed: _handleSubmit,
                isLoading: state.isLoading,
              ),

              // Error Message
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade100),
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
            ],
          ),
        ),
      ),
      resultCard: state.calculation != null
          ? NetSalaryResultCard(calculation: state.calculation!)
          : _buildEmptyState(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calculate_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'O resultado aparecerá aqui',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preencha os dados ao lado e clique em calcular.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }

  void _handleCalculate(CalculateNetSalaryParams params) {
    ref.read(netSalaryCalculatorProvider.notifier).calculate(params);
  }

  void _showInfo(BuildContext context) {
    // Check if educational content exists
    if (CalculatorContentRepository.hasContent(
        '/calculators/financial/net-salary')) {
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
                      '/calculators/financial/net-salary')!,
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
        title: const Text('Sobre o Salário Líquido'),
        content: const SingleChildScrollView(
          child: Text(
            'O salário líquido é o valor que você efetivamente recebe após os descontos obrigatórios e voluntários.\n\n'
            'Descontos obrigatórios:\n'
            '• INSS: Calculado progressivamente até 14% sobre o salário bruto\n'
            '• IRRF: Imposto de Renda Retido na Fonte, calculado após INSS\n\n'
            'Descontos voluntários:\n'
            '• Vale Transporte: Máximo 6% do salário bruto\n'
            '• Plano de Saúde: Valor definido pela empresa\n'
            '• Outros descontos: Empréstimos, adiantamentos, etc.\n\n'
            'Dependentes reduzem a base de cálculo do IRRF em R\$ 189,59 cada.\n\n'
            'Este cálculo é baseado nas tabelas de 2024 do governo federal.',
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
