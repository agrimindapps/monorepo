import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/semantic_widgets.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/notifiers/expenses_notifier.dart';
import '../../../expenses/presentation/state/expenses_state.dart';
import '../../../fuel/domain/entities/fuel_record_entity.dart';
import '../../../fuel/presentation/providers/fuel_riverpod_notifier.dart';
import '../../../maintenance/domain/entities/maintenance_entity.dart';
import '../../../maintenance/presentation/notifiers/maintenances_notifier.dart';
import '../../../maintenance/presentation/notifiers/maintenances_state.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';
import '../../domain/models/timeline_entry.dart';
import '../providers/timeline_providers.dart';

/// Timeline page showing all records in chronological order and statistics
class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage>
    with SingleTickerProviderStateMixin {
  String? _selectedVehicleId;
  late TabController _tabController;

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
    final timelineAsync = _selectedVehicleId == null
        ? ref.watch(timelineProvider)
        : ref.watch(filteredTimelineProvider(vehicleId: _selectedVehicleId));

    final vehiclesAsync = ref.watch(vehiclesProvider);
    final fuelStateAsync = ref.watch(fuelRiverpodProvider);
    final expensesState = ref.watch(expensesProvider);
    final maintenancesState = ref.watch(maintenancesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (vehiclesAsync.value?.isNotEmpty ?? false)
              _buildVehicleSelector(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Timeline
                  timelineAsync.when(
                    data: (entries) {
                      if (entries.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      final groupedEntries = _groupEntriesByDate(entries);

                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(timelineProvider);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: groupedEntries.length,
                          itemBuilder: (context, index) {
                            final dateGroup = groupedEntries[index];
                            return _TimelineDayGroup(
                              date: dateGroup.date,
                              entries: dateGroup.entries,
                              isLast: index == groupedEntries.length - 1,
                            );
                          },
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => _buildErrorState(context, error),
                  ),
                  // Tab 2: Estatísticas
                  fuelStateAsync.when(
                    data: (fuelState) => _buildStatisticsTab(
                      context,
                      fuelState,
                      expensesState,
                      maintenancesState,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => _buildStatisticsTab(
                      context,
                      null,
                      expensesState,
                      maintenancesState,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 9,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.timeline, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Timeline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Histórico de registros',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: EnhancedVehicleSelector(
        selectedVehicleId: _selectedVehicleId,
        onVehicleChanged: (vehicleId) {
          setState(() {
            _selectedVehicleId = vehicleId;
          });
        },
        hintText: 'Todos os veículos',
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timeline, size: 18),
                SizedBox(width: 6),
                Text('Timeline'),
              ],
            ),
          ),
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 18),
                SizedBox(width: 6),
                Text('Estatísticas'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(
    BuildContext context,
    FuelState? fuelState,
    ExpensesState expensesState,
    MaintenancesState maintenancesState,
  ) {
    // Filtrar dados pelo veículo selecionado
    final fuelRecords =
        fuelState?.fuelRecords
            .where(
              (r) =>
                  _selectedVehicleId == null ||
                  r.vehicleId == _selectedVehicleId,
            )
            .toList() ??
        [];

    final expenses = expensesState.expenses
        .where(
          (ExpenseEntity e) =>
              _selectedVehicleId == null || e.vehicleId == _selectedVehicleId,
        )
        .toList();

    final maintenances = maintenancesState.maintenances
        .where(
          (MaintenanceEntity m) =>
              _selectedVehicleId == null || m.vehicleId == _selectedVehicleId,
        )
        .toList();

    // Calcular totais
    final fuelCost = fuelRecords.fold<double>(
      0.0,
      (double total, FuelRecordEntity r) => total + r.totalPrice,
    );
    final expensesCost = expenses.fold<double>(
      0.0,
      (double total, ExpenseEntity e) => total + e.amount,
    );
    final maintenanceCost = maintenances.fold<double>(
      0.0,
      (double total, MaintenanceEntity m) => total + m.cost,
    );

    final totalCost = fuelCost + expensesCost + maintenanceCost;

    if (fuelRecords.isEmpty && expenses.isEmpty && maintenances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Sem dados para exibir',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Adicione registros para visualizar estatísticas',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Gasto Total',
                  value: currencyFormat.format(totalCost),
                  icon: Icons.attach_money,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Combustível',
                  value: currencyFormat.format(fuelCost),
                  icon: Icons.local_gas_station,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Despesas',
                  value: currencyFormat.format(expensesCost),
                  icon: Icons.receipt_long,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Manutenção',
                  value: currencyFormat.format(maintenanceCost),
                  icon: Icons.build,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Quantidade de Registros',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCountCard(
                  context,
                  label: 'Abastecimentos',
                  count: fuelRecords.length,
                  icon: Icons.local_gas_station,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCountCard(
                  context,
                  label: 'Despesas',
                  count: expenses.length,
                  icon: Icons.receipt_long,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCountCard(
                  context,
                  label: 'Manutenções',
                  count: maintenances.length,
                  icon: Icons.build,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard(
    BuildContext context, {
    required String label,
    required int count,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum registro ainda',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Adicione seu primeiro abastecimento, manutenção ou despesa '
              'para começar a acompanhar seu histórico.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar timeline',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Group entries by date (day)
  List<_DateGroup> _groupEntriesByDate(List<TimelineEntry> entries) {
    final Map<String, List<TimelineEntry>> grouped = {};

    for (final entry in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.date);
      grouped.putIfAbsent(dateKey, () => []).add(entry);
    }

    // Sort entries within each day by time (newest first)
    for (final list in grouped.values) {
      list.sort((a, b) => b.date.compareTo(a.date));
    }

    // Convert to list and sort by date (newest first)
    final result = grouped.entries.map((e) {
      return _DateGroup(date: DateTime.parse(e.key), entries: e.value);
    }).toList();

    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }
}

/// Date group model
class _DateGroup {
  final DateTime date;
  final List<TimelineEntry> entries;

  _DateGroup({required this.date, required this.entries});
}

/// Timeline day group widget with vertical line
class _TimelineDayGroup extends StatelessWidget {
  const _TimelineDayGroup({
    required this.date,
    required this.entries,
    required this.isLast,
  });

  final DateTime date;
  final List<TimelineEntry> entries;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'pt_BR');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    String dateLabel;
    if (entryDate == today) {
      dateLabel = 'Hoje';
    } else if (entryDate == yesterday) {
      dateLabel = 'Ontem';
    } else {
      dateLabel = dateFormat.format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 16, bottom: 8),
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        // Entries for this day
        ...entries.asMap().entries.map((mapEntry) {
          final index = mapEntry.key;
          final entry = mapEntry.value;
          final isLastInDay = index == entries.length - 1;

          return _TimelineEntryItem(
            entry: entry,
            showLine: !isLastInDay || !isLast,
          );
        }),
      ],
    );
  }
}

/// Individual timeline entry item with circle and line
class _TimelineEntryItem extends StatelessWidget {
  const _TimelineEntryItem({required this.entry, required this.showLine});

  final TimelineEntry entry;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator (circle + line)
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Circle
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: entry.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: entry.color.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                ),
                // Vertical line
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16, left: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type and time
                  Row(
                    children: [
                      Icon(entry.icon, size: 16, color: entry.color),
                      const SizedBox(width: 6),
                      Text(
                        entry.typeName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: entry.color,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeFormat.format(entry.date),
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Details row (odometer and amount)
                  Row(
                    children: [
                      if (entry.odometer != null) ...[
                        Icon(
                          Icons.speed,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.odometer!.toStringAsFixed(0)} km',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (entry.odometer != null && entry.amount != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            width: 1,
                            height: 12,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      if (entry.amount != null) ...[
                        Text(
                          NumberFormat.currency(
                            locale: 'pt_BR',
                            symbol: 'R\$',
                          ).format(entry.amount),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: entry.color,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
