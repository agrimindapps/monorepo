import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../providers/weather_provider.dart';
import '../widgets/rain_gauge_card_widget.dart';
import '../widgets/rain_gauges_summary.dart';
import '../widgets/weather_chart_widget.dart';
import '../widgets/weather_current_card.dart';
import '../widgets/weather_measurements_list.dart';
import '../widgets/weather_statistics_card.dart';

/// Main weather dashboard page
/// Displays current weather, measurements, rain gauges, and statistics
class WeatherDashboardPage extends ConsumerStatefulWidget {
  const WeatherDashboardPage({super.key});

  @override
  ConsumerState<WeatherDashboardPage> createState() => _WeatherDashboardPageState();
}

class _WeatherDashboardPageState extends ConsumerState<WeatherDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);
    final notifier = ref.read(weatherProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estação Meteorológica'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: state.isSyncing ? null : () => _syncWeatherData(),
                icon: state.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                tooltip: 'Sincronizar dados',
              );
            },
          ),
          IconButton(
            onPressed: () => _showSettingsDialog(),
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Atual', icon: Icon(Icons.wb_sunny)),
            Tab(text: 'Histórico', icon: Icon(Icons.history)),
            Tab(text: 'Pluviômetros', icon: Icon(Icons.water_drop)),
          ],
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && !state.hasMeasurements) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando dados meteorológicos...'),
                ],
              ),
            );
          }

          if (state.hasError && !state.hasMeasurements) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar dados',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Erro desconhecido',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => notifier.initialize(),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCurrentWeatherTab(state, notifier),
              _buildHistoryTab(state, notifier),
              _buildRainGaugesTab(state, notifier),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMeasurementDialog(),
        tooltip: 'Adicionar medição manual',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build current weather tab
  Widget _buildCurrentWeatherTab(WeatherState state, WeatherNotifier notifier) {
    return RefreshIndicator(
      onRefresh: () => notifier.loadLatestMeasurement(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WeatherCurrentCard(
              measurement: state.latestMeasurement,
              isLoading: state.isLoading,
            ),
            
            const SizedBox(height: 16),
            if (state.measurements.isNotEmpty) ...[
              WeatherChartWidget(
                measurements: state.measurements.take(14).toList(),
                title: 'Tendência de Temperatura',
                isRainfall: false,
              ),
              const SizedBox(height: 16),
            ],
            if (state.hasStatistics) ...[
              WeatherStatisticsCard(
                statistics: state.statistics.first,
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ações Rápidas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickActionButton(
                          context,
                          'API Externa',
                          Icons.cloud_download,
                          () => _getCurrentWeatherFromAPI(),
                        ),
                        _buildQuickActionButton(
                          context,
                          'Previsão',
                          Icons.wb_cloudy,
                          () => _getWeatherForecast(),
                        ),
                        _buildQuickActionButton(
                          context,
                          'Manual',
                          Icons.edit,
                          () => _showAddMeasurementDialog(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build history tab
  Widget _buildHistoryTab(WeatherState state, WeatherNotifier notifier) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDateRangePicker(),
                  icon: const Icon(Icons.date_range),
                  label: Text(_getDateRangeText(state)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showFilterDialog(),
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filtros avançados',
              ),
            ],
          ),
        ),
        Expanded(
          child: WeatherMeasurementsList(
            measurements: state.measurements,
            isLoading: state.isMeasurementsLoading,
            hasMore: state.hasMoreMeasurements,
            onLoadMore: () => notifier.loadMoreMeasurements(),
            onRefresh: () => notifier.loadMeasurements(refresh: true),
          ),
        ),
      ],
    );
  }

  /// Build rain gauges tab
  Widget _buildRainGaugesTab(WeatherState state, WeatherNotifier notifier) {
    return RefreshIndicator(
      onRefresh: () => notifier.loadRainGauges(refresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RainGaugesSummary(
              rainGauges: state.rainGauges,
              isLoading: state.isRainGaugesLoading,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.pushNamed('weather-rain-gauges');
              },
              icon: const Icon(Icons.list),
              label: const Text('Gerenciar Pluviômetros'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pluviômetros Ativos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (state.activeRainGauges.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhum pluviômetro ativo no momento.'),
                ),
              )
            else
              ...state.activeRainGauges.take(3).map(
                    (gauge) => RainGaugeCardWidget(
                      rainGauge: gauge,
                      onTap: () {
                        context.pushNamed(
                          'weather-rain-gauges-detail',
                          pathParameters: {'id': gauge.id},
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status dos Pluviômetros',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildStatusRow(
                      'Operacionais',
                      state.operationalRainGauges.length,
                      Colors.green,
                    ),
                    _buildStatusRow(
                      'Necessitam Manutenção',
                      state.rainGaugesNeedingMaintenance.length,
                      Colors.orange,
                    ),
                    _buildStatusRow(
                      'Total',
                      state.rainGauges.length,
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick action button
  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build status row
  Widget _buildStatusRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Get date range text for display
  String _getDateRangeText(WeatherState state) {
    if (state.startDate == null && state.endDate == null) {
      return 'Período: Todos';
    }
    
    final start = state.startDate?.toLocal().toString().split(' ')[0] ?? 'Início';
    final end = state.endDate?.toLocal().toString().split(' ')[0] ?? 'Fim';
    
    return '$start - $end';
  }

  /// Sync weather data
  Future<void> _syncWeatherData() async {
    final notifier = ref.read(weatherProvider.notifier);
    final success = await notifier.syncWeatherData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Dados sincronizados com sucesso!' : 'Erro na sincronização',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Show settings dialog
  Future<void> _showSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Localização'),
              subtitle: Text('Configurar localização padrão'),
            ),
            ListTile(
              leading: Icon(Icons.sync),
              title: Text('Sincronização'),
              subtitle: Text('Configurar sync automático'),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notificações'),
              subtitle: Text('Configurar alertas meteorológicos'),
            ),
          ],
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

  /// Show add measurement dialog
  Future<void> _showAddMeasurementDialog() async {
    context.pushNamed('weather-measurements-add');
  }

  /// Show date range picker
  Future<void> _showDateRangePicker() async {
    final state = ref.read(weatherProvider);
    final notifier = ref.read(weatherProvider.notifier);
    
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: state.startDate != null && state.endDate != null
          ? DateTimeRange(start: state.startDate!, end: state.endDate!)
          : null,
    );

    if (picked != null) {
      notifier.setDateRangeFilter(picked.start, picked.end);
    }
  }

  /// Show filter dialog
  Future<void> _showFilterDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros Avançados'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Temperatura mínima (°C)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Temperatura máxima (°C)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Chuva mínima (mm)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  /// Get current weather from API
  Future<void> _getCurrentWeatherFromAPI() async {
    const latitude = -23.5505;
    const longitude = -46.6333;
    
    final notifier = ref.read(weatherProvider.notifier);
    await notifier.getCurrentWeatherFromAPI(latitude, longitude);
    
    final state = ref.read(weatherProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.hasError 
                ? 'Erro ao obter dados da API'
                : 'Dados atualizados da API!',
          ),
          backgroundColor: state.hasError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  /// Get weather forecast
  Future<void> _getWeatherForecast() async {
    const latitude = -23.5505;
    const longitude = -46.6333;
    
    final notifier = ref.read(weatherProvider.notifier);
    await notifier.getWeatherForecast(latitude, longitude, days: 7);
    
    final state = ref.read(weatherProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.hasError 
                ? 'Erro ao obter previsão'
                : 'Previsão de 7 dias obtida!',
          ),
          backgroundColor: state.hasError ? Colors.red : Colors.green,
        ),
      );
    }
  }
}
