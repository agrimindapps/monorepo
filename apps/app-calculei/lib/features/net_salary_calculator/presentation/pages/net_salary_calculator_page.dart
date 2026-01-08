import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
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

    return CalculatorPageLayout(
      title: 'Calculadora de Salário Líquido',
      subtitle: 'Descontos e Valor Líquido',
      icon: Icons.account_balance_wallet_outlined,
      accentColor: CalculatorAccentColors.labor,
      categoryName: 'Trabalhista',
      instructions: 'Calcule seu salário líquido após descontos obrigatórios e voluntários. '
          'Informe salário bruto, dependentes e descontos aplicáveis. '
          'Inclui cálculo de INSS e IRRF conforme tabelas 2024.',
      maxContentWidth: 700,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Form
            NetSalaryInputForm(
              formKey: _formKey,
              onCalculate: _handleCalculate,
            ),

            const SizedBox(height: 24),

            // Calculate Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: state.isLoading ? null : _handleSubmit,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.calculate_rounded),
                label: Text(
                  state.isLoading ? 'Calculando...' : 'Calcular Salário Líquido',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CalculatorAccentColors.labor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  disabledBackgroundColor:
                      CalculatorAccentColors.labor.withValues(alpha: 0.5),
                ),
              ),
            ),

            // Error Message
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
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

            // Result Card or Empty State
            const SizedBox(height: 32),
            if (state.calculation != null)
              NetSalaryResultCard(calculation: state.calculation!)
            else
              _buildEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calculate_outlined,
            size: 64,
            color: CalculatorAccentColors.labor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'O resultado aparecerá aqui',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preencha os dados acima e clique em calcular.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
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
}
