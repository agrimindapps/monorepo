import 'package:core/core.dart';
import 'package:flutter/material.dart';

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

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  String? _selectedVehicleId;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final fuelStateAsync = ref.watch(fuelRiverpodProvider);
    final expensesState = ref.watch(expensesProvider);
    final maintenancesState = ref.watch(maintenancesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            // Mostrar seletor de veículos se houver veículos cadastrados
            if (vehiclesAsync.value?.isNotEmpty ?? false)
              _buildVehicleSelector(context),
            // Sempre mostrar conteúdo, independentemente de ter veículos ou não
            Expanded(
              child: vehiclesAsync.when(
                data: (_) {
                  return fuelStateAsync.when(
                    data: (fuelState) => _buildContent(
                      context,
                      fuelState,
                      expensesState,
                      maintenancesState,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => _buildContent(
                      context,
                      null,
                      expensesState,
                      maintenancesState,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _buildContent(
                  context,
                  null,
                  expensesState,
                  maintenancesState,
                ),
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
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              blurRadius: 9,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Semantics(
              label: 'Seção de estatísticas',
              hint: 'Página principal para visualizar estatísticas e gráficos',
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Estatísticas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Acompanhe o desempenho dos seus veículos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: EnhancedVehicleSelector(
        selectedVehicleId: _selectedVehicleId,
        onVehicleChanged: (vehicleId) {
          setState(() {
            _selectedVehicleId = vehicleId;
          });
        },
        hintText: 'Selecione um veículo',
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    FuelState? fuelState,
    ExpensesState expensesState,
    MaintenancesState maintenancesState,
  ) {
    return _buildStatisticsContent(fuelState, expensesState, maintenancesState);
  }

  Widget _buildStatisticsContent(
    FuelState? fuelState,
    ExpensesState expensesState,
    MaintenancesState maintenancesState,
  ) {
    // Filtrar dados pelo veículo selecionado
    final fuelRecords = fuelState?.fuelRecords
            .where((r) =>
                _selectedVehicleId == null || r.vehicleId == _selectedVehicleId)
            .toList() ??
        [];

    final expenses = expensesState.expenses
        .where((ExpenseEntity e) =>
            _selectedVehicleId == null || e.vehicleId == _selectedVehicleId)
        .toList();

    final maintenances = maintenancesState.maintenances
        .where((MaintenanceEntity m) =>
            _selectedVehicleId == null || m.vehicleId == _selectedVehicleId)
        .toList();

    // Calcular totais
    final fuelCost = fuelRecords.fold<double>(0.0, (double total, FuelRecordEntity r) => total + r.totalPrice);
    final expensesCost = expenses.fold<double>(0.0, (double total, ExpenseEntity e) => total + e.amount);
    final maintenanceCost =
        maintenances.fold<double>(0.0, (double total, MaintenanceEntity m) => total + m.cost);

    final totalCost = fuelCost + expensesCost + maintenanceCost;

    // Calcular Km rodados (baseado nos abastecimentos)
    double kmTraveled = 0;
    if (fuelRecords.isNotEmpty) {
      // Ordenar por odômetro
      final sortedRecords = List.of(fuelRecords)
        ..sort((a, b) => a.odometer.compareTo(b.odometer));
      
      if (sortedRecords.length > 1) {
        kmTraveled = sortedRecords.last.odometer - sortedRecords.first.odometer;
      } else {
         // Se tiver apenas 1 registro, tenta usar distanceTraveled se disponível
         kmTraveled = sortedRecords.first.distanceTraveled ?? 0;
      }
    }

    // Calcular consumo médio
    double totalConsumption = 0;
    int consumptionCount = 0;
    for (final record in fuelRecords) {
      if (record.consumption != null && record.consumption! > 0) {
        totalConsumption += record.consumption!;
        consumptionCount++;
      }
    }
    final averageConsumption =
        consumptionCount > 0 ? totalConsumption / consumptionCount : 0.0;

    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final numberFormat = NumberFormat.decimalPattern('pt_BR');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSection(
            totalCost: currencyFormat.format(totalCost),
            kmTraveled: '${numberFormat.format(kmTraveled)} km',
            fuelCount: fuelRecords.length.toString(),
            avgConsumption: '${numberFormat.format(averageConsumption)} km/l',
          ),
          const SizedBox(height: 24),
          _buildChartsSection(),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection({
    required String totalCost,
    required String kmTraveled,
    required String fuelCount,
    required String avgConsumption,
  }) {
    return Column(
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
                title: 'Gasto Total',
                value: totalCost,
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Km Rodados',
                value: kmTraveled,
                icon: Icons.speed,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Abastecimentos',
                value: fuelCount,
                icon: Icons.local_gas_station,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Consumo Médio',
                value: avgConsumption,
                icon: Icons.trending_up,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
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
            const SizedBox(height: 12),
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

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gráficos',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.show_chart,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Gráficos visuais estarão disponíveis em breve!',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gráficos serão implementados',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
