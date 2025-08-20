// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';

class AproveitamentoInfoDialogWidget extends StatelessWidget {
  const AproveitamentoInfoDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? ShadcnStyle.backgroundColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark
                          ? Colors.amber.shade300
                          : Colors.amber.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sobre o Aproveitamento de Carcaça',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ShadcnStyle.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.amber.withValues(alpha: 0.1)
                        : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.amber.withValues(alpha: 0.3)
                          : Colors.amber.shade100,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'O que é o Aproveitamento de Carcaça?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.amber.shade300
                              : Colors.amber.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'O aproveitamento ou rendimento de carcaça é a relação percentual entre o peso da carcaça e o peso vivo do animal. Este índice é fundamental para avaliar a eficiência da produção de carne.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Cálculo:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Rendimento = (Peso da Carcaça ÷ Peso Vivo) × 100',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Interpretação:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• < 50%: Baixo rendimento',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '• 50-55%: Rendimento médio',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '• 55-60%: Bom rendimento',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '• > 60%: Excelente rendimento',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Fatores que influenciam:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Raça do animal',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                Text(
                  '• Idade e peso ao abate',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                Text(
                  '• Sistema de produção',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                Text(
                  '• Nutrição e manejo',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ShadcnStyle.primaryButtonStyle,
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
