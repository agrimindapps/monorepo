import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/month_extractor.dart';
import '../../../../core/widgets/crud_form_dialog.dart';
import '../../../../core/widgets/enhanced_empty_state.dart';
import '../../../../core/widgets/standard_loading_view.dart';
import '../../../../core/widgets/swipe_to_delete_wrapper.dart';
import '../../../../shared/widgets/adaptive_main_navigation.dart';
import '../../../../shared/widgets/month_selector.dart';
import '../../../../shared/widgets/record_page_header.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/vehicle_selector_section.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../providers/fuel_riverpod_notifier.dart';
import 'fuel_form_page.dart';

class FuelPage extends ConsumerStatefulWidget {
  const FuelPage({super.key});

  @override
  ConsumerState<FuelPage> createState() => _FuelPageState();
}

class _FuelPageState extends ConsumerState<FuelPage> {
  String? _selectedVehicleId;
  bool _showMonthlyStats = false; // Toggle para mostrar/ocultar estatísticas

  @override
  Widget build(BuildContext context) {
    final fuelStateAsync = ref.watch(fuelRiverpodProvider);
    final isOnline = ref.watch(fuelIsOnlineProvider);
    final pendingCount = ref.watch(fuelPendingCountProvider);
    final isSyncing = ref.watch(fuelIsSyncingProvider);
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            RecordPageHeader(
              title: 'Abastecimentos',
              subtitle: 'Gerencie os abastecimentos do seu veículo',
              icon: Icons.local_gas_station,
              semanticLabel: 'Seção de abastecimentos',
              semanticHint: 'Página principal para gerenciar abastecimentos',
              actionButton: IconButton(
                icon: Icon(
                  _showMonthlyStats
                      ? Icons.analytics
                      : Icons.analytics_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: _showMonthlyStats
                    ? 'Ocultar estatísticas'
                    : 'Mostrar estatísticas',
                onPressed: () {
                  setState(() {
                    _showMonthlyStats = !_showMonthlyStats;
                  });
                },
              ),
            ),

            if (!isOnline || pendingCount > 0)
              _buildOfflineIndicator(isOnline, pendingCount, isSyncing),

            VehicleSelectorSection(
              selectedVehicleId: _selectedVehicleId,
              onVehicleChanged: (vehicleId) {
                setState(() {
                  _selectedVehicleId = vehicleId;
                });
                // Filtrar abastecimentos por veículo
                if (vehicleId != null) {
                  ref
                      .read(fuelRiverpodProvider.notifier)
                      .filterByVehicle(vehicleId);
                } else {
                  ref.read(fuelRiverpodProvider.notifier).clearVehicleFilter();
                }
              },
            ),

            if (_selectedVehicleId != null &&
                (vehiclesAsync.value?.isNotEmpty ?? false))
              fuelStateAsync.when(
                data: (state) => _buildMonthSelector(state),
                loading: () => const SizedBox(height: 66),
                error: (_, __) => const SizedBox.shrink(),
              ),

            Expanded(
              child: vehiclesAsync.when(
                data: (vehicles) {
                  if (_selectedVehicleId == null) {
                    return _buildSelectVehicleState();
                  }
                  return fuelStateAsync.when(
                    data: (fuelState) => _buildContent(context, fuelState),
                    loading: () => const StandardLoadingView(
                      message: 'Carregando abastecimentos...',
                      showProgress: true,
                    ),
                    error: (error, stack) => EnhancedEmptyState(
                      title: 'Erro ao carregar',
                      description: error.toString(),
                      icon: Icons.error_outline,
                      actionLabel: 'Tentar novamente',
                      onAction: () {
                        ref
                            .read(fuelRiverpodProvider.notifier)
                            .loadFuelRecords();
                      },
                    ),
                  );
                },
                loading: () => const StandardLoadingView(
                  message: 'Carregando veículos...',
                  showProgress: true,
                ),
                error: (error, _) => EnhancedEmptyState(
                  title: 'Erro ao carregar veículos',
                  description: error.toString(),
                  icon: Icons.error_outline,
                  actionLabel: 'Tentar novamente',
                  onAction: () {
                    ref.read(vehiclesProvider.notifier).refresh();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AdaptiveFloatingActionButton(
        onPressed: _addFuel,
        tooltip: 'Adicionar abastecimento',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Adicionar novo abastecimento
  void _addFuel() {
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um veículo primeiro'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    showDialog<bool>(
      context: context,
      builder: (context) => FuelFormPage(
        vehicleId: _selectedVehicleId,
        initialMode: CrudDialogMode.create,
      ),
    ).then((result) {
      if (result == true) {
        ref.read(fuelRiverpodProvider.notifier).loadFuelRecords();
      }
    });
  }

  Widget _buildOfflineIndicator(
    bool isOnline,
    int pendingCount,
    bool isSyncing,
  ) {
    if (isOnline && pendingCount == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isOnline
            ? Colors.orange.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOnline ? Colors.orange : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.sync : Icons.cloud_off,
            color: isOnline ? Colors.orange : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isOnline
                  ? '$pendingCount ${pendingCount == 1 ? 'registro pendente' : 'registros pendentes'}'
                  : 'Modo offline - Dados serão sincronizados quando voltar online',
              style: TextStyle(
                color: isOnline ? Colors.orange[900] : Colors.red[900],
                fontSize: 13,
              ),
            ),
          ),
          if (isOnline && pendingCount > 0 && !isSyncing)
            TextButton(
              onPressed: () {
                ref.read(fuelRiverpodProvider.notifier).syncPendingRecords();
              },
              child: const Text('Sincronizar'),
            ),
          if (isSyncing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(FuelState fuelState) {
    final vehicleRecords = fuelState.fuelRecords
        .where((r) => r.vehicleId == _selectedVehicleId)
        .toList();

    final months = MonthExtractor.extractMonths(
      vehicleRecords,
      (record) => record.date,
    );

    final selectedMonth = fuelState.selectedMonth;

    // Se não há mês selecionado e há meses disponíveis, seleciona o mês atual (ou o mais recente)
    if (selectedMonth == null && months.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);

        // Verifica se o mês atual existe nos dados
        final hasCurrentMonth = months.any(
          (m) => m.year == currentMonth.year && m.month == currentMonth.month,
        );

        if (hasCurrentMonth) {
          ref.read(fuelRiverpodProvider.notifier).selectMonth(currentMonth);
        } else {
          // Se não tem dados do mês atual, seleciona o mais recente
          ref.read(fuelRiverpodProvider.notifier).selectMonth(months.first);
        }
      });
    }

    return MonthSelector(
      months: months,
      selectedMonth: selectedMonth,
      onMonthSelected: (month) {
        ref.read(fuelRiverpodProvider.notifier).selectMonth(month);
      },
    );
  }

  Widget _buildContent(BuildContext context, FuelState fuelState) {
    if (fuelState.isLoading && !fuelState.isInitialized) {
      return const StandardLoadingView(
        message: 'Carregando abastecimentos...',
        showProgress: true,
      );
    }

    if (fuelState.errorMessage != null && fuelState.filteredRecords.isEmpty) {
      return EnhancedEmptyState(
        title: 'Erro ao carregar',
        description: fuelState.errorMessage!,
        icon: Icons.error_outline,
        actionLabel: 'Tentar novamente',
        onAction: () {
          ref.read(fuelRiverpodProvider.notifier).loadFuelRecords();
        },
      );
    }

    final records = fuelState.filteredRecords;

    // DEBUG: Verificar registros
    if (kDebugMode) {
      debugPrint(
        '🔍 Fuel Page - Total records: ${fuelState.fuelRecords.length}',
      );
      debugPrint('🔍 Fuel Page - Filtered records: ${records.length}');
      debugPrint(
        '🔍 Fuel Page - Selected vehicle: ${fuelState.selectedVehicleId}',
      );
      debugPrint('🔍 Fuel Page - Selected month: ${fuelState.selectedMonth}');
    }

    if (records.isEmpty) {
      return EnhancedEmptyState(
        title: 'Nenhum abastecimento',
        description: fuelState.hasActiveFilters
            ? 'Nenhum registro encontrado com os filtros aplicados.'
            : 'Adicione seu primeiro abastecimento para começar a acompanhar seus gastos com combustível.',
        icon: Icons.local_gas_station_outlined,
      );
    }

    // Layout com estatísticas fixas + lista scrollable
    return Column(
      children: [
        if (_showMonthlyStats) _buildMonthlyStatsPanel(records),
        Expanded(child: _buildFuelRecordsList(records)),
      ],
    );
  }

  Widget _buildFuelRecordsList(List<FuelRecordEntity> records) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(fuelRiverpodProvider.notifier).loadFuelRecords();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return SwipeToDeleteWrapper(
            itemKey: 'fuel_${record.id}',
            deletedMessage: 'Abastecimento excluído',
            onDelete: () async {
              await ref
                  .read(fuelRiverpodProvider.notifier)
                  .deleteOptimistic(record.id);
            },
            onRestore: () async {
              await ref
                  .read(fuelRiverpodProvider.notifier)
                  .restoreDeleted(record.id);
            },
            child: _buildFuelRecordCard(record),
          );
        },
      ),
    );
  }

  Widget _buildFuelRecordCard(FuelRecordEntity record) {
    final date = record.date;
    final day = date.day.toString().padLeft(2, '0');
    final weekday = DateFormat('EEE', 'pt_BR').format(date).toLowerCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _openFuelDetail(record),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Date Section
                SizedBox(
                  width: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              height: 1.0,
                            ),
                      ),
                      Text(
                        weekday,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Divider
                VerticalDivider(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                  thickness: 1,
                  width: 24,
                ),

                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Row 1: Liters & Price/L
                      Row(
                        children: [
                          Icon(
                            Icons.local_gas_station,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${record.liters.toStringAsFixed(1)} L',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'R\$ ${record.pricePerLiter.toStringAsFixed(3)}/L',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Row 2: Odometer
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${record.odometer.toStringAsFixed(0)} km',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (record.fullTank) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ],
                      ),

                      // Row 3: Stats (Distance & Consumption)
                      if (record.distanceTraveled != null &&
                          record.distanceTraveled! > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.route,
                              size: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${record.distanceTraveled!.toStringAsFixed(0)} km',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            if (record.consumption != null &&
                                record.consumption! > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.eco,
                                size: 14,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${record.consumption!.toStringAsFixed(1)} km/l',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.tertiary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Price Section (Right)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${record.totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Abre o detalhe do registro de abastecimento em modo visualização
  void _openFuelDetail(FuelRecordEntity record) {
    showDialog<bool>(
      context: context,
      builder: (context) => FuelFormPage(
        fuelRecordId: record.id,
        vehicleId: record.vehicleId,
        initialMode: CrudDialogMode.view,
      ),
    ).then((result) {
      if (result == true) {
        ref.read(fuelRiverpodProvider.notifier).loadFuelRecords();
      }
    });
  }

  Widget _buildSelectVehicleState() {
    return const EnhancedEmptyState(
      title: 'Selecione um veículo',
      description:
          'Escolha um veículo acima para visualizar seus abastecimentos.',
      icon: Icons.local_gas_station_outlined,
    );
  }

  /// Painel de estatísticas mensais fixo
  Widget _buildMonthlyStatsPanel(List<FuelRecordEntity> records) {
    if (records.isEmpty) return const SizedBox.shrink();

    // Cálculos
    final totalSpent = records.fold<double>(
      0.0,
      (total, r) => total + r.totalPrice,
    );

    final totalLiters = records.fold<double>(
      0.0,
      (total, r) => total + r.liters,
    );

    final avgPricePerLiter = totalLiters > 0 ? totalSpent / totalLiters : 0.0;

    // Km rodados no período (diferença entre maior e menor odômetro)
    final odometers = records.map((r) => r.odometer).toList();
    odometers.sort();
    final kmDriven = odometers.isNotEmpty
        ? (odometers.last - odometers.first)
        : 0.0;

    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Estatísticas do Mês',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grid 2x2 com as estatísticas
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.attach_money,
                  label: 'Total Gasto',
                  value: currencyFormat.format(totalSpent),
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.local_gas_station,
                  label: 'Total Litros',
                  value: '${totalLiters.toStringAsFixed(1)} L',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.trending_up,
                  label: 'Média/Litro',
                  value: currencyFormat.format(avgPricePerLiter),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.route,
                  label: 'Km Rodados',
                  value: '${kmDriven.toStringAsFixed(0)} km',
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
