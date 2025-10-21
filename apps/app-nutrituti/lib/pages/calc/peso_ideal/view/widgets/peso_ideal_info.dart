// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';

class PesoIdealInfoDialog {
  static void show(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isDark ? Colors.blue.shade300 : Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Informações sobre o Peso Ideal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ShadcnStyle.textColor,
                        ),
                      ),
                    ],
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
                    'Esta calculadora estima o peso ideal com base na altura e no gênero da pessoa, utilizando uma fórmula específica para homens e mulheres.',
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
                      'Homens: Peso Ideal = 35.15 + ((altura - 130) × 0.75)\nMulheres: Peso Ideal = 33.875 + ((altura - 130) × 0.675)',
                      style: TextStyle(
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Observações importantes:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.amber.shade300
                          : Colors.amber.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• A altura deve ser informada em centímetros (cm)\n• Esta é apenas uma estimativa baseada em médias populacionais\n• Fatores como estrutura óssea, composição corporal e condições médicas podem influenciar o peso ideal\n• Consulte um profissional de saúde para uma avaliação individual completa',
                    style: TextStyle(
                      color: isDark
                          ? Colors.amber.shade300
                          : Colors.amber.shade800,
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
        );
      },
    );
  }
}
