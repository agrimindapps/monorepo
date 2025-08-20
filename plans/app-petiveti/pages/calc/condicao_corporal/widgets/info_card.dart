// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    'Sobre a Condição Corporal',
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
            _buildSection(
              'O que é a Condição Corporal:',
              'O Índice de Condição Corporal (ECC) é uma ferramenta utilizada para avaliar se o animal está no peso adequado. A escala vai de 1 a 9, onde 1 representa extrema magreza, 5 representa o peso ideal, e 9 representa obesidade mórbida.',
              isDark,
              Icons.pets_outlined,
              Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Como avaliar:',
              'Para avaliar corretamente seu animal, observe-o de cima e de lado, e palpe as costelas, coluna e ossos pélvicos conforme descrito em cada categoria. A avaliação deve ser feita com o animal em pé e relaxado.',
              isDark,
              Icons.touch_app_outlined,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Importância:',
              'Manter o peso ideal é fundamental para a saúde do seu animal, prevenindo problemas articulares, cardíacos, diabetes e outras complicações relacionadas ao sobrepeso ou desnutrição.',
              isDark,
              Icons.favorite_outline,
              Colors.red,
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Observação:',
              'Esta avaliação é apenas indicativa. Sempre consulte um veterinário para uma avaliação completa e orientações específicas para seu animal.',
              isDark,
              Icons.warning_amber_outlined,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, String content, bool isDark, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? color.withValues(alpha: 0.8) : color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ShadcnStyle.textColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: ShadcnStyle.textColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
