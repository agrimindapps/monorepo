// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: isDark ? Colors.blue.shade300 : Colors.blue,
          ),
          const SizedBox(width: 10),
          Text(
            'Informações',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection(
              context,
              title: 'Previsão Básica',
              content:
                  'Cálculo simplificado para estimar custos de produção e potencial de receita baseado em dados básicos e preços médios históricos.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Análise de Rentabilidade',
              content:
                  'Análise detalhada que considera custos específicos, investimentos, impostos e outros fatores para calcular a viabilidade econômica do projeto agrícola.',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Observações:',
              content:
                  '• Os resultados são estimativas e podem variar de acordo com condições reais de mercado, clima e manejo.\n'
                  '• Consulte um técnico agrícola ou especialista para análises mais precisas.\n'
                  '• Valores de referência são baseados em médias regionais e histórico de preços.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: ShadcnStyle.primaryButtonStyle,
          child: const Text('Entendi'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ShadcnStyle.textColor,
              ),
        ),
      ],
    );
  }
}
