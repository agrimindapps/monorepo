// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';

class InfoDialog {
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
            constraints: const BoxConstraints(maxWidth: 600),
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
                          'Sobre o Custo Real do Crédito',
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
                    'Como funciona?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esta calculadora ajuda você a decidir entre pagar à vista ou parcelar uma compra, considerando o rendimento que você poderia ter ao investir o dinheiro.',
                    style: TextStyle(
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'O que é considerado no cálculo?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• O valor total que você pagará no parcelamento\n'
                    '• O rendimento que você teria se investisse o valor à vista\n'
                    '• A diferença real entre as duas opções',
                    style: TextStyle(
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Como usar?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Digite o valor à vista do produto\n'
                    '2. Digite o valor da parcela\n'
                    '3. Informe o número de parcelas\n'
                    '4. Digite a taxa de rendimento mensal que você conseguiria ao investir',
                    style: TextStyle(
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.amber.shade900.withValues(alpha: 0.2)
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? Colors.amber.shade700.withValues(alpha: 0.3)
                            : Colors.amber.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: isDark
                              ? Colors.amber.shade300
                              : Colors.amber.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Use essa informação para tomar a melhor decisão financeira, considerando seu planejamento e objetivos.',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.amber.shade100
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ShadcnStyle.textButtonStyle,
                      child: const Text('Entendi'),
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
