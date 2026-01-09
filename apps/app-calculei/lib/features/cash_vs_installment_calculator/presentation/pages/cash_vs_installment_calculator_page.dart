import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
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
  Key _formKeyId = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashVsInstallmentCalculatorProvider);

    return CalculatorPageLayout(
      title: 'À Vista ou Parcelado?',
      subtitle: 'Compare as opções de pagamento',
      icon: Icons.compare_arrows_outlined,
      accentColor: CalculatorAccentColors.financial,
      categoryName: 'Financeiro',
      instructions: 'Informe o preço à vista, valor parcelado e taxa de juros '
          'para descobrir qual é a melhor opção financeira. A calculadora '
          'considera o valor do dinheiro no tempo.',
      maxContentWidth: 800,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white70),
          onPressed: () => _showInfo(context),
          tooltip: 'Informações',
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Form
            CashVsInstallmentInputForm(
              key: _formKeyId,
              formKey: _formKey,
              onCalculate: _handleCalculate,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            CalculatorActionButtons(
              onCalculate: _handleSubmit,
              onClear: _handleClear,
              accentColor: CalculatorAccentColors.financial,
              isLoading: state.isLoading,
            ),

            // Error Message
            if (state.errorMessage != null) ...[
              const SizedBox(height: 20),
              _DarkErrorCard(message: state.errorMessage!),
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
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // The form's onSaved callbacks will trigger _submitForm()
      // which calls the onCalculate callback from the form widget
      _formKey.currentState!.save();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleCalculate(CalculateCashVsInstallmentParams params) {
    // Execute the calculation through the notifier
    ref.read(cashVsInstallmentCalculatorProvider.notifier).calculate(params);
  }

  void _handleClear() {
    setState(() {
      _formKeyId = UniqueKey();
    });
    ref.read(cashVsInstallmentCalculatorProvider.notifier).clearCalculation();
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

/// Dark themed error card
class _DarkErrorCard extends StatelessWidget {
  final String message;

  const _DarkErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade300,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
