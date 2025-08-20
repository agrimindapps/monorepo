// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';

class InfoDialogWidget extends StatelessWidget {
  final bool isDark;

  const InfoDialogWidget({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
                          ? Colors.green.shade300
                          : Colors.green.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sobre o Cálculo de Semeadura',
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
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.green.shade100,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'O que é o Cálculo de Semeadura?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.green.shade300
                              : Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Este cálculo ajuda a determinar a quantidade de sementes necessárias para o plantio, '
                        'considerando a área a ser plantada, o espaçamento entre linhas e plantas, o poder '
                        'germinativo das sementes e o peso de mil sementes.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'O resultado apresentará a quantidade de sementes por metro quadrado, '
                        'por hectare e o total, assim como o peso equivalente em quilogramas.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Como funciona o cálculo:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Sementes por m²: Calculado com base no espaçamento entre linhas e plantas.',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '2. Sementes por hectare: Considera a quantidade por m² e o poder de germinação.',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '3. Peso em kg: Calculado a partir do peso de mil sementes informado.',
                  style: TextStyle(color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Fórmulas aplicadas:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    'Sementes/m² = 10000 ÷ (Espaçamento linhas × Espaçamento plantas)\n'
                    'Sementes/ha = Sementes/m² × 10000 × (100 ÷ Poder germinação)\n'
                    'Sementes total = Sementes/ha × Área plantada\n'
                    'Kg sementes/ha = (Sementes/ha × Peso mil sementes) ÷ 1000000\n'
                    'Kg sementes total = Kg sementes/ha × Área plantada',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: ShadcnStyle.textColor,
                    ),
                  ),
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
