import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../providers/pluviometer_provider.dart';
import '../widgets/rainfall_chart_widget.dart';
import '../widgets/statistics_summary_widget.dart';

/// Página de estatísticas pluviométricas
class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(statisticsProvider.notifier);
      notifier.loadStatistics();
      notifier.loadMonthlyTotals(DateTime.now().year);
      notifier.loadYearlyTotals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar CSV',
            onPressed: () => _exportCsv(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumo'),
            Tab(text: 'Mensal'),
            Tab(text: 'Anual'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab Resumo
                _SummaryTab(state: state),

                // Tab Mensal
                _MonthlyTab(
                  state: state,
                  onYearChanged: (year) {
                    ref
                        .read(statisticsProvider.notifier)
                        .selectYear(year);
                  },
                ),

                // Tab Anual
                _YearlyTab(state: state),
              ],
            ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final csv = await ref.read(csvExporterProvider.notifier).exportToCsv();

      if (csv != null && mounted) {
        // Salva arquivo
        final directory = await getApplicationDocumentsDirectory();
        final timestamp =
            DateTime.now().millisecondsSinceEpoch;
        final file = File('${directory.path}/pluviometria_$timestamp.csv');
        await file.writeAsString(csv);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CSV exportado para: ${file.path}'),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    }
  }
}

/// Tab de resumo geral
class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.state});

  final StatisticsState state;

  @override
  Widget build(BuildContext context) {
    if (state.statistics == null) {
      return const Center(child: Text('Sem dados disponíveis'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatisticsSummaryWidget(statistics: state.statistics!),
          const SizedBox(height: 24),
          Text(
            'Distribuição Mensal (${state.selectedYear ?? DateTime.now().year})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: RainfallChartWidget.monthly(
              monthlyTotals: state.monthlyTotals,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab de estatísticas mensais
class _MonthlyTab extends StatelessWidget {
  const _MonthlyTab({
    required this.state,
    required this.onYearChanged,
  });

  final StatisticsState state;
  final void Function(int year) onYearChanged;

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (i) => currentYear - i);

    return Column(
      children: [
        // Seletor de ano
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Ano: '),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: state.selectedYear ?? currentYear,
                items: years
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        ))
                    .toList(),
                onChanged: (year) {
                  if (year != null) onYearChanged(year);
                },
              ),
            ],
          ),
        ),

        // Gráfico
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: state.monthlyTotals.isEmpty
                ? const Center(child: Text('Sem dados para este ano'))
                : RainfallChartWidget.monthly(
                    monthlyTotals: state.monthlyTotals,
                    showLabels: true,
                  ),
          ),
        ),

        // Tabela de dados
        Expanded(
          child: _MonthlyDataTable(monthlyTotals: state.monthlyTotals),
        ),
      ],
    );
  }
}

/// Tab de estatísticas anuais
class _YearlyTab extends StatelessWidget {
  const _YearlyTab({required this.state});

  final StatisticsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gráfico anual
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: state.yearlyTotals.isEmpty
                ? const Center(child: Text('Sem dados disponíveis'))
                : RainfallChartWidget.yearly(
                    yearlyTotals: state.yearlyTotals,
                  ),
          ),
        ),

        // Tabela de comparação
        Expanded(
          child: _YearlyDataTable(yearlyTotals: state.yearlyTotals),
        ),
      ],
    );
  }
}

/// Tabela de dados mensais
class _MonthlyDataTable extends StatelessWidget {
  const _MonthlyDataTable({required this.monthlyTotals});

  final Map<int, double> monthlyTotals;

  @override
  Widget build(BuildContext context) {
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    final total = monthlyTotals.values.fold(0.0, (a, b) => a + b);

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Mês')),
          DataColumn(label: Text('Total (mm)'), numeric: true),
          DataColumn(label: Text('% do Ano'), numeric: true),
        ],
        rows: [
          ...List.generate(12, (i) {
            final month = i + 1;
            final value = monthlyTotals[month] ?? 0;
            final percentage = total > 0 ? (value / total) * 100 : 0;

            return DataRow(cells: [
              DataCell(Text(months[i])),
              DataCell(Text(value.toStringAsFixed(1))),
              DataCell(Text('${percentage.toStringAsFixed(1)}%')),
            ]);
          }),
          // Linha de total
          DataRow(
            color: WidgetStateProperty.all(
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            ),
            cells: [
              const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(
                total.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              const DataCell(Text('100%', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tabela de dados anuais
class _YearlyDataTable extends StatelessWidget {
  const _YearlyDataTable({required this.yearlyTotals});

  final Map<int, double> yearlyTotals;

  @override
  Widget build(BuildContext context) {
    final sortedYears = yearlyTotals.keys.toList()..sort((a, b) => b.compareTo(a));
    final average = yearlyTotals.values.isEmpty
        ? 0.0
        : yearlyTotals.values.reduce((a, b) => a + b) / yearlyTotals.length;

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Ano')),
          DataColumn(label: Text('Total (mm)'), numeric: true),
          DataColumn(label: Text('vs Média'), numeric: true),
        ],
        rows: [
          ...sortedYears.map((year) {
            final value = yearlyTotals[year] ?? 0;
            final diff = average > 0 ? ((value - average) / average) * 100 : 0;
            final diffText = diff >= 0
                ? '+${diff.toStringAsFixed(1)}%'
                : '${diff.toStringAsFixed(1)}%';

            return DataRow(cells: [
              DataCell(Text(year.toString())),
              DataCell(Text(value.toStringAsFixed(1))),
              DataCell(Text(
                diffText,
                style: TextStyle(
                  color: diff >= 0 ? Colors.green : Colors.red,
                ),
              )),
            ]);
          }),
          // Linha de média
          DataRow(
            color: WidgetStateProperty.all(
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            ),
            cells: [
              const DataCell(Text('Média', style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(
                average.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              const DataCell(Text('-')),
            ],
          ),
        ],
      ),
    );
  }
}
