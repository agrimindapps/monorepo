// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:app_calculei/core/style/shadcn_style.dart';
import 'package:app_calculei/core/themes/manager.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const InfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 650 ? 600.0 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Sobre Juros Compostos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              _buildInfoSection(
                'O que são Juros Compostos?',
                'Juros compostos são o conceito de adicionar juros acumulados de volta ao principal, '
                    'para que os juros também ganhem juros ao longo do tempo. É frequentemente chamado de \'juros sobre juros\'.',
              ),
              const SizedBox(height: 15),
              _buildInfoSection(
                'Como calculamos',
                'A fórmula utilizada é M = P(1+i)^n + PMT[((1+i)^n-1)/i], onde:\n'
                    '- M = Montante final\n'
                    '- P = Capital inicial\n'
                    '- i = Taxa de juros (mensal)\n'
                    '- n = Número de meses\n'
                    '- PMT = Aporte mensal',
              ),
              const SizedBox(height: 15),
              _buildInfoSection(
                'Rendimento Total',
                'O rendimento total é calculado dividindo o total de juros pelo total investido, '
                    'mostrando o ganho percentual em relação ao capital investido.',
              ),
              const SizedBox(height: 15),
              Center(
                child: _buildCuriosityCard(isDark),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ShadcnStyle.primaryButtonStyle,
                  child: const Text('Entendi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          content,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCuriosityCard(bool isDark) {
    return Card(
      elevation: 0,
      color:
          isDark ? Colors.amber.withValues(alpha: 0.2) : Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDark
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.amber.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Você sabia?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color:
                        isDark ? Colors.amber.shade300 : Colors.amber.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Albert Einstein teria chamado os juros compostos de \'a maior invenção matemática da humanidade\' e \'a força mais poderosa do universo\'.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
