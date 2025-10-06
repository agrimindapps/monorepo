import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/analytics/advanced_health_monitoring_service.dart';

/// Error tracking dashboard for monitoring system health and issues
class ErrorTrackingDashboard extends StatefulWidget {
  const ErrorTrackingDashboard({super.key});

  @override
  State<ErrorTrackingDashboard> createState() => _ErrorTrackingDashboardState();
}

class _ErrorTrackingDashboardState extends State<ErrorTrackingDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AdvancedHealthMonitoringService _healthService;

  SystemHealthReport? _currentReport;
  List<SystemHealthReport> _healthHistory = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _healthService = AdvancedHealthMonitoringService.instance;
    _loadHealthData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHealthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final report = await _healthService.performHealthCheck();
      final history = _healthService.getHealthHistory(limit: 20);

      setState(() {
        _currentReport = report;
        _healthHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        _loadHealthData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Monitoramento'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Status Atual'),
            Tab(text: 'Histórico'),
            Tab(text: 'Alertas'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHealthData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentStatusTab(),
                _buildHistoryTab(),
                _buildAlertsTab(),
              ],
            ),
    );
  }

  Widget _buildCurrentStatusTab() {
    if (_currentReport == null) {
      return const Center(
        child: Text('Nenhum dado disponível'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallStatusCard(_currentReport!),
          const SizedBox(height: 16),
          Text(
            'Componentes do Sistema',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          ..._currentReport!.componentResults
              .map((result) => _buildComponentCard(result)),
          const SizedBox(height: 16),
          Text(
            'Métricas do Sistema',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _buildSystemMetricsCard(_currentReport!.systemMetrics),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_healthHistory.isEmpty) {
      return const Center(
        child: Text('Nenhum histórico disponível'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _healthHistory.length,
      itemBuilder: (context, index) {
        final report = _healthHistory[index];
        return _buildHistoryCard(report);
      },
    );
  }

  Widget _buildAlertsTab() {
    final alerts = [
      {
        'name': 'Alto uso de memória',
        'level': 'warning',
        'time': '2 min atrás',
        'message': 'Uso de memória em 85%',
      },
      {
        'name': 'Resposta lenta da API',
        'level': 'critical',
        'time': '5 min atrás',
        'message': 'Tempo de resposta médio > 3s',
      },
      {
        'name': 'Falha de sincronização',
        'level': 'warning',
        'time': '10 min atrás',
        'message': '3 sincronizações falharam',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index] as Map<String, dynamic>;
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildOverallStatusCard(SystemHealthReport report) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (report.overallStatus) {
      case HealthStatus.healthy:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Sistema Saudável';
        break;
      case HealthStatus.warning:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'Sistema com Avisos';
        break;
      case HealthStatus.critical:
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Sistema Crítico';
        break;
      case HealthStatus.failed:
        statusColor = Colors.red[900]!;
        statusIcon = Icons.cancel;
        statusText = 'Sistema com Falhas';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Última verificação: ${_formatTime(report.timestamp)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Componentes verificados: ${report.componentResults.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentCard(ComponentHealthResult result) {
    Color statusColor;
    IconData statusIcon;

    switch (result.status) {
      case HealthStatus.healthy:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case HealthStatus.warning:
        statusColor = Colors.orange;
        statusIcon = Icons.warning_outlined;
        break;
      case HealthStatus.critical:
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        break;
      case HealthStatus.failed:
        statusColor = Colors.red[900]!;
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          result.component.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(result.message),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              result.status.value.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              _formatTime(result.timestamp),
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        onTap: () => _showComponentDetails(result),
      ),
    );
  }

  Widget _buildSystemMetricsCard(Map<String, dynamic> metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Sistema',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...metrics.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatMetricKey(entry.key),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(entry.value.toString()),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(SystemHealthReport report) {
    Color statusColor;
    switch (report.overallStatus) {
      case HealthStatus.healthy:
        statusColor = Colors.green;
        break;
      case HealthStatus.warning:
        statusColor = Colors.orange;
        break;
      case HealthStatus.critical:
        statusColor = Colors.red;
        break;
      case HealthStatus.failed:
        statusColor = Colors.red[900]!;
        break;
    }

    final criticalCount = report.componentResults
        .where((r) => r.status == HealthStatus.critical)
        .length;
    final warningCount = report.componentResults
        .where((r) => r.status == HealthStatus.warning)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(report.overallStatus.value.toUpperCase()),
        subtitle: Text(
          '${report.componentResults.length} componentes verificados • '
          '${criticalCount > 0 ? '$criticalCount críticos • ' : ''}'
          '${warningCount > 0 ? '$warningCount avisos' : ''}',
        ),
        trailing: Text(
          _formatTime(report.timestamp),
          style: const TextStyle(fontSize: 12),
        ),
        onTap: () => _showReportDetails(report),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color alertColor;
    IconData alertIcon;

    switch (alert['level'] as String) {
      case 'warning':
        alertColor = Colors.orange;
        alertIcon = Icons.warning;
        break;
      case 'critical':
        alertColor = Colors.red;
        alertIcon = Icons.error;
        break;
      default:
        alertColor = Colors.blue;
        alertIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(alertIcon, color: alertColor),
        title: Text(alert['name'] as String),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert['message'] as String),
            const SizedBox(height: 4),
            Text(
              alert['time'] as String,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            (alert['level'] as String).toUpperCase(),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: alertColor,
        ),
      ),
    );
  }

  void _showComponentDetails(ComponentHealthResult result) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.component.toUpperCase()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status: ${result.status.value}'),
              const SizedBox(height: 8),
              Text('Mensagem: ${result.message}'),
              const SizedBox(height: 8),
              Text('Timestamp: ${result.timestamp}'),
              const SizedBox(height: 16),
              const Text('Métricas:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...result.metrics.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('${entry.key}: ${entry.value}'),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(SystemHealthReport report) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ReportDetailsScreen(report: report),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min atrás';
    } else {
      return 'agora';
    }
  }

  String _formatMetricKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class _ReportDetailsScreen extends StatelessWidget {
  final SystemHealthReport report;

  const _ReportDetailsScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Relatório'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Geral: ${report.overallStatus.value}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Timestamp: ${report.timestamp}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Componentes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ...report.componentResults.map((result) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.component.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('Status: ${result.status.value}'),
                        Text('Mensagem: ${result.message}'),
                        const SizedBox(height: 8),
                        const Text('Métricas:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...result.metrics.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}