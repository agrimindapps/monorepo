import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_utils.dart' as local_date_utils;
import '../../../../core/widgets/crud_form_dialog.dart';
import '../../../../core/widgets/enhanced_empty_state.dart';
import '../../../../core/widgets/responsive_content_area.dart';
import '../../../../core/widgets/semantic_widgets.dart';
import '../../../../core/widgets/standard_loading_view.dart';
import '../../../../core/widgets/swipe_to_delete_wrapper.dart';
import '../../../../shared/widgets/adaptive_main_navigation.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../notifiers/maintenances_notifier.dart';
import '../notifiers/maintenances_state.dart';
import 'add_maintenance_page.dart';

class MaintenancePage extends ConsumerStatefulWidget {
  const MaintenancePage({super.key});

  @override
  ConsumerState<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends ConsumerState<MaintenancePage> {
  String? _selectedVehicleId;
  bool _showMonthlyStats = false; // Toggle para mostrar/ocultar estatísticas

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final maintenanceState = ref.watch(maintenancesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header (sempre visível - mobile e desktop)
            _buildHeader(context),

            Expanded(
              child: ResponsiveContentArea(
                child: Column(
                  children: [
                    _buildVehicleSelector(context),

                    if (_selectedVehicleId != null &&
                        (vehiclesAsync.value?.isNotEmpty ?? false))
                      _buildMonthSelector(maintenanceState),

                    Expanded(
                      child: vehiclesAsync.when(
                        data: (vehicles) {
                          if (_selectedVehicleId == null) {
                            return _buildSelectVehicleState();
                          }
                          return _buildContent(context, maintenanceState);
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
            ),
          ],
        ),
      ),
      floatingActionButton: AdaptiveFloatingActionButton(
        onPressed: _addMaintenance,
        tooltip: 'Adicionar manutenção',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Adicionar nova manutenção
  void _addMaintenance() {
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
      builder: (context) => AddMaintenancePage(vehicleId: _selectedVehicleId!),
    ).then((result) {
      if (result == true) {
        ref.read(maintenancesProvider.notifier).loadMaintenances();
      }
    });
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
            // Botão de voltar
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
              tooltip: 'Voltar',
            ),
            const SizedBox(width: 4),
            Semantics(
              label: 'Seção de manutenções',
              hint: 'Página principal para gerenciar manutenções',
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.build, color: Colors.white, size: 19),
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Manutenções',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Histórico de manutenções dos seus veículos',
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
          if (vehicleId != null) {
            ref
                .read(maintenancesProvider.notifier)
                .loadMaintenancesByVehicle(vehicleId);
          }
        },
        hintText: 'Selecione um veículo',
      ),
    );
  }

  Widget _buildMonthSelector(MaintenancesState state) {
    final vehicleRecords = state.maintenances
        .where((r) => r.vehicleId == _selectedVehicleId)
        .toList();

    final months = _getMonths(vehicleRecords);
    final selectedMonth = state.selectedMonth;

    // Se não há mês selecionado e há meses disponíveis, seleciona o mês atual (ou o mais recente)
    if (selectedMonth == null && months.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);
        
        // Verifica se o mês atual existe nos dados
        final hasCurrentMonth = months.any((m) => 
          m.year == currentMonth.year && m.month == currentMonth.month);
        
        if (hasCurrentMonth) {
          ref.read(maintenancesProvider.notifier).selectMonth(currentMonth);
        } else {
          // Se não tem dados do mês atual, seleciona o mais recente
          ref.read(maintenancesProvider.notifier).selectMonth(months.first);
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
                ref
                    .read(maintenancesProvider.notifier)
                    .selectMonth(month);
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

  Widget _buildContent(BuildContext context, MaintenancesState state) {
    if (state.isLoading && !state.hasData) {
      return const StandardLoadingView(
        message: 'Carregando manutenções...',
        showProgress: true,
      );
    }

    if (state.errorMessage != null && !state.hasData) {
      return EnhancedEmptyState(
        title: 'Erro ao carregar',
        description: state.errorMessage!,
        icon: Icons.error_outline,
        actionLabel: 'Tentar novamente',
        onAction: () {
          if (_selectedVehicleId != null) {
            ref
                .read(maintenancesProvider.notifier)
                .loadMaintenancesByVehicle(_selectedVehicleId!);
          }
        },
      );
    }

    final records = state.filteredMaintenances;

    if (records.isEmpty) {
      return EnhancedEmptyState(
        title: 'Nenhuma manutenção',
        description: state.hasActiveFilters
            ? 'Nenhum registro encontrado com os filtros aplicados.'
            : 'Adicione sua primeira manutenção para começar a acompanhar o histórico de manutenções.',
        icon: Icons.build_outlined,
      );
    }

    // Layout com estatísticas fixas + lista scrollable
    return Column(
      children: [
        if (_showMonthlyStats)
          _buildMonthlyStatsPanel(records),
        Expanded(
          child: _buildMaintenanceList(records),
        ),
      ],
    );
  }

  Widget _buildMaintenanceList(List<MaintenanceEntity> records) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedVehicleId != null) {
          await ref
              .read(maintenancesProvider.notifier)
              .loadMaintenancesByVehicle(_selectedVehicleId!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return SwipeToDeleteWrapper(
            itemKey: 'maintenance_${record.id}',
            deletedMessage: 'Manutenção excluída',
            onDelete: () async {
              await ref
                  .read(maintenancesProvider.notifier)
                  .deleteOptimistic(record.id);
            },
            onRestore: () async {
              await ref
                  .read(maintenancesProvider.notifier)
                  .restoreDeleted(record.id);
            },
            child: _buildMaintenanceCard(record),
          );
        },
      ),
    );
  }

  Widget _buildMaintenanceCard(MaintenanceEntity record) {
    final date = record.serviceDate;
    final day = date.day.toString().padLeft(2, '0');
    final weekday = DateFormat('EEE', 'pt_BR').format(date).toLowerCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _openMaintenanceDetail(record),
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
                      // Row 1: Title
                      Text(
                        record.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Row 2: Badges (Type & Status)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(record.type.colorValue).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Color(record.type.colorValue).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              record.type.displayName,
                              style: TextStyle(
                                color: Color(record.type.colorValue),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(record.status.colorValue).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Color(record.status.colorValue).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              record.status.displayName,
                              style: TextStyle(
                                color: Color(record.status.colorValue),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      
                      // Row 3: Odometer
                      if (record.odometer > 0)
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
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Price Section (Right)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${record.cost.toStringAsFixed(2)}',
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

  /// Abre o detalhe da manutenção em modo visualização
  void _openMaintenanceDetail(MaintenanceEntity record) {
    showDialog<bool>(
      context: context,
      builder: (context) => AddMaintenancePage(
        maintenanceId: record.id,
        vehicleId: record.vehicleId,
        initialMode: CrudDialogMode.view,
      ),
    ).then((result) {
      if (result == true && _selectedVehicleId != null) {
        ref
            .read(maintenancesProvider.notifier)
            .loadMaintenancesByVehicle(_selectedVehicleId!);
      }
    });
  }

  Widget _buildSelectVehicleState() {
    return const EnhancedEmptyState(
      title: 'Selecione um veículo',
      description: 'Escolha um veículo acima para visualizar suas manutenções.',
      icon: Icons.build_outlined,
    );
  }

  List<DateTime> _getMonths(List<MaintenanceEntity> records) {
    final dates = records.map((e) => e.serviceDate).toList();
    final dateUtils = local_date_utils.DateUtils();
    return dateUtils.generateMonthRange(dates);
  }

  /// Painel de estatísticas mensais fixo - Manutenções
  Widget _buildMonthlyStatsPanel(List<MaintenanceEntity> records) {
    if (records.isEmpty) return const SizedBox.shrink();

    // Cálculos
    final totalSpent = records.fold<double>(0.0, (sum, r) => sum + r.cost);
    
    final costs = records.map((r) => r.cost).toList();
    costs.sort();
    
    final avgCost = totalSpent / records.length;
    final maxCost = costs.isNotEmpty ? costs.last : 0.0;
    final totalServices = records.length;

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
                  context: context,
                  icon: Icons.attach_money,
                  label: 'Total Gasto',
                  value: currencyFormat.format(totalSpent),
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: Icons.show_chart,
                  label: 'Média/Manutenção',
                  value: currencyFormat.format(avgCost),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: Icons.arrow_upward,
                  label: 'Maior Custo',
                  value: currencyFormat.format(maxCost),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: Icons.build_circle,
                  label: 'Total Serviços',
                  value: totalServices.toString(),
                  color: Theme.of(context).colorScheme.tertiary,
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
