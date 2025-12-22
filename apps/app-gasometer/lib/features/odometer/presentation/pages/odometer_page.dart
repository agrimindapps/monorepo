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
import '../../domain/entities/odometer_entity.dart';
import '../providers/odometer_notifier.dart';
import '../providers/odometer_state.dart';
import 'odometer_form_page.dart';

class OdometerPage extends ConsumerStatefulWidget {
  const OdometerPage({super.key});

  @override
  ConsumerState<OdometerPage> createState() => _OdometerPageState();
}

class _OdometerPageState extends ConsumerState<OdometerPage> {
  String? _selectedVehicleId;
  bool _showMonthlyStats = false; // Toggle para mostrar/ocultar estatísticas

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final odometerState = ref.watch(odometerProvider);

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          _buildVehicleSelector(context),
          if (_selectedVehicleId != null &&
              (vehiclesAsync.value?.isNotEmpty ?? false))
            _buildMonthSelector(odometerState),
          Expanded(
            child: vehiclesAsync.when(
              data: (vehicles) {
                if (_selectedVehicleId == null) {
                  return _buildSelectVehicleState();
                }
                return _buildContent(context, odometerState);
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
              label: 'Seção de odômetro',
              hint:
                  'Página principal para controlar quilometragem dos veículos',
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.speed, color: Colors.white, size: 19),
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SemanticText.heading(
                    'Odômetro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  SemanticText.subtitle(
                    'Controle da quilometragem dos seus veículos',
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
                .read(odometerProvider.notifier)
                .loadByVehicle(vehicleId);
          }
        },
        hintText: 'Selecione um veículo',
      ),
    );
  }

  Widget _buildMonthSelector(OdometerState state) {
    final vehicleRecords = state.readings;

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
          ref.read(odometerProvider.notifier).selectMonth(currentMonth);
        } else {
          // Se não tem dados do mês atual, seleciona o mais recente
          ref.read(odometerProvider.notifier).selectMonth(months.first);
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
                ref.read(odometerProvider.notifier).selectMonth(month);
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

  Widget _buildContent(BuildContext context, OdometerState state) {
    if (state.isLoading && !state.hasData) {
      return const StandardLoadingView(
        message: 'Carregando leituras...',
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
                .read(odometerProvider.notifier)
                .loadByVehicle(_selectedVehicleId!);
          }
        },
      );
    }

    final records = state.filteredReadings;

    if (records.isEmpty) {
      return EnhancedEmptyState(
        title: 'Nenhum registro',
        description: state.hasActiveFilters
            ? 'Nenhum registro encontrado com os filtros aplicados.'
            : 'Adicione sua primeira leitura de odômetro para começar a acompanhar a quilometragem.',
        icon: Icons.speed_outlined,
      );
    }

    // Layout com estatísticas fixas + lista scrollable
    return Column(
      children: [
        if (_showMonthlyStats)
          _buildMonthlyStatsPanel(records),
        Expanded(
          child: _buildOdometerList(records),
        ),
      ],
    );
  }

  Widget _buildOdometerList(List<OdometerEntity> records) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedVehicleId != null) {
          await ref
              .read(odometerProvider.notifier)
              .loadByVehicle(_selectedVehicleId!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final reading = records[index];
          final formatter = NumberFormat('#,##0.0', 'pt_BR');
          final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

          return SwipeToDeleteWrapper(
            itemKey: 'odometer_${reading.id}',
            deletedMessage: 'Leitura de odômetro excluída',
            onDelete: () async {
              await ref
                  .read(odometerProvider.notifier)
                  .deleteOptimistic(reading.id);
            },
            onRestore: () async {
              await ref
                  .read(odometerProvider.notifier)
                  .restoreDeleted(reading.id);
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _openOdometerDetail(reading),
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
                                reading.registrationDate.day.toString().padLeft(2, '0'),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                      height: 1.0,
                                    ),
                              ),
                              Text(
                                DateFormat('EEE', 'pt_BR').format(reading.registrationDate).toLowerCase(),
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
                              // Row 1: Odometer Value
                              Text(
                                '${formatter.format(reading.value)} km',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Row 2: Description (if any)
                              if (reading.description.isNotEmpty)
                                Text(
                                  reading.description,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              else
                                Text(
                                  'Registro de odômetro',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Type Badge (Right)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                reading.type.displayName,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Abre o detalhe do registro de odômetro em modo visualização
  void _openOdometerDetail(OdometerEntity reading) {
    showDialog<bool>(
      context: context,
      builder: (context) => OdometerFormPage(
        odometerId: reading.id,
        vehicleId: reading.vehicleId,
        initialMode: CrudDialogMode.view,
      ),
    ).then((result) {
      if (result == true && _selectedVehicleId != null) {
        ref.read(odometerProvider.notifier).loadByVehicle(_selectedVehicleId!);
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
          builder: (context) => OdometerFormPage(
            vehicleId: _selectedVehicleId,
            initialMode: CrudDialogMode.create,
          ),
        ).then((result) {
          if (result == true && _selectedVehicleId != null) {
            // Reload odometer list after adding
            ref
                .read(odometerProvider.notifier)
                .loadByVehicle(_selectedVehicleId!);
          }
        });
      },
      backgroundColor: isEnabled ? null : Colors.grey,
      tooltip: 'Adicionar leitura',
      child: const Icon(Icons.add),
    );
  }

  Widget _buildSelectVehicleState() {
    return const EnhancedEmptyState(
      title: 'Selecione um veículo',
      description:
          'Escolha um veículo acima para visualizar suas leituras de odômetro.',
      icon: Icons.speed_outlined,
    );
  }

  List<DateTime> _getMonths(List<OdometerEntity> records) {
    final dates = records.map((e) => e.registrationDate).toList();
    final dateUtils = local_date_utils.DateUtils();
    return dateUtils.generateMonthRange(dates);
  }

  /// Painel de estatísticas mensais fixo - Odômetro
  Widget _buildMonthlyStatsPanel(List<OdometerEntity> records) {
    if (records.isEmpty) return const SizedBox.shrink();

    // Cálculos
    final totalRecords = records.length;
    
    final values = records.map((r) => r.value).toList();
    values.sort();
    
    final minValue = values.isNotEmpty ? values.first : 0.0;
    final maxValue = values.isNotEmpty ? values.last : 0.0;
    final kmTraveled = maxValue - minValue;

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
                  icon: Icons.format_list_numbered,
                  label: 'Total Registros',
                  value: totalRecords.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.route,
                  label: 'Km Percorridos',
                  value: '${kmTraveled.toStringAsFixed(0)} km',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.arrow_upward,
                  label: 'Maior Registro',
                  value: '${maxValue.toStringAsFixed(0)} km',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.arrow_downward,
                  label: 'Menor Registro',
                  value: '${minValue.toStringAsFixed(0)} km',
                  color: Colors.purple,
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
