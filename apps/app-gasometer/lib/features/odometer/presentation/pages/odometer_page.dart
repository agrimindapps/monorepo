import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/date_utils.dart' as local_date_utils;
import '../../../../core/widgets/enhanced_empty_state.dart';
import '../../../../core/widgets/semantic_widgets.dart';
import '../../../../core/widgets/standard_loading_view.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../vehicles/presentation/providers/vehicles_notifier.dart';
import '../../domain/entities/odometer_entity.dart';
import '../providers/odometer_notifier.dart';
import '../providers/odometer_state.dart';
import 'add_odometer_page.dart';

class OdometerPage extends ConsumerStatefulWidget {
  const OdometerPage({super.key});

  @override
  ConsumerState<OdometerPage> createState() => _OdometerPageState();
}

class _OdometerPageState extends ConsumerState<OdometerPage> {
  String? _selectedVehicleId;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    final odometerState = ref.watch(odometerNotifierProvider);

    return Scaffold(
      body: SafeArea(
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
                .read(odometerNotifierProvider.notifier)
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
                ref.read(odometerNotifierProvider.notifier).clearMonthFilter();
              } else {
                ref.read(odometerNotifierProvider.notifier).selectMonth(month);
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
                .read(odometerNotifierProvider.notifier)
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
        actionLabel: state.hasActiveFilters ? 'Limpar filtros' : null,
        onAction: state.hasActiveFilters
            ? () =>
                ref.read(odometerNotifierProvider.notifier).clearMonthFilter()
            : null,
      );
    }

    return _buildOdometerList(records);
  }

  Widget _buildOdometerList(List<OdometerEntity> records) {
    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedVehicleId != null) {
          await ref
              .read(odometerNotifierProvider.notifier)
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

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.speed, color: Colors.white),
              ),
              title: Text(
                '${formatter.format(reading.value)} km',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateFormatter.format(reading.registrationDate)),
                  if (reading.description.isNotEmpty)
                    Text(
                      reading.description,
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
              trailing: Text(
                reading.type.displayName,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
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
          builder: (context) => AddOdometerPage(vehicleId: _selectedVehicleId),
        ).then((result) {
          if (result == true && _selectedVehicleId != null) {
            // Reload odometer list after adding
            ref
                .read(odometerNotifierProvider.notifier)
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
    final dateUtils =
        ModularInjectionContainer.instance<local_date_utils.DateUtils>();
    return dateUtils.generateMonthRange(dates);
  }
}
