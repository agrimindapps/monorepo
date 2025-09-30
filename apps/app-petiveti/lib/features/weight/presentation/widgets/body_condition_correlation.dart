import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../providers/weights_provider.dart';

/// Body condition correlation display for weight analysis
class BodyConditionCorrelation extends ConsumerStatefulWidget {
  final String? animalId;
  final bool showInteractiveMode;

  const BodyConditionCorrelation({
    super.key,
    this.animalId,
    this.showInteractiveMode = true,
  });

  @override
  ConsumerState<BodyConditionCorrelation> createState() => _BodyConditionCorrelationState();
}

class _BodyConditionCorrelationState extends ConsumerState<BodyConditionCorrelation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'last3months';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weightsState = ref.watch(weightsProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.show_chart), text: 'Correlação'),
              Tab(icon: Icon(Icons.analytics), text: 'Análise'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCorrelationView(theme, weightsState),
                _buildAnalysisView(theme, weightsState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Correlação Peso vs Condição Corporal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Análise da relação entre peso e escore corporal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.showInteractiveMode)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip('1month', '1 Mês'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('last3months', '3 Meses'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('last6months', '6 Meses'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('lastyear', '1 Ano'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String value, String label) {
    final isSelected = _selectedPeriod == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPeriod = value);
        }
      },
    );
  }

  Widget _buildCorrelationView(ThemeData theme, WeightsState weightsState) {
    final mockData = _generateMockCorrelationData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gráfico de Dispersão',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Correlation chart placeholder
          Container(
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: CorrelationChartPainter(
                data: mockData,
                theme: theme,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Correlation metrics
          _buildCorrelationMetrics(theme, mockData),
        ],
      ),
    );
  }

  Widget _buildAnalysisView(ThemeData theme, WeightsState weightsState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalysisCard(
            theme,
            'Tendência Geral',
            'Forte correlação positiva (r=0.85) entre peso e escore corporal',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildAnalysisCard(
            theme,
            'Peso Ideal Estimado',
            'Baseado no BCS 5/9: 22-25 kg para este animal',
            Icons.balance,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildAnalysisCard(
            theme,
            'Recomendação',
            'Manter peso atual, monitorar BCS semanalmente',
            Icons.medical_services,
            Colors.orange,
          ),
          const SizedBox(height: 20),
          
          _buildBcsWeightTable(theme),
        ],
      ),
    );
  }

  Widget _buildCorrelationMetrics(ThemeData theme, List<Map<String, double>> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(theme, 'Correlação', '0.85', 'Forte', Colors.green),
              ),
              Expanded(
                child: _buildMetricItem(theme, 'R²', '0.72', 'Boa', Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(theme, 'Tendência', '+0.8 kg/BCS', 'Positiva', Colors.orange),
              ),
              Expanded(
                child: _buildMetricItem(theme, 'Precisão', '±1.2 kg', 'Alta', Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(ThemeData theme, String label, String value, String description, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(ThemeData theme, String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBcsWeightTable(ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(Icons.table_chart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Tabela BCS vs Peso',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildTableHeader(theme),
          ..._getBcsWeightData().map((row) => _buildTableRow(theme, row)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'BCS',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Peso Estimado',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Status',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(ThemeData theme, Map<String, dynamic> row) {
    final statusColor = _getStatusColor(row['status'] as String);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row['bcs'] as String,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row['weight'] as String,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                row['status'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mock data and helpers
  List<Map<String, double>> _generateMockCorrelationData() {
    return [
      {'weight': 18.5, 'bcs': 3.0},
      {'weight': 21.2, 'bcs': 4.0},
      {'weight': 23.8, 'bcs': 5.0},
      {'weight': 26.5, 'bcs': 6.0},
      {'weight': 29.1, 'bcs': 7.0},
      {'weight': 31.8, 'bcs': 8.0},
      {'weight': 34.2, 'bcs': 9.0},
    ];
  }

  List<Map<String, dynamic>> _getBcsWeightData() {
    return [
      {'bcs': '1-2', 'weight': '< 20 kg', 'status': 'Muito Magro'},
      {'bcs': '3', 'weight': '20-22 kg', 'status': 'Magro'},
      {'bcs': '4-5', 'weight': '22-26 kg', 'status': 'Ideal'},
      {'bcs': '6-7', 'weight': '26-30 kg', 'status': 'Acima do Peso'},
      {'bcs': '8-9', 'weight': '> 30 kg', 'status': 'Obeso'},
    ];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Muito Magro':
        return Colors.red;
      case 'Magro':
        return Colors.orange;
      case 'Ideal':
        return Colors.green;
      case 'Acima do Peso':
        return Colors.orange;
      case 'Obeso':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Custom painter for correlation chart
class CorrelationChartPainter extends CustomPainter {
  final List<Map<String, double>> data;
  final ThemeData theme;

  CorrelationChartPainter({
    required this.data,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Chart bounds
    const padding = 40.0;
    final chartRect = Rect.fromLTWH(
      padding,
      padding,
      size.width - padding * 2,
      size.height - padding * 2,
    );

    // Find min/max values
    final weights = data.map((d) => d['weight']!).toList();
    final bcsValues = data.map((d) => d['bcs']!).toList();
    
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final minBcs = bcsValues.reduce((a, b) => a < b ? a : b);
    final maxBcs = bcsValues.reduce((a, b) => a > b ? a : b);

    // Draw data points
    for (final point in data) {
      final x = chartRect.left + 
          ((point['weight']! - minWeight) / (maxWeight - minWeight)) * chartRect.width;
      final y = chartRect.bottom - 
          ((point['bcs']! - minBcs) / (maxBcs - minBcs)) * chartRect.height;
      
      canvas.drawCircle(Offset(x, y), 4, paint);
    }

    // Draw trend line (simplified)
    if (data.length > 1) {
      final firstPoint = data.first;
      final lastPoint = data.last;
      
      final startX = chartRect.left + 
          ((firstPoint['weight']! - minWeight) / (maxWeight - minWeight)) * chartRect.width;
      final startY = chartRect.bottom - 
          ((firstPoint['bcs']! - minBcs) / (maxBcs - minBcs)) * chartRect.height;
      
      final endX = chartRect.left + 
          ((lastPoint['weight']! - minWeight) / (maxWeight - minWeight)) * chartRect.width;
      final endY = chartRect.bottom - 
          ((lastPoint['bcs']! - minBcs) / (maxBcs - minBcs)) * chartRect.height;
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;

    // X axis
    canvas.drawLine(
      Offset(chartRect.left, chartRect.bottom),
      Offset(chartRect.right, chartRect.bottom),
      axisPaint,
    );

    // Y axis
    canvas.drawLine(
      Offset(chartRect.left, chartRect.top),
      Offset(chartRect.left, chartRect.bottom),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(CorrelationChartPainter oldDelegate) {
    return data != oldDelegate.data;
  }
}