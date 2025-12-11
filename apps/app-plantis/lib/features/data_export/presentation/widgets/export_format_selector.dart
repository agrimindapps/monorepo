import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../domain/entities/export_request.dart';

/// Widget for selecting export format in Plantis
class ExportFormatSelector extends StatefulWidget {
  final ExportFormat selectedFormat;
  final void Function(ExportFormat) onFormatChanged;

  const ExportFormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
  });

  @override
  State<ExportFormatSelector> createState() => _ExportFormatSelectorState();
}

class _ExportFormatSelectorState extends State<ExportFormatSelector> {
  IconData _getFormatIcon(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return Icons.code;
      case ExportFormat.csv:
        return Icons.table_chart;
      case ExportFormat.xml:
        return Icons.description;
      case ExportFormat.pdf:
        return Icons.picture_as_pdf;
    }
  }

  String _getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'Estruturado e legível por máquinas. Ideal para desenvolvedores.';
      case ExportFormat.csv:
        return 'Compatível com planilhas. Fácil de abrir no Excel ou Google Sheets.';
      case ExportFormat.xml:
        return 'Formato estruturado padrão. Boa compatibilidade com sistemas.';
      case ExportFormat.pdf:
        return 'Documento formatado para leitura. Ideal para impressão.';
    }
  }

  Color _getFormatColor(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return Colors.blue;
      case ExportFormat.csv:
        return Colors.green;
      case ExportFormat.xml:
        return Colors.orange;
      case ExportFormat.pdf:
        return Colors.red;
    }
  }

  String _getFormatTag(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'TÉCNICO';
      case ExportFormat.csv:
        return 'PLANILHA';
      case ExportFormat.xml:
        return 'ESTRUTURADO';
      case ExportFormat.pdf:
        return 'DOCUMENTO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Formato de Exportação',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha o formato que melhor atende às suas necessidades',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: ExportFormat.values.map((format) {
            final isSelected = widget.selectedFormat == format;
            final color = _getFormatColor(format);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onFormatChanged(format),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withAlpha(30)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? color.withAlpha(100)
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withAlpha(100),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withAlpha(50)
                                : color.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getFormatIcon(format),
                            color: color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    format.displayName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(30),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _getFormatTag(format),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _getFormatDescription(format),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected ? color : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? color : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PlantisColors.primary.withAlpha(20),
                PlantisColors.leaf.withAlpha(20),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PlantisColors.primary.withAlpha(60)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: PlantisColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recomendação',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: PlantisColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.selectedFormat == ExportFormat.json
                          ? 'JSON é ideal para backup completo dos dados'
                          : widget.selectedFormat == ExportFormat.csv
                          ? 'CSV é perfeito para análise em planilhas'
                          : widget.selectedFormat == ExportFormat.pdf
                          ? 'PDF é ótimo para relatórios legíveis'
                          : 'XML oferece boa compatibilidade entre sistemas',
                      style: TextStyle(
                        fontSize: 13,
                        color: PlantisColors.primary.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
