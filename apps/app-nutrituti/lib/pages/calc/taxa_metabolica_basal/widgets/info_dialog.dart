// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class InfoDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = ThemeManager().isDark.value;

        return AlertDialog(
          title: const Text(
            'Calculadora de Taxa Metabólica Basal (TMB)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'A Taxa Metabólica Basal (TMB) representa a quantidade mínima de energia necessária para manter as funções vitais do organismo em repouso, como respiração, batimentos cardíacos e temperatura corporal.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'O Gasto Energético Total inclui sua TMB mais a energia gasta em atividades físicas diárias.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Para homens:',
                  style: TextStyle(
                    color: isDark ? Colors.blue.shade300 : Colors.blue,
                  ),
                ),
                Text(
                  'TMB = 13.397 × peso(kg) + 4.799 × altura(cm) - 5.677 × idade(anos) + 88.362',
                  style: TextStyle(fontSize: 14, color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Para mulheres:',
                  style: TextStyle(
                    color: isDark ? Colors.pink.shade300 : Colors.pink,
                  ),
                ),
                Text(
                  'TMB = 9.247 × peso(kg) + 3.098 × altura(cm) - 4.330 × idade(anos) + 447.593',
                  style: TextStyle(fontSize: 14, color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gasto Energético Total = TMB × Fator de Atividade',
                  style: TextStyle(
                    fontSize: 14,
                    color: ShadcnStyle.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fatores de Atividade:',
                  style: TextStyle(
                    color: ShadcnStyle.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '• Sedentário: 1.2',
                  style: TextStyle(fontSize: 14, color: ShadcnStyle.textColor),
                ),
                Text(
                  '• Levemente ativo: 1.375',
                  style: TextStyle(fontSize: 14, color: ShadcnStyle.textColor),
                ),
                Text(
                  '• Moderadamente ativo: 1.55',
                  style: TextStyle(fontSize: 14, color: ShadcnStyle.textColor),
                ),
                Text(
                  '• Muito ativo: 1.725',
                  style: TextStyle(fontSize: 14, color: ShadcnStyle.textColor),
                ),
                Text(
                  '• Extra ativo: 1.9',
                  style: TextStyle(fontSize: 14, color: ShadcnStyle.textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Observação: Estes valores são estimativas e podem variar de acordo com fatores individuais como composição corporal, genética e condições médicas.',
                  style: TextStyle(
                    fontSize: 12,
                    color: ShadcnStyle.mutedTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ShadcnStyle.textButtonStyle,
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
