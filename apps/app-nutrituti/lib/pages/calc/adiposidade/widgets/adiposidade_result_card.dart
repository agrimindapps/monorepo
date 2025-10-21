// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../../../../../../core/themes/manager.dart';
import '../model/adiposidade_model.dart';

class AdipososidadeResultCard extends StatelessWidget {
  final AdipososidadeModel model;
  final bool isVisible;
  final Function() onShare;

  const AdipososidadeResultCard({
    super.key,
    required this.model,
    required this.isVisible,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: isVisible,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Resultado do IAC',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ShadcnStyle.textColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Compartilhar'),
                      style: ShadcnStyle.textButtonStyle,
                    ),
                  ],
                ),
                const Divider(thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: isDark
                        ? Colors.purple.withValues(alpha: 0.1)
                        : Colors.purple.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isDark
                            ? Colors.purple.withValues(alpha: 0.3)
                            : Colors.purple.shade100,
                      ),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            size: 40,
                            color:
                                isDark ? Colors.purple.shade300 : Colors.purple,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Índice de Adiposidade Corporal (IAC):',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ShadcnStyle.textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${model.iac}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.purple.shade300
                                        : Colors.purple.shade800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Classificação:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ShadcnStyle.textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  model.classificacao,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ShadcnStyle.textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildComentarioCard(isDark),
                const SizedBox(height: 16),
                _buildTabelasReferencia(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComentarioCard(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.comment,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Comentário',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              model.comentario,
              style: TextStyle(
                fontSize: 14,
                color: ShadcnStyle.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabelasReferencia(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark
              ? Colors.blue.withValues(alpha: 0.3)
              : Colors.blue.shade100,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.table_chart,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tabela de Referência',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ShadcnStyle.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Valores de referência para homens:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                width: 1,
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.grey.shade200,
                  ),
                  children: [
                    _tableCell('Classificação', isHeader: true),
                    _tableCell('Valores de IAC', isHeader: true),
                  ],
                ),
                TableRow(
                  children: [
                    _tableCell('Adiposidade essencial'),
                    _tableCell('< 8%'),
                  ],
                ),
                TableRow(
                  children: [
                    _tableCell('Adiposidade saudável'),
                    _tableCell('8% - 20,9%'),
                  ],
                ),
                TableRow(
                  children: [
                    _tableCell('Sobrepeso'),
                    _tableCell('21% - 25,9%'),
                  ],
                ),
                TableRow(
                  children: [
                    _tableCell('Obesidade'),
                    _tableCell('≥ 26%'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Valores de referência para mulheres:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ShadcnStyle.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                width: 1,
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.grey.shade200,
                  ),
                  children: [
                    _tableCell('Classificação', isHeader: true),
                    _tableCell('Valores de IAC', isHeader: true),
                  ],
                ),
                TableRow(
                  children: [
                    _tableCell('Adiposidade essencial'),
                    _tableCell('< 21%'),
                  ],
                ),
                TableRow(
                  children: [
                    _tableCell('Adiposidade saudável'),
                    _tableCell('21% - 32,9%'),
                  ],
                ),
                TableRow(
                  children: [
                    _tableCell('Sobrepeso'),
                    _tableCell('33% - 38,9%'),
                  ],
                ),
                TableRow(
                  children: [
                    _tableCell('Obesidade'),
                    _tableCell('≥ 39%'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Observação: Estes valores são indicativos e podem variar conforme idade e atividade física. Consulte um profissional de saúde para avaliação individualizada.',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: ShadcnStyle.mutedTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: ShadcnStyle.textColor,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}
