import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/calculation_result.dart';

/// Widget para exibir resultado principal com destaque
class PrimaryResultWidget extends StatelessWidget {
  final CalculationResultValue result;
  final VoidCallback? onTap;

  const PrimaryResultWidget({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getIconForResult(result),
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () => _copyToClipboard(context),
                    tooltip: 'Copiar valor',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatValue(result.value),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (result.unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      result.unit,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              if (result.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  result.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final text = '${result.label}: ${_formatValue(result.value)} ${result.unit}';
    Clipboard.setData(ClipboardData(text: text));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Valor copiado para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  IconData _getIconForResult(CalculationResultValue result) {
    // Mapear ícones baseado no tipo/contexto do resultado
    final label = result.label.toLowerCase();
    
    if (label.contains('produtividade') || label.contains('yield')) {
      return Icons.trending_up;
    } else if (label.contains('população') || label.contains('densidade')) {
      return Icons.grid_view;
    } else if (label.contains('água') || label.contains('irrigação')) {
      return Icons.water_drop;
    } else if (label.contains('fertilizante') || label.contains('nutriente')) {
      return Icons.eco;
    } else if (label.contains('custo') || label.contains('preço')) {
      return Icons.attach_money;
    } else if (label.contains('tempo') || label.contains('data')) {
      return Icons.schedule;
    } else if (label.contains('área')) {
      return Icons.crop_landscape;
    } else if (label.contains('peso') || label.contains('massa')) {
      return Icons.scale;
    } else if (label.contains('energia')) {
      return Icons.bolt;
    } else if (label.contains('eficiência')) {
      return Icons.speed;
    }
    
    return Icons.analytics;
  }

  String _formatValue(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else if (value < 0.01) {
      return value.toStringAsExponential(2);
    } else if (value < 1) {
      return value.toStringAsFixed(3);
    } else if (value < 100) {
      return value.toStringAsFixed(2);
    } else if (value < 10000) {
      return value.toStringAsFixed(1);
    } else {
      return value.toInt().toString();
    }
  }
}

/// Widget para exibir resultado secundário em lista
class SecondaryResultWidget extends StatelessWidget {
  final CalculationResultValue result;
  final VoidCallback? onTap;

  const SecondaryResultWidget({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          _getIconForResult(result),
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        result.label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: result.description.isNotEmpty 
          ? Text(result.description)
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatValue(result.value),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (result.unit.isNotEmpty)
            Text(
              result.unit,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  IconData _getIconForResult(CalculationResultValue result) {
    // Mesmo método da classe anterior
    final label = result.label.toLowerCase();
    
    if (label.contains('produtividade') || label.contains('yield')) {
      return Icons.trending_up;
    } else if (label.contains('população') || label.contains('densidade')) {
      return Icons.grid_view;
    } else if (label.contains('água') || label.contains('irrigação')) {
      return Icons.water_drop;
    } else if (label.contains('fertilizante') || label.contains('nutriente')) {
      return Icons.eco;
    } else if (label.contains('custo') || label.contains('preço')) {
      return Icons.attach_money;
    } else if (label.contains('tempo') || label.contains('data')) {
      return Icons.schedule;
    } else if (label.contains('área')) {
      return Icons.crop_landscape;
    } else if (label.contains('peso') || label.contains('massa')) {
      return Icons.scale;
    } else if (label.contains('energia')) {
      return Icons.bolt;
    } else if (label.contains('eficiência')) {
      return Icons.speed;
    }
    
    return Icons.analytics;
  }

  String _formatValue(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else if (value < 0.01) {
      return value.toStringAsExponential(2);
    } else if (value < 1) {
      return value.toStringAsFixed(3);
    } else if (value < 100) {
      return value.toStringAsFixed(2);
    } else if (value < 10000) {
      return value.toStringAsFixed(1);
    } else {
      return value.toInt().toString();
    }
  }
}

/// Widget para exibir tabela de dados
class DataTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const DataTableWidget({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final headers = data.first.keys.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                headingRowHeight: 40,
                dataRowHeight: 36,
                columns: headers.map((header) {
                  return DataColumn(
                    label: Text(
                      _formatHeaderText(header),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                rows: data.map((row) {
                  return DataRow(
                    cells: headers.map((header) {
                      final value = row[header];
                      return DataCell(
                        Text(
                          _formatCellValue(value),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHeaderText(String header) {
    // Converte snake_case para Title Case
    return header
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatCellValue(dynamic value) {
    if (value == null) return '-';
    if (value is double) {
      if (value == value.toInt()) {
        return value.toInt().toString();
      } else {
        return value.toStringAsFixed(2);
      }
    }
    return value.toString();
  }
}

/// Widget para exibir indicadores de qualidade/status
class QualityIndicatorWidget extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final String unit;
  final Color? color;

  const QualityIndicatorWidget({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    this.unit = '',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final indicatorColor = color ?? _getColorForPercentage(context, percentage);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(1)}$unit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: indicatorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${maxValue.toStringAsFixed(0)}$unit',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForPercentage(BuildContext context, double percentage) {
    if (percentage >= 0.8) {
      return Colors.green;
    } else if (percentage >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

/// Widget para exibir recomendações com ícones
class RecommendationsWidget extends StatelessWidget {
  final List<String> recommendations;
  final String title;

  const RecommendationsWidget({
    super.key,
    required this.recommendations,
    this.title = 'Recomendações',
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;
              final icon = _getRecommendationIcon(recommendation);
              
              return Padding(
                padding: EdgeInsets.only(bottom: index < recommendations.length - 1 ? 8 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  IconData _getRecommendationIcon(String recommendation) {
    final text = recommendation.toLowerCase();
    
    if (text.contains('cuidado') || text.contains('atenção')) {
      return Icons.warning_outlined;
    } else if (text.contains('melhorar') || text.contains('aumentar')) {
      return Icons.trending_up;
    } else if (text.contains('reduzir') || text.contains('diminuir')) {
      return Icons.trending_down;
    } else if (text.contains('monitorar') || text.contains('acompanhar')) {
      return Icons.visibility_outlined;
    } else if (text.contains('aplicar') || text.contains('utilizar')) {
      return Icons.agriculture;
    } else if (text.contains('evitar') || text.contains('não')) {
      return Icons.do_not_disturb_on_outlined;
    }
    
    return Icons.arrow_forward_ios;
  }
}