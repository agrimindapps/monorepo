// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../../core/themes/manager.dart';

class GorduraCorporeaInfoDialog {
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
                      const Expanded(
                        child: Text(
                          'Sobre a Calculadora de Gordura Corporal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'O que é gordura corporal?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gordura corporal é o tecido adiposo encontrado no corpo humano. Certa quantidade de gordura é essencial para as funções corporais, incluindo isolamento, proteção de órgãos e armazenamento de energia.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Como calculamos:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esta calculadora utiliza a fórmula de Durnin-Womersley ou a fórmula de Jackson-Pollock para estimar a porcentagem de gordura corporal com base em medições de dobras cutâneas. Estes métodos são amplamente utilizados na avaliação da composição corporal.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Classificação de gordura corporal para homens:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildClassificationTable(true, isDark),
                  const SizedBox(height: 16),
                  const Text(
                    'Classificação de gordura corporal para mulheres:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildClassificationTable(false, isDark),
                  const SizedBox(height: 16),
                  const Text(
                    'Observações importantes:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Este é um método de estimativa e não fornece resultados tão precisos quanto métodos laboratoriais.\n'
                    '• A medição das dobras cutâneas deve ser realizada por um profissional qualificado para maior precisão.\n'
                    '• Os valores de referência podem variar conforme idade, etnia e nível de atividade física.\n'
                    '• Para uma avaliação completa da composição corporal, busque orientação profissional.',
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

  static Widget _buildClassificationTable(bool isMan, bool isDark) {
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final headerBgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Table(
      border: TableBorder.all(
        color: borderColor,
        width: 1,
      ),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: headerBgColor,
          ),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Classificação',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Percentual',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        if (isMan) ...[
          _buildTableRow('Essencial', '2-5%'),
          _buildTableRow('Atleta', '6-13%'),
          _buildTableRow('Fitness', '14-17%'),
          _buildTableRow('Médio', '18-24%'),
          _buildTableRow('Obeso', '>25%'),
        ] else ...[
          _buildTableRow('Essencial', '10-13%'),
          _buildTableRow('Atleta', '14-20%'),
          _buildTableRow('Fitness', '21-24%'),
          _buildTableRow('Médio', '25-31%'),
          _buildTableRow('Obeso', '>32%'),
        ],
      ],
    );
  }

  static TableRow _buildTableRow(String classification, String percentage) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(classification),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            percentage,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
