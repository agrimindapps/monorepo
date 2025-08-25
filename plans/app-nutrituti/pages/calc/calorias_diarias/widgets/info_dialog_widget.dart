// Flutter imports:
import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;
    final headingColor = isDark ? Colors.cyan.shade200 : Colors.cyan.shade700;
    final accentColor = isDark ? Colors.amber.shade200 : Colors.amber.shade600;
    final noteTextColor =
        isDark ? Colors.grey.shade300 : const Color(0xFF505050);
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final cardBgColor = isDark ? const Color(0xFF262626) : Colors.white;
    final containerBgColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50;
    final noteBgColor =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA);

    return Dialog(
      backgroundColor: cardBgColor,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(accentColor, textColor, context),
                Divider(color: borderColor, height: 24),
                _buildSection(
                  'Como Funciona',
                  'Esta calculadora estima a quantidade de calorias queimadas durante diferentes tipos de exercícios físicos. O cálculo é baseado no tipo de atividade e no tempo de duração do exercício.',
                  headingColor,
                  textColor,
                  null,
                ),
                const SizedBox(height: 16),
                _buildSection(
                  'Fatores Importantes',
                  'O gasto calórico durante o exercício varia significativamente dependendo de vários fatores, como intensidade do exercício, peso corporal, idade, sexo e nível de condicionamento físico. Esta calculadora fornece uma estimativa baseada em valores médios para cada tipo de atividade.',
                  headingColor,
                  textColor,
                  null,
                ),
                const SizedBox(height: 16),
                _buildFormulaCard(
                  containerBgColor,
                  accentColor,
                  headingColor,
                  textColor,
                ),
                const SizedBox(height: 20),
                _buildSection(
                  'Taxas Médias de Queima Calórica',
                  '',
                  headingColor,
                  textColor,
                  Icons.local_fire_department,
                ),
                const SizedBox(height: 10),
                _buildRateTable(context, borderColor),
                const SizedBox(height: 20),
                _buildSection(
                  'Benefícios de Calcular as Calorias Queimadas',
                  '',
                  headingColor,
                  textColor,
                  Icons.volunteer_activism,
                ),
                const SizedBox(height: 10),
                _buildBenefitsList(textColor, accentColor),
                const SizedBox(height: 20),
                _buildNoteCard(
                  noteBgColor,
                  borderColor,
                  isDark,
                  noteTextColor,
                ),
                const SizedBox(height: 20),
                _buildCloseButton(context, accentColor, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      Color accentColor, Color textColor, BuildContext context) {
    return Row(
      children: [
        Icon(Icons.fitness_center, color: accentColor, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Cálculo de Calorias por Exercício',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: textColor.withValues(alpha: 0.7),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildSection(
    String title,
    String content,
    Color titleColor,
    Color textColor,
    IconData? icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: titleColor, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ],
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: textColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormulaCard(
    Color bgColor,
    Color borderColor,
    Color headingColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, color: headingColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'Fórmula Utilizada',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Calorias Queimadas = Tempo (minutos) × Taxa de Queima Calórica da Atividade',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateTable(BuildContext context, Color borderColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor =
        isDark ? const Color(0xFF333333) : const Color(0xFFE8F0FE);
    final headerTextColor =
        isDark ? Colors.cyan.shade200 : Colors.cyan.shade800;
    final textColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;
    final rowColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final alternateRowColor =
        isDark ? const Color(0xFF242424) : const Color(0xFFF8F9FA);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
        color: isDark ? const Color(0xFF262626) : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeader(headerColor, headerTextColor),
          _buildTableRow(
              'Caminhada leve (3-4 km/h)', '3-4', textColor, rowColor),
          _buildTableRow('Caminhada rápida (5-6 km/h)', '5-7', textColor,
              alternateRowColor),
          _buildTableRow(
              'Corrida moderada (8-10 km/h)', '10-12', textColor, rowColor),
          _buildTableRow('Corrida intensa (12-14 km/h)', '14-16', textColor,
              alternateRowColor),
          _buildTableRow('Ciclismo leve', '5-7', textColor, rowColor),
          _buildTableRow(
              'Ciclismo intenso', '12-14', textColor, alternateRowColor),
          _buildTableRow('Natação moderada', '8-10', textColor, rowColor),
          _buildTableRow('Musculação', '6-8', textColor, alternateRowColor),
        ],
      ),
    );
  }

  Widget _buildTableHeader(Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(7),
          topRight: Radius.circular(7),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Atividade',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Calorias (kcal/min)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    String activity,
    String calories,
    Color textColor,
    Color bgColor,
  ) {
    return ColoredBox(
      color: bgColor,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                activity,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(width: 1, color: Color(0xFF444444)),
                ),
              ),
              child: Text(
                calories,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList(Color textColor, Color bulletColor) {
    final benefits = [
      'Ajuda a planejar melhor sua dieta e equilíbrio calórico',
      'Permite comparar a eficiência de diferentes exercícios',
      'Auxilia no estabelecimento de metas realistas para perda de peso',
      'Motiva a manter a regularidade nos exercícios',
    ];

    return Column(
      children: benefits
          .map((text) => _buildBulletPoint(text, textColor, bulletColor))
          .toList(),
    );
  }

  Widget _buildBulletPoint(String text, Color textColor, Color bulletColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              fontSize: 18,
              color: bulletColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(
    Color bgColor,
    Color borderColor,
    bool isDark,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta calculadora fornece apenas uma estimativa. A queima calórica real pode variar dependendo de fatores individuais como peso, metabolismo, intensidade do exercício e nível de condicionamento físico. Para medições mais precisas, considere monitores de frequência cardíaca ou consulte um profissional.',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(
      BuildContext context, Color accentColor, bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: isDark ? 4 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Fechar',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
