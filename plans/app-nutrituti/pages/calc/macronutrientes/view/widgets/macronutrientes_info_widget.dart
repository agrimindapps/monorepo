// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';

class MacronutrientesInfoWidget extends StatelessWidget {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const MacronutrientesInfoWidget();
      },
    );
  }

  const MacronutrientesInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Informações sobre Macronutrientes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  'O que são macronutrientes?',
                  'Macronutrientes são os componentes da dieta necessários em grandes quantidades para fornecer energia e dar suporte ao crescimento e manutenção do corpo. Os três principais macronutrientes são:',
                  isDark,
                  Icons.category_outlined,
                  Colors.green,
                ),
                _buildBulletPoints(isDark, [
                  'Carboidratos: Principal fonte de energia do corpo (4 kcal/g)',
                  'Proteínas: Essenciais para construção e reparo muscular (4 kcal/g)',
                  'Gorduras: Importantes para absorção de vitaminas e produção hormonal (9 kcal/g)',
                ]),
                const SizedBox(height: 20),
                _buildSection(
                  'Como usar a calculadora',
                  'Para calcular sua distribuição de macronutrientes:',
                  isDark,
                  Icons.calculate_outlined,
                  Colors.blue,
                ),
                _buildBulletPoints(isDark, [
                  '1. Insira suas calorias diárias totais',
                  '2. Escolha uma distribuição predefinida ou personalize as porcentagens',
                  '3. Clique em calcular para ver os resultados em gramas e calorias',
                ]),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
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
              size: 20,
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
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            content,
            style: TextStyle(
              color: ShadcnStyle.textColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoints(bool isDark, List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: points
            .map((text) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: 14,
                          color: ShadcnStyle.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 14,
                            color: ShadcnStyle.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
