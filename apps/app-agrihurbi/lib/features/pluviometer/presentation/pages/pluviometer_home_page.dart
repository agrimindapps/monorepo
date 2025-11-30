import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pluviometer_provider.dart';
import 'measurements_list_page.dart';
import 'rain_gauges_list_page.dart';
import 'statistics_page.dart';

/// Página inicial do módulo de pluviometria
class PluviometerHomePage extends ConsumerStatefulWidget {
  const PluviometerHomePage({super.key});

  @override
  ConsumerState<PluviometerHomePage> createState() =>
      _PluviometerHomePageState();
}

class _PluviometerHomePageState extends ConsumerState<PluviometerHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rainGaugesProvider.notifier).loadGauges();
      ref.read(measurementsProvider.notifier).loadMeasurements();
      ref.read(statisticsProvider.notifier).loadStatistics();
      ref
          .read(statisticsProvider.notifier)
          .loadMonthlyTotals(DateTime.now().year);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DashboardView(),
      const RainGaugesListPage(),
      const MeasurementsListPage(),
      const StatisticsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Resumo',
          ),
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed),
            label: 'Pluviômetros',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Medições',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
        ],
      ),
    );
  }
}

/// View do dashboard/resumo
class _DashboardView extends ConsumerWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gaugesState = ref.watch(rainGaugesProvider);
    final measurementsState = ref.watch(measurementsProvider);
    final statisticsState = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pluviometria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(rainGaugesProvider.notifier).loadGauges();
              ref
                  .read(measurementsProvider.notifier)
                  .loadMeasurements();
              ref.read(statisticsProvider.notifier).loadStatistics();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(rainGaugesProvider.notifier).loadGauges();
          await ref
              .read(measurementsProvider.notifier)
              .loadMeasurements();
          await ref.read(statisticsProvider.notifier).loadStatistics();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cards de resumo
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Pluviômetros',
                      value: '${gaugesState.gauges.length}',
                      icon: Icons.speed,
                      color: Colors.blue,
                      isLoading: gaugesState.isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Medições',
                      value: '${measurementsState.measurements.length}',
                      icon: Icons.water_drop,
                      color: Colors.teal,
                      isLoading: measurementsState.isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Acumulado',
                      value: statisticsState.statistics != null
                          ? '${statisticsState.statistics!.totalAmount.toStringAsFixed(1)} mm'
                          : '-- mm',
                      icon: Icons.water,
                      color: Colors.indigo,
                      isLoading: statisticsState.isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Média',
                      value: statisticsState.statistics != null
                          ? '${statisticsState.statistics!.averageDaily.toStringAsFixed(1)} mm'
                          : '-- mm',
                      icon: Icons.analytics,
                      color: Colors.orange,
                      isLoading: statisticsState.isLoading,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Últimas medições
              Text(
                'Últimas Medições',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (measurementsState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (measurementsState.measurements.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nenhuma medição registrada'),
                  ),
                )
              else
                ...measurementsState.measurements.take(5).map(
                      (m) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.water_drop),
                          ),
                          title: Text('${m.amount.toStringAsFixed(1)} mm'),
                          subtitle: Text(
                            _formatDate(m.measurementDate),
                          ),
                          trailing: m.observations != null
                              ? const Icon(Icons.note)
                              : null,
                        ),
                      ),
                    ),

              const SizedBox(height: 24),

              // Totais mensais (mini gráfico)
              Text(
                'Acumulado Mensal (${statisticsState.selectedYear ?? DateTime.now().year})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (statisticsState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (statisticsState.monthlyTotals.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Sem dados para exibir'),
                  ),
                )
              else
                SizedBox(
                  height: 150,
                  child: _MonthlyBarChart(
                    monthlyTotals: statisticsState.monthlyTotals,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Card de resumo
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Gráfico de barras mensal simplificado
class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart({required this.monthlyTotals});

  final Map<int, double> monthlyTotals;

  @override
  Widget build(BuildContext context) {
    final maxValue = monthlyTotals.values.isEmpty
        ? 1.0
        : monthlyTotals.values.reduce((a, b) => a > b ? a : b);

    final months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(12, (index) {
        final month = index + 1;
        final value = monthlyTotals[month] ?? 0;
        final height = maxValue > 0 ? (value / maxValue) * 100 : 0.0;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (value > 0)
                  Text(
                    value.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                const SizedBox(height: 4),
                Container(
                  height: height.clamp(4.0, 100.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.7),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  months[index],
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
