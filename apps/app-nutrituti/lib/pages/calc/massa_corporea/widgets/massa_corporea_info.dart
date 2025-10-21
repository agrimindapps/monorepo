// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class MassaCorporeaInfoDialog extends StatelessWidget {
  const MassaCorporeaInfoDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const MassaCorporeaInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    final dialogPadding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
        : const EdgeInsets.all(20);

    final sectionSpacing = isMobile ? 16.0 : 20.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : 40.0,
        vertical: isMobile ? 24.0 : 40.0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: screenSize.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: dialogPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isDark),
                SizedBox(height: sectionSpacing),
                _buildSection(
                  'O que é IMC?',
                  'O Índice de Massa Corporal (IMC) é uma medida internacional usada para calcular se uma pessoa está no peso ideal.',
                  isDark,
                ),
                SizedBox(height: sectionSpacing),
                _buildSection(
                  'Como é calculado?',
                  'O IMC é calculado dividindo o peso (em kg) pela altura ao quadrado (em metros). Por exemplo, uma pessoa com 70kg e 1,75m tem IMC = 70 / (1,75²) = 22,9.',
                  isDark,
                ),
                SizedBox(height: sectionSpacing),
                _buildSection(
                  'Classificação do IMC',
                  '',
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildIMCTable(isDark),
                SizedBox(height: sectionSpacing),
                _buildSection(
                  'Importante',
                  'O IMC é apenas uma referência e não leva em conta a composição corporal. Consulte sempre um profissional de saúde para uma avaliação completa.',
                  isDark,
                  isImportant: true,
                ),
                const SizedBox(height: 24),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: isDark ? Colors.blue.shade300 : Colors.blue,
          size: 24,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Índice de Massa Corporal (IMC)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content, bool isDark,
      {bool isImportant = false}) {
    if (content.isEmpty) {
      return Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isImportant
              ? (isDark ? Colors.amber.shade300 : Colors.amber.shade700)
              : null,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isImportant
                ? (isDark ? Colors.amber.shade300 : Colors.amber.shade700)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: isImportant
                ? (isDark ? Colors.amber.shade100 : Colors.amber.shade900)
                : null,
            fontStyle: isImportant ? FontStyle.italic : null,
          ),
        ),
      ],
    );
  }

  Widget _buildIMCTable(bool isDark) {
    final headerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Table(
      border: TableBorder.all(color: borderColor, width: 1),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          decoration: BoxDecoration(color: headerColor),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('IMC', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Classificação',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child:
                  Text('Risco', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        _buildTableRow('< 18,5', 'Abaixo do peso',
            'Baixo (com risco para outros problemas)'),
        _buildTableRow('18,5 - 24,9', 'Peso normal', 'Médio'),
        _buildTableRow('25,0 - 29,9', 'Sobrepeso', 'Aumentado'),
        _buildTableRow('30,0 - 34,9', 'Obesidade I', 'Moderado'),
        _buildTableRow('35,0 - 39,9', 'Obesidade II', 'Grave'),
        _buildTableRow('≥ 40,0', 'Obesidade III', 'Muito grave'),
      ],
    );
  }

  TableRow _buildTableRow(String col1, String col2, String col3) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(col1, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(col2),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(col3),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ShadcnStyle.primaryButtonStyle,
        child: const Text('Entendi'),
      ),
    );
  }
}
