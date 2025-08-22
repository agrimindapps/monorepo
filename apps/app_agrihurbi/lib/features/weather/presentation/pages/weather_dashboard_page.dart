import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_current_card.dart';
import '../widgets/weather_measurements_list.dart';
import '../widgets/rain_gauges_summary.dart';
import '../widgets/weather_statistics_card.dart';
import '../../domain/entities/weather_measurement_entity.dart';

/// Main weather dashboard page
/// Displays current weather, measurements, rain gauges, and statistics
class WeatherDashboardPage extends StatefulWidget {
  const WeatherDashboardPage({super.key});

  @override
  State<WeatherDashboardPage> createState() => _WeatherDashboardPageState();
}

class _WeatherDashboardPageState extends State<WeatherDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize weather provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estação Meteorológica'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Sync button
          Consumer<WeatherProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: provider.isSyncing ? null : () => _syncWeatherData(),
                icon: provider.isSyncing
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
          
          // Settings button
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
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !provider.hasMeasurements) {
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

          if (provider.hasError && !provider.hasMeasurements) {
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
                    provider.errorMessage ?? 'Erro desconhecido',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.initialize(),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCurrentWeatherTab(provider),
              _buildHistoryTab(provider),
              _buildRainGaugesTab(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMeasurementDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Adicionar medição manual',
      ),
    );
  }

  /// Build current weather tab
  Widget _buildCurrentWeatherTab(WeatherProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadLatestMeasurement(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current weather card
            WeatherCurrentCard(
              measurement: provider.latestMeasurement,
              isLoading: provider.isLoading,
            ),
            
            const SizedBox(height: 16),
            
            // Weather statistics
            if (provider.hasStatistics) ...[
              WeatherStatisticsCard(
                statistics: provider.statistics.first,
              ),
              const SizedBox(height: 16),
            ],
            
            // Quick actions
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
  Widget _buildHistoryTab(WeatherProvider provider) {
    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDateRangePicker(),
                  icon: const Icon(Icons.date_range),
                  label: Text(_getDateRangeText(provider)),
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
        
        // Measurements list
        Expanded(
          child: WeatherMeasurementsList(
            measurements: provider.measurements,
            isLoading: provider.isMeasurementsLoading,
            hasMore: provider.hasMoreMeasurements,
            onLoadMore: () => provider.loadMoreMeasurements(),
            onRefresh: () => provider.loadMeasurements(refresh: true),
          ),
        ),
      ],
    );
  }

  /// Build rain gauges tab
  Widget _buildRainGaugesTab(WeatherProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadRainGauges(refresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rain gauges summary
            RainGaugesSummary(
              rainGauges: provider.rainGauges,
              isLoading: provider.isRainGaugesLoading,
            ),
            
            const SizedBox(height: 16),
            
            // Rain gauges status
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
                    _buildStatusRow('Operacionais', provider.operationalRainGauges.length, Colors.green),
                    _buildStatusRow('Necessitam Manutenção', provider.rainGaugesNeedingMaintenance.length, Colors.orange),
                    _buildStatusRow('Total', provider.rainGauges.length, Colors.blue),
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
  String _getDateRangeText(WeatherProvider provider) {
    if (provider.startDate == null && provider.endDate == null) {
      return 'Período: Todos';
    }
    
    final start = provider.startDate?.toLocal().toString().split(' ')[0] ?? 'Início';
    final end = provider.endDate?.toLocal().toString().split(' ')[0] ?? 'Fim';
    
    return '$start - $end';
  }

  /// Sync weather data
  Future<void> _syncWeatherData() async {
    final provider = context.read<WeatherProvider>();
    final success = await provider.syncWeatherData();
    
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
    // Implementation for settings dialog
    showDialog(
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
    // Implementation for manual measurement input
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Medição Manual'),
        content: const Text(
          'Esta funcionalidade permite adicionar medições meteorológicas manualmente.\n\n'
          'Em desenvolvimento...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open measurement form
            },
            child: const Text('Abrir Formulário'),
          ),
        ],
      ),
    );
  }

  /// Show date range picker
  Future<void> _showDateRangePicker() async {
    final provider = context.read<WeatherProvider>();
    
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: provider.startDate != null && provider.endDate != null
          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
          : null,
    );

    if (picked != null) {
      provider.setDateRangeFilter(picked.start, picked.end);
    }
  }

  /// Show filter dialog
  Future<void> _showFilterDialog() async {
    // Implementation for advanced filters
    showDialog(
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
    // For demo purposes, using São Paulo coordinates
    const latitude = -23.5505;
    const longitude = -46.6333;
    
    final provider = context.read<WeatherProvider>();
    await provider.getCurrentWeatherFromAPI(latitude, longitude);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.hasError 
                ? 'Erro ao obter dados da API'
                : 'Dados atualizados da API!',
          ),
          backgroundColor: provider.hasError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  /// Get weather forecast
  Future<void> _getWeatherForecast() async {
    // For demo purposes, using São Paulo coordinates
    const latitude = -23.5505;
    const longitude = -46.6333;
    
    final provider = context.read<WeatherProvider>();
    await provider.getWeatherForecast(latitude, longitude, days: 7);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.hasError 
                ? 'Erro ao obter previsão'
                : 'Previsão de 7 dias obtida!',
          ),
          backgroundColor: provider.hasError ? Colors.red : Colors.green,
        ),
      );
    }
  }
}