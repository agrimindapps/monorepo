// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class ZNewIndiceAdiposidadeInfoDialog {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Índice de Adiposidade Corporal (IAC)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'O que é IAC?',
                    'O Índice de Adiposidade Corporal (IAC) é uma medida alternativa ao IMC para estimar a porcentagem de gordura corporal. Foi desenvolvido em 2011 para fornecer uma estimativa simples da adiposidade que não requer a medição do peso corporal.',
                    isDark,
                    Icons.help_outline,
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Como é calculado?',
                    'IAC = (Circunferência do quadril em cm / Altura em m^1.5) - 18',
                    isDark,
                    Icons.calculate_outlined,
                    Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Interpretação para homens:',
                    '• Adiposidade essencial: < 8%\n• Adiposidade saudável: 8% - 20,9%\n• Sobrepeso: 21% - 25,9%\n• Obesidade: ≥ 26%',
                    isDark,
                    Icons.male,
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Interpretação para mulheres:',
                    '• Adiposidade essencial: < 21%\n• Adiposidade saudável: 21% - 32,9%\n• Sobrepeso: 33% - 38,9%\n• Obesidade: ≥ 39%',
                    isDark,
                    Icons.female,
                    Colors.pink,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Observação importante:',
                    'O IAC é apenas uma estimativa e deve ser interpretado junto com outros indicadores de saúde. Consulte sempre um profissional de saúde para uma avaliação completa.',
                    isDark,
                    Icons.warning_amber_outlined,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSection(
      String title, String content, bool isDark, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: ShadcnStyle.textColor,
            ),
          ),
        ),
      ],
    );
  }
}
