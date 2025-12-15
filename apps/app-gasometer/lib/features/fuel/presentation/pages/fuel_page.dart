import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_utils.dart' as local_date_utils;
import '../../../../core/widgets/crud_form_dialog.dart';
import '../../../../core/widgets/enhanced_empty_state.dart';
import '../../../../core/widgets/semantic_widgets.dart';
import '../../../../core/widgets/standard_loading_view.dart';
import '../../../../core/widgets/swipe_to_delete_wrapper.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
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
                    ref.read(vehiclesProvider.notifier).refresh();
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
            // Botão de toggle para estatísticas mensais
            IconButton(
              icon: Icon(
                _showMonthlyStats ? Icons.analytics : Icons.analytics_outlined,
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

    // Se não há mês selecionado e há meses disponíveis, seleciona o mês atual (ou o mais recente)
    if (selectedMonth == null && months.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);
        
        // Verifica se o mês atual existe nos dados
        final hasCurrentMonth = months.any((m) => 
          m.year == currentMonth.year && m.month == currentMonth.month);
        
        if (hasCurrentMonth) {
          ref.read(fuelRiverpodProvider.notifier).selectMonth(currentMonth);
        } else {
          // Se não tem dados do mês atual, seleciona o mais recente
          ref.read(fuelRiverpodProvider.notifier).selectMonth(months.first);
        }
      });
    }

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
              // Sempre permite selecionar, nunca desmarca
              if (!isSelected) {
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
      );
    }

    // Layout com estatísticas fixas + lista scrollable
    return Column(
      children: [
        if (_showMonthlyStats)
          _buildMonthlyStatsPanel(records),
        Expanded(
          child: _buildFuelRecordsList(records),
        ),
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
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
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
                            color: Theme.of(context).colorScheme.onSurfaceVariant
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${record.liters.toStringAsFixed(1)} L',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: Theme.of(context).disabledColor),
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
                            color: Theme.of(context).colorScheme.onSurfaceVariant
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
                              color: Theme.of(context).primaryColor
                            ),
                          ],
                        ],
                      ),

                      // Row 3: Stats (Distance & Consumption)
                      if (record.distanceTraveled != null && record.distanceTraveled! > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.route, 
                              size: 14, 
                              color: Theme.of(context).colorScheme.secondary
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${record.distanceTraveled!.toStringAsFixed(0)} km',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (record.consumption != null && record.consumption! > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: TextStyle(color: Theme.of(context).disabledColor),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.eco, 
                                size: 14, 
                                color: Colors.green
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${record.consumption!.toStringAsFixed(1)} km/l',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
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
                            color: Theme.of(context).primaryColor,
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

  Widget _buildFloatingActionButton(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
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
          builder: (context) => FuelFormPage(
            vehicleId: _selectedVehicleId,
            initialMode: CrudDialogMode.create,
          ),
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

  /// Painel de estatísticas mensais fixo
  Widget _buildMonthlyStatsPanel(List<FuelRecordEntity> records) {
    if (records.isEmpty) return const SizedBox.shrink();

    // Cálculos
    final totalSpent = records.fold<double>(
      0.0, 
      (sum, r) => sum + r.totalPrice,
    );
    
    final totalLiters = records.fold<double>(
      0.0, 
      (sum, r) => sum + r.liters,
    );
    
    final avgPricePerLiter = totalLiters > 0 
      ? totalSpent / totalLiters 
      : 0.0;
    
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
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
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
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Estatísticas do Mês',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grid 2x2 com as estatísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.attach_money,
                  label: 'Total Gasto',
                  value: currencyFormat.format(totalSpent),
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_gas_station,
                  label: 'Total Litros',
                  value: '${totalLiters.toStringAsFixed(1)} L',
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
                  icon: Icons.trending_up,
                  label: 'Média/Litro',
                  value: currencyFormat.format(avgPricePerLiter),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.route,
                  label: 'Km Rodados',
                  value: '${kmDriven.toStringAsFixed(0)} km',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card individual de estatística
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
