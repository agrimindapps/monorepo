import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
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
  Key _formKeyId = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emergencyReserveCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Reserva de Emergência',
      subtitle: 'Planeje sua segurança financeira',
      icon: Icons.savings_outlined,
      accentColor: CalculatorAccentColors.financial,
      categoryName: 'Financeiro',
      instructions: 'Informe suas despesas mensais e perfil para calcular o valor '
          'ideal de reserva de emergência. Recomenda-se de 3 a 12 meses de despesas, '
          'dependendo da estabilidade de sua renda.',
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
            EmergencyReserveInputForm(
              key: _formKeyId,
              formKey: _formKey,
              onCalculate: _handleCalculate,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DarkTextButton(
                  onPressed: _handleClear,
                  icon: Icons.clear,
                  label: 'Limpar',
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading ? null : _handleSubmit,
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.calculate_rounded),
                    label: Text(
                      state.isLoading ? 'Calculando...' : 'Calcular',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CalculatorAccentColors.financial,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                  ),
                ),
              ],
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
                child: EmergencyReserveResultCard(
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
      _formKey.currentState!.save();
    }
  }

  void _handleCalculate(CalculateEmergencyReserveParams params) {
    ref.read(emergencyReserveCalculatorProvider.notifier).calculate(params);
  }

  void _handleClear() {
    setState(() {
      _formKeyId = UniqueKey();
    });
    ref.read(emergencyReserveCalculatorProvider.notifier).clearCalculation();
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

/// Dark themed text button for the calculator
class _DarkTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _DarkTextButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
