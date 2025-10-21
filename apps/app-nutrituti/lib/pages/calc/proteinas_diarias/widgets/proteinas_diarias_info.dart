// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class ProteinasDiariasInfo {
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
                      Expanded(
                        child: Text(
                          'Cálculo de Proteínas Diárias',
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
                    'Esta calculadora estima a quantidade diária recomendada de proteínas com base no seu peso e nível de atividade física.',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recomendações por nível de atividade:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Sedentário: 0.8g/kg de peso corporal\n'
                    '• Levemente ativo: 1.0g/kg de peso corporal\n'
                    '• Moderadamente ativo: 1.2g/kg de peso corporal\n'
                    '• Muito ativo: 1.6g/kg de peso corporal\n'
                    '• Extremamente ativo: 2.0g/kg de peso corporal',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Observações importantes:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.amber.shade300
                          : Colors.amber.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Estas são recomendações gerais\n'
                    '• Fatores individuais podem afetar suas necessidades\n'
                    '• Atletas podem precisar de quantidades maiores\n'
                    '• Consulte um profissional de saúde para recomendações específicas',
                    style: TextStyle(
                      color: isDark
                          ? Colors.amber.shade300
                          : Colors.amber.shade900,
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
