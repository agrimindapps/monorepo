import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/rain_gauge_entity.dart';
import '../../domain/entities/weather_measurement_entity.dart';
import '../providers/weather_provider.dart';

import '../widgets/weather_chart_widget.dart';

class RainGaugeDetailPage extends ConsumerStatefulWidget {
  final String rainGaugeId;

  const RainGaugeDetailPage({
    super.key,
    required this.rainGaugeId,
  });

  @override
  ConsumerState<RainGaugeDetailPage> createState() => _RainGaugeDetailPageState();
}

class _RainGaugeDetailPageState extends ConsumerState<RainGaugeDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gauge = _findGauge();
      if (gauge != null) {
        // Set filter to load measurements for this location
        ref.read(weatherProvider.notifier).setLocationFilter(gauge.locationId);
      }
    });
  }

  RainGaugeEntity? _findGauge() {
    final state = ref.read(weatherProvider);
    try {
      return state.rainGauges.firstWhere((g) => g.id == widget.rainGaugeId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);
    
    // Find gauge in current state
    RainGaugeEntity? gauge;
    try {
      gauge = state.rainGauges.firstWhere((g) => g.id == widget.rainGaugeId);
    } catch (_) {
      // Gauge not found or deleted
    }

    if (gauge == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Pluviômetro')),
        body: const Center(child: Text('Pluviômetro não encontrado')),
      );
    }

    // Filter measurements for this location
    final measurements = state.measurements
        .where((m) => m.locationId == gauge!.locationId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(gauge.locationName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.pushNamed(
                'weather-rain-gauges-edit',
                pathParameters: {'id': gauge!.id},
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(weatherProvider.notifier).loadMeasurements(refresh: true);
          await ref.read(weatherProvider.notifier).loadRainGauges();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(context, gauge),
                    const SizedBox(height: 16),
                    _buildMetricsGrid(context, gauge),
                    const SizedBox(height: 24),
                    if (measurements.isNotEmpty) ...[
                      WeatherChartWidget(
                        measurements: measurements,
                        title: 'Precipitação (Últimos dias)',
                        isRainfall: true,
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      'Histórico de Medições',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (state.isMeasurementsLoading && measurements.isEmpty)
               const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                )),
              )
            else if (measurements.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.history_toggle_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          'Nenhuma medição registrada',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final measurement = measurements[index];
                    return _buildMeasurementItem(context, measurement);
                  },
                  childCount: measurements.length,
                ),
              ),
             // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, RainGaugeEntity gauge) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(gauge.statusColor, colorScheme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${gauge.status.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ID: ${gauge.deviceId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Bateria',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  gauge.batteryLevel != null 
                      ? '${gauge.batteryLevel!.toStringAsFixed(0)}%' 
                      : 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, RainGaugeEntity gauge) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Chuva Hoje',
                '${gauge.dailyAccumulation.toStringAsFixed(1)} mm',
                Icons.water_drop,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                context,
                'Chuva Mês',
                '${gauge.monthlyAccumulation.toStringAsFixed(1)} mm',
                Icons.calendar_today,
                Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildMetricCard(
          context,
          'Última Leitura',
          DateFormat('dd/MM/yyyy HH:mm').format(gauge.lastMeasurement),
          Icons.access_time,
          Colors.grey.shade700,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: fullWidth ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementItem(BuildContext context, WeatherMeasurementEntity measurement) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.blue,
        child: Icon(Icons.water_drop, color: Colors.white, size: 20),
      ),
      title: Text('${measurement.rainfall.toStringAsFixed(1)} mm'),
      subtitle: Text(
        DateFormat('dd/MM/yyyy HH:mm').format(measurement.timestamp),
      ),
      trailing: Text(
        '${measurement.temperature.toStringAsFixed(1)}°C',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Color _getStatusColor(String statusColorName, ColorScheme scheme) {
    switch (statusColorName.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.orange;
      case 'red':
        return scheme.error;
      case 'gray':
      default:
        return scheme.outline;
    }
  }
}
