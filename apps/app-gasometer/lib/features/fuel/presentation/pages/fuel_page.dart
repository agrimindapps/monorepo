import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart' as local_date_utils;
import '../../../../core/widgets/enhanced_empty_state.dart';
import '../../../../core/widgets/semantic_widgets.dart';
import '../../../../core/widgets/standard_loading_view.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';
import '../../domain/entities/fuel_record_entity.dart';
import '../providers/fuel_riverpod_notifier.dart';
import 'add_fuel_page.dart';

class FuelPage extends ConsumerStatefulWidget {
  const FuelPage({super.key});

  @override
  ConsumerState<FuelPage> createState() => _FuelPageState();
}

class _FuelPageState extends ConsumerState<FuelPage> {
  String? _selectedVehicleId;

  @override
  Widget build(BuildContext context) {
    final fuelStateAsync = ref.watch(fuelRiverpodProvider);
    final isOnline = ref.watch(fuelIsOnlineProvider);
    final pendingCount = ref.watch(fuelPendingCountProvider);
    final isSyncing = ref.watch(fuelIsSyncingProvider);
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (!isOnline || pendingCount > 0)
              _buildOfflineIndicator(isOnline, pendingCount, isSyncing),
            _buildVehicleSelector(context),
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
                    ref.read(vehiclesNotifierProvider.notifier).refresh();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
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
              label: 'Seção de abastecimentos',
              hint: 'Página principal para gerenciar abastecimentos',
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.local_gas_station,
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
                    'Abastecimentos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Histórico de abastecimentos dos seus veículos',
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
          // Filtrar abastecimentos por veículo
          if (vehicleId != null) {
            ref.read(fuelRiverpodProvider.notifier).filterByVehicle(vehicleId);
          } else {
            ref.read(fuelRiverpodProvider.notifier).clearVehicleFilter();
          }
        },
        hintText: 'Selecione um veículo',
      ),
    );
  }

  Widget _buildMonthSelector(FuelState fuelState) {
    final vehicleRecords = fuelState.fuelRecords
        .where((r) => r.vehicleId == _selectedVehicleId)
        .toList();

    final months = _getMonths(vehicleRecords);
    final selectedMonth = fuelState.selectedMonth;

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = selectedMonth != null &&
              month.year == selectedMonth.year &&
              month.month == selectedMonth.month;

          final monthName = DateFormat('MMM yy', 'pt_BR').format(month);
          final formattedMonth =
              monthName[0].toUpperCase() + monthName.substring(1);

          return GestureDetector(
            onTap: () {
              if (isSelected) {
                ref.read(fuelRiverpodProvider.notifier).clearMonthFilter();
              } else {
                ref.read(fuelRiverpodProvider.notifier).selectMonth(month);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  formattedMonth,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
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

    if (records.isEmpty) {
      return EnhancedEmptyState(
        title: 'Nenhum abastecimento',
        description: fuelState.hasActiveFilters
            ? 'Nenhum registro encontrado com os filtros aplicados.'
            : 'Adicione seu primeiro abastecimento para começar a acompanhar seus gastos com combustível.',
        icon: Icons.local_gas_station_outlined,
        actionLabel: fuelState.hasActiveFilters ? 'Limpar filtros' : null,
        onAction: fuelState.hasActiveFilters
            ? () => ref.read(fuelRiverpodProvider.notifier).clearAllFilters()
            : null,
      );
    }

    return _buildFuelRecordsList(records);
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
          return _buildFuelRecordCard(record);
        },
      ),
    );
  }

  Widget _buildFuelRecordCard(FuelRecordEntity record) {
    final date = record.date;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'R\$ ${record.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.local_gas_station,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  '${record.liters.toStringAsFixed(1)} L',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  'R\$ ${record.pricePerLiter.toStringAsFixed(3)}/L',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (record.fullTank) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tanque cheio',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final hasVehicles = vehiclesAsync.value?.isNotEmpty ?? false;
    final isEnabled = hasVehicles && _selectedVehicleId != null;

    return FloatingActionButton(
      onPressed: () {
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
          builder: (context) => AddFuelPage(vehicleId: _selectedVehicleId),
        ).then((result) {
          if (result == true) {
            ref.read(fuelRiverpodProvider.notifier).loadFuelRecords();
          }
        });
      },
      backgroundColor: isEnabled ? null : Colors.grey,
      tooltip: 'Adicionar abastecimento',
      child: const Icon(Icons.add),
    );
  }

  Widget _buildSelectVehicleState() {
    return const EnhancedEmptyState(
      title: 'Selecione um veículo',
      description:
          'Escolha um veículo acima para visualizar seus abastecimentos.',
      icon: Icons.local_gas_station_outlined,
    );
  }

  List<DateTime> _getMonths(List<FuelRecordEntity> records) {
    final dates = records.map((e) => e.date).toList();
    final dateUtils = local_date_utils.DateUtils();
    return dateUtils.generateMonthRange(dates);
  }
}
