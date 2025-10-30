import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/analytics/advanced_health_monitoring_service.dart';
import '../../core/di/injection_container.dart' as di;
import 'domain/services/monitoring_alert_service.dart';
import 'domain/services/monitoring_formatter_service.dart';
import 'domain/services/monitoring_ui_mapper_service.dart';

/// Error tracking dashboard for monitoring system health and issues
///
/// **REFACTORED (SOLID):**
/// - Usa serviços especializados para formatação, mapeamento UI e alertas
/// - Lógica de negócio extraída para serviços reutilizáveis
/// - Dependency Injection: serviços injetados via DI
class ErrorTrackingDashboard extends StatefulWidget {
  const ErrorTrackingDashboard({super.key});

  @override
  State<ErrorTrackingDashboard> createState() => _ErrorTrackingDashboardState();
}

class _ErrorTrackingDashboardState extends State<ErrorTrackingDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AdvancedHealthMonitoringService _healthService;
  late MonitoringFormatterService _formatterService;
  late MonitoringUIMapperService _uiMapperService;
  late MonitoringAlertService _alertService;

  SystemHealthReport? _currentReport;
  List<SystemHealthReport> _healthHistory = [];
  List<MonitoringAlert> _alerts = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _healthService = AdvancedHealthMonitoringService.instance;

    // Injeção de serviços via DI (SOLID - Dependency Inversion Principle)
    _formatterService = di.sl<MonitoringFormatterService>();
    _uiMapperService = di.sl<MonitoringUIMapperService>();
    _alertService = di.sl<MonitoringAlertService>();

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
      final alerts = _alertService.getRecentAlerts(limit: 10);

      setState(() {
        _currentReport = report;
        _healthHistory = history;
        _alerts = alerts;
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
          ? const Center(child: CircularProgressIndicator())
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
      return const Center(child: Text('Nenhum dado disponível'));
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
          ..._currentReport!.componentResults.map(
            (result) => _buildComponentCard(result),
          ),
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
      return const Center(child: Text('Nenhum histórico disponível'));
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
    // REFACTORED: Usa MonitoringAlertService para obter alertas reais
    if (_alerts.isEmpty) {
      return const Center(child: Text('Nenhum alerta no momento'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return _buildAlertCard(alert);
      },
    );
  }

  Widget _buildOverallStatusCard(SystemHealthReport report) {
    // REFACTORED: Usa MonitoringUIMapperService para mapear status -> UI
    final statusColor = _uiMapperService.getStatusColor(report.overallStatus);
    final statusIcon = _uiMapperService.getStatusIcon(report.overallStatus);
    final statusText = _uiMapperService.getStatusText(report.overallStatus);

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
                        'Última verificação: ${_formatterService.formatRelativeTime(report.timestamp)}',
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
    // REFACTORED: Usa MonitoringUIMapperService para mapear status -> UI
    final statusColor = _uiMapperService.getStatusColor(result.status);
    final statusIcon = _uiMapperService.getStatusIcon(
      result.status,
      outlined: true,
    );

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
              _formatterService.formatRelativeTime(result.timestamp),
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
            ...metrics.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatterService.formatMetricKey(entry.key),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(entry.value.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(SystemHealthReport report) {
    // REFACTORED: Usa MonitoringUIMapperService para mapear status -> UI
    final statusColor = _uiMapperService.getStatusColor(report.overallStatus);

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
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        title: Text(report.overallStatus.value.toUpperCase()),
        subtitle: Text(
          '${report.componentResults.length} componentes verificados • '
          '${criticalCount > 0 ? '$criticalCount críticos • ' : ''}'
          '${warningCount > 0 ? '$warningCount avisos' : ''}',
        ),
        trailing: Text(
          _formatterService.formatRelativeTime(report.timestamp),
          style: const TextStyle(fontSize: 12),
        ),
        onTap: () => _showReportDetails(report),
      ),
    );
  }

  Widget _buildAlertCard(MonitoringAlert alert) {
    // REFACTORED: Usa MonitoringUIMapperService para mapear nível -> UI
    final alertColor = _uiMapperService.getAlertLevelColor(alert.level);
    final alertIcon = _uiMapperService.getAlertLevelIcon(alert.level);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(alertIcon, color: alertColor),
        title: Text(alert.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message),
            const SizedBox(height: 4),
            Text(
              _formatterService.formatRelativeTime(alert.timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            alert.level.toUpperCase(),
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
              const Text(
                'Métricas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...result.metrics.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              ),
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

  // REMOVED: _formatTime() e _formatMetricKey()
  // Agora usa MonitoringFormatterService para formatação (SOLID - SRP)
}

class _ReportDetailsScreen extends StatelessWidget {
  final SystemHealthReport report;

  const _ReportDetailsScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Relatório')),
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
            ...report.componentResults.map(
              (result) => Card(
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
                      const Text(
                        'Métricas:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...result.metrics.entries.map(
                        (entry) => Text('${entry.key}: ${entry.value}'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
