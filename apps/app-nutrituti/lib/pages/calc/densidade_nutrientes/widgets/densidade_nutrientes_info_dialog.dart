// Widget: Diálogo de informações sobre densidade de nutrientes

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class DensidadeNutrientesInfoDialog {
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
                          'Sobre a Densidade de Nutrientes',
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
                    'O que é densidade de nutrientes?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A densidade de nutrientes é uma medida que avalia a quantidade de nutrientes em relação às calorias de um alimento. Alimentos com alta densidade de nutrientes fornecem quantidades significativas de vitaminas, minerais, proteínas ou fibras em relação às suas calorias.',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fórmula aplicada:',
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
                      'Densidade de Nutrientes = (Quantidade do nutriente / Calorias do alimento) × 1000',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Valores de referência:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShadcnStyle.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Proteína: <30 (Baixa), 30-50 (Moderada), >50 (Alta) g/1000kcal',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  Text(
                    '• Fibra: <10 (Baixa), 10-14 (Moderada), >14 (Alta) g/1000kcal',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  Text(
                    '• Vitamina A: <300 (Baixa), 300-600 (Moderada), >600 (Alta) μg/1000kcal',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  Text(
                    '• Vitamina C: <30 (Baixa), 30-60 (Moderada), >60 (Alta) mg/1000kcal',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  Text(
                    '• Cálcio: <400 (Baixa), 400-600 (Moderada), >600 (Alta) mg/1000kcal',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  Text(
                    '• Ferro: <4 (Baixa), 4-8 (Moderada), >8 (Alta) mg/1000kcal',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  Text(
                    '• Potássio: <1000 (Baixa), 1000-2000 (Moderada), >2000 (Alta) mg/1000kcal',
                    style: TextStyle(color: ShadcnStyle.textColor),
                  ),
                  Text(
                    '• Magnésio: <120 (Baixa), 120-160 (Moderada), >160 (Alta) mg/1000kcal',
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
        );
      },
    );
  }
}
