import 'package:flutter/material.dart';

import 'analytics_dashboard_service.dart';

/// Analytics Dashboard Screen for admin/analytics viewing
/// Shows comprehensive analytics insights and conversion funnels
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnalyticsDashboardService _analyticsService;
  
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  UserEngagementMetrics? _engagementMetrics;
  ConversionFunnelMetrics? _funnelMetrics;
  PerformanceMetrics? _performanceMetrics;
  RevenueMetrics? _revenueMetrics;
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _analyticsService = AnalyticsDashboardService.instance;
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _analyticsService.getUserEngagementMetrics(
          startDate: _startDate,
          endDate: _endDate,
        ),
        _analyticsService.getConversionFunnelMetrics(
          startDate: _startDate,
          endDate: _endDate,
        ),
        _analyticsService.getPerformanceMetrics(
          startDate: _startDate,
          endDate: _endDate,
        ),
        _analyticsService.getRevenueMetrics(
          startDate: _startDate,
          endDate: _endDate,
        ),
      ]);

      setState(() {
        _engagementMetrics = results[0] as UserEngagementMetrics;
        _funnelMetrics = results[1] as ConversionFunnelMetrics;
        _performanceMetrics = results[2] as PerformanceMetrics;
        _revenueMetrics = results[3] as RevenueMetrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadAnalyticsData();
    }
  }

  Future<void> _exportReport() async {
    try {
      // ignore: unused_local_variable
      final report = await _analyticsService.exportAnalyticsReport(
        startDate: _startDate,
        endDate: _endDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relatório exportado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar relatório: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Engajamento'),
            Tab(text: 'Conversão'),
            Tab(text: 'Performance'),
            Tab(text: 'Receita'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportReport,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAnalyticsData,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildDateRangeHeader(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildEngagementTab(),
                          _buildConversionTab(),
                          _buildPerformanceTab(),
                          _buildRevenueTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDateRangeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Período: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          TextButton(
            onPressed: _selectDateRange,
            child: const Text('Alterar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementTab() {
    if (_engagementMetrics == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas de Engajamento',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildMetricsGrid([
            _MetricCard(
              title: 'Usuários Ativos Diários',
              value: _engagementMetrics!.dailyActiveUsers.toString(),
              icon: Icons.today,
              color: Colors.blue,
            ),
            _MetricCard(
              title: 'Usuários Ativos Semanais',
              value: _engagementMetrics!.weeklyActiveUsers.toString(),
              icon: Icons.date_range,
              color: Colors.green,
            ),
            _MetricCard(
              title: 'Usuários Ativos Mensais',
              value: _engagementMetrics!.monthlyActiveUsers.toString(),
              icon: Icons.calendar_month,
              color: Colors.purple,
            ),
            _MetricCard(
              title: 'Duração Média da Sessão',
              value: '${_engagementMetrics!.avgSessionDuration.toStringAsFixed(1)}min',
              icon: Icons.timer,
              color: Colors.orange,
            ),
          ]),
          const SizedBox(height: 24),
          Text(
            'Uso de Funcionalidades',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildFeatureUsageChart(_engagementMetrics!.featureUsage),
        ],
      ),
    );
  }

  Widget _buildConversionTab() {
    if (_funnelMetrics == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Funil de Conversão',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildConversionFunnel(_funnelMetrics!),
          const SizedBox(height: 24),
          Text(
            'Taxas de Conversão',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildConversionRatesTable(_funnelMetrics!.conversionRates),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    if (_performanceMetrics == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas de Performance',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildMetricsGrid([
            _MetricCard(
              title: 'Tempo de Inicialização',
              value: '${_performanceMetrics!.avgAppStartupTime.toStringAsFixed(2)}s',
              icon: Icons.speed,
              color: Colors.cyan,
            ),
            _MetricCard(
              title: 'Carregamento de Tela',
              value: '${_performanceMetrics!.avgScreenLoadTime.toStringAsFixed(2)}s',
              icon: Icons.hourglass_empty,
              color: Colors.indigo,
            ),
            _MetricCard(
              title: 'Crashes',
              value: _performanceMetrics!.crashCount.toString(),
              icon: Icons.error,
              color: Colors.red,
            ),
            _MetricCard(
              title: 'Erros',
              value: _performanceMetrics!.errorCount.toString(),
              icon: Icons.warning,
              color: Colors.amber,
            ),
          ]),
          const SizedBox(height: 24),
          Text(
            'Performance por Feature',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildFeaturePerformanceChart(_performanceMetrics!.featurePerformance),
        ],
      ),
    );
  }

  Widget _buildRevenueTab() {
    if (_revenueMetrics == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas de Receita',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildMetricsGrid([
            _MetricCard(
              title: 'Receita Total',
              value: 'R\$ ${_revenueMetrics!.totalRevenue.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            _MetricCard(
              title: 'ARPU',
              value: 'R\$ ${_revenueMetrics!.averageRevenuePerUser.toStringAsFixed(2)}',
              icon: Icons.person,
              color: Colors.blue,
            ),
            _MetricCard(
              title: 'Assinaturas Ativas',
              value: _revenueMetrics!.activeSubscriptions.toString(),
              icon: Icons.subscriptions,
              color: Colors.purple,
            ),
            _MetricCard(
              title: 'Churn Rate',
              value: '${_revenueMetrics!.churnRate.toStringAsFixed(1)}%',
              icon: Icons.trending_down,
              color: Colors.red,
            ),
          ]),
          const SizedBox(height: 24),
          Text(
            'Receita por Plano',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildRevenueByPlanChart(_revenueMetrics!.revenueByPlan),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(List<_MetricCard> cards) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: cards.map((card) => _buildMetricCard(card)).toList(),
    );
  }

  Widget _buildMetricCard(_MetricCard card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: card.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(card.icon, color: card.color, size: 32),
          const SizedBox(height: 8),
          Text(
            card.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: card.color,
            ),
          ),
          Text(
            card.title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureUsageChart(Map<String, int> featureUsage) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: featureUsage.entries.map((entry) {
          final percentage = entry.value / featureUsage.values.reduce((a, b) => a > b ? a : b);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    entry.key.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.value.toString(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConversionFunnel(ConversionFunnelMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: ConversionFunnelStep.values.map((step) {
          final count = metrics.stepCounts[step] ?? 0;
          final rate = metrics.conversionRates[step] ?? 0.0;
          final maxCount = metrics.stepCounts.values.reduce((a, b) => a > b ? a : b);
          final width = count / maxCount;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.stepName.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.6 * width,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          count.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${rate.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConversionRatesTable(Map<ConversionFunnelStep, double> rates) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: rates.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key.stepName.replaceAll('_', ' ')),
                Text(
                  '${entry.value.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturePerformanceChart(Map<String, double> performance) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: performance.entries.map((entry) {
          final color = entry.value < 1.0 ? Colors.green : entry.value < 2.0 ? Colors.orange : Colors.red;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(entry.key.toUpperCase()),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (entry.value / 3.0).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${entry.value.toStringAsFixed(2)}s',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRevenueByPlanChart(Map<String, double> revenueByPlan) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: revenueByPlan.entries.map((entry) {
          final total = revenueByPlan.values.reduce((a, b) => a + b);
          final percentage = entry.value / total;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(entry.key.toUpperCase()),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'R\$ ${entry.value.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MetricCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}