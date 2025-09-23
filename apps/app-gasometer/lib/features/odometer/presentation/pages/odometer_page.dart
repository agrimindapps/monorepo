import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/enhanced_empty_state.dart';
import '../../../../core/presentation/widgets/standard_card.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/theme/gasometer_colors.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../../shared/widgets/design_system/base/standard_list_item_card.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../domain/entities/odometer_entity.dart';
import '../providers/odometer_form_provider.dart';
import '../providers/odometer_provider.dart';
import 'add_odometer_page.dart';

class OdometerPage extends StatefulWidget {
  const OdometerPage({super.key});

  @override
  State<OdometerPage> createState() => _OdometerPageState();
}

class _OdometerPageState extends State<OdometerPage> {
  String? _selectedVehicleId;
  int _currentMonthIndex = DateTime.now().month - 1; // Initialize to current month
  bool _showStatistics = true;

  // Generate month list dynamically
  List<String> get _months {
    final now = DateTime.now();
    final currentYear = now.year;
    final monthNames = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];

    return monthNames
        .asMap()
        .entries
        .map((entry) => '${entry.value} ${currentYear.toString().substring(2)}')
        .toList();
  }

  // Get odometers from the provider instead of maintaining local state
  List<OdometerEntity> _getOdometers(OdometerProvider provider) {
    List<OdometerEntity> odometers;

    // First filter by vehicle if selected
    if (_selectedVehicleId != null) {
      odometers = provider.getOdometersByVehicle(_selectedVehicleId!);
    } else {
      odometers = provider.odometers;
    }

    // Then filter by selected month
    final selectedMonth = _currentMonthIndex + 1; // Convert index to month (1-12)
    final currentYear = DateTime.now().year;

    return odometers.where((odometer) {
      return odometer.registrationDate.month == selectedMonth &&
             odometer.registrationDate.year == currentYear;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadOdometerData();
    });
  }

  void _loadOdometerData() {
    if (_selectedVehicleId != null && _selectedVehicleId!.isNotEmpty) {
      Provider.of<OdometerProvider>(context, listen: false)
          .loadOdometersByVehicle(_selectedVehicleId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<OdometerProvider>(
          builder: (context, odometerProvider, child) {
            final odometers = _getOdometers(odometerProvider);
            return Column(
              children: [
                _buildHeader(),
                _buildControls(odometers),
                _buildMonthsBar(),
                Expanded(child: _buildContent(odometers)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: GasometerDesignTokens.colorHeaderBackground,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: GasometerDesignTokens.colorHeaderBackground
                  .withValues(alpha: 0.2),
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
              child: const Icon(
                Icons.speed,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Odômetro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3),
                  Text(
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

  Widget _buildControls(List<OdometerEntity> odometers) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              maxWidth: GasometerDesignTokens.maxWidthContent),
          child: EnhancedVehicleSelector(
            selectedVehicleId: _selectedVehicleId,
            onVehicleChanged: (String? vehicleId) {
              setState(() {
                _selectedVehicleId = vehicleId;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMonthsBar() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentMonthIndex;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _currentMonthIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _months[index],
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
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

  Widget _buildContent(List<OdometerEntity> odometers) {
    if (_selectedVehicleId == null) {
      return _buildNoVehicleSelected();
    }

    // Se não há registros de odômetro, mostrar empty state
    if (odometers.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              maxWidth: GasometerDesignTokens.maxWidthContent),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (_showStatistics && odometers.isNotEmpty) ...[
                  _buildStatisticsCard(odometers),
                  SizedBox(height: GasometerDesignTokens.spacingLg),
                ],
                _buildOdometerList(odometers),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoVehicleSelected() {
    return Center(
      child: EnhancedEmptyState.generic(
        icon: Icons.directions_car_outlined,
        title: 'Selecione um veículo',
        description:
            'Escolha um veículo para visualizar os registros de odômetro',
        height: MediaQuery.of(context).size.height * 0.6,
      ),
    );
  }

  Widget _buildStatisticsCard(List<OdometerEntity> odometers) {
    // Calcular estatísticas reais baseadas nos registros
    final statistics = _calculateStatistics(odometers);

    return StandardCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardSectionTitle(
            title: 'Estatísticas do Mês',
            icon: Icons.assessment,
          ),
          SizedBox(height: GasometerDesignTokens.spacingXl),
          Row(
            children: [
              Expanded(
                  child: _buildStatisticItem('Km Inicial',
                      statistics['kmInicial'] ?? '-', Icons.trip_origin)),
              Expanded(
                  child: _buildStatisticItem(
                      'Km Final', statistics['kmFinal'] ?? '-', Icons.flag)),
              Expanded(
                  child: _buildStatisticItem('Total Rodado',
                      statistics['totalRodado'] ?? '-', Icons.trending_up)),
              Expanded(
                  child: _buildStatisticItem('Média/Dia',
                      statistics['mediaDia'] ?? '-', Icons.timeline)),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, String> _calculateStatistics(List<OdometerEntity> odometers) {
    if (odometers.isEmpty) {
      return {
        'kmInicial': '-',
        'kmFinal': '-',
        'totalRodado': '-',
        'mediaDia': '-',
      };
    }

    // Ordenar por data para calcular estatísticas do mês atual
    final sortedOdometers = List<OdometerEntity>.from(odometers);
    sortedOdometers
        .sort((a, b) => a.registrationDate.compareTo(b.registrationDate));

    // Filtrar registros do mês atual
    final now = DateTime.now();
    final currentMonthOdometers = sortedOdometers
        .where((o) =>
            o.registrationDate.year == now.year &&
            o.registrationDate.month == now.month)
        .toList();

    if (currentMonthOdometers.isEmpty) {
      return {
        'kmInicial': '-',
        'kmFinal': '-',
        'totalRodado': '-',
        'mediaDia': '-',
      };
    }

    final kmInicial = currentMonthOdometers.first.value;
    final kmFinal = currentMonthOdometers.last.value;
    final totalRodado = kmFinal - kmInicial;
    final diasNoMes = currentMonthOdometers.last.registrationDate
        .difference(currentMonthOdometers.first.registrationDate)
        .inDays;
    final mediaDia = diasNoMes > 0 ? totalRodado / diasNoMes : 0.0;

    return {
      'kmInicial': kmInicial.toStringAsFixed(1).replaceAll('.', ','),
      'kmFinal': kmFinal.toStringAsFixed(1).replaceAll('.', ','),
      'totalRodado': totalRodado.toStringAsFixed(1).replaceAll('.', ','),
      'mediaDia': mediaDia.toStringAsFixed(1).replaceAll('.', ','),
    };
  }

  Widget _buildStatisticItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: GasometerDesignTokens.paddingAll(
            GasometerDesignTokens.spacingMd,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusLg,
            ),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: GasometerDesignTokens.iconSizeListItem,
          ),
        ),
        SizedBox(height: GasometerDesignTokens.spacingSm),
        Text(
          value,
          style: TextStyle(
            fontSize: GasometerDesignTokens.fontSizeLg,
            fontWeight: GasometerDesignTokens.fontWeightBold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: GasometerDesignTokens.fontSizeSm,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: GasometerDesignTokens.opacitySecondary),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOdometerList(List<OdometerEntity> odometers) {
    if (odometers.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children:
          odometers.map((odometer) => _buildOdometerItem(odometer)).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: EnhancedEmptyState.generic(
        icon: Icons.speed_outlined,
        title: 'Nenhum registro encontrado',
        description: 'Não há registros de odômetro para este período',
        height: MediaQuery.of(context).size.height * 0.4,
      ),
    );
  }

  Widget _buildOdometerItem(OdometerEntity odometer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      child: StandardListItemCard.odometer(
        date: odometer.registrationDate,
        odometer: odometer.value,
        location: odometer.description.isNotEmpty ? odometer.description : null,
        onTap: () => _editOdometer(odometer),
        actionWidget: Icon(
          Icons.chevron_right,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: GasometerDesignTokens.opacityHint),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final hasSelectedVehicle = _selectedVehicleId != null;

    return FloatingActionButton(
      onPressed: hasSelectedVehicle ? _addOdometer : _showSelectVehicleMessage,
      backgroundColor: hasSelectedVehicle
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).disabledColor,
      foregroundColor: hasSelectedVehicle
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tooltip: hasSelectedVehicle
          ? 'Adicionar registro de odômetro'
          : 'Selecione um veículo primeiro',
      child: const Icon(Icons.add),
    );
  }

  void _showSelectVehicleMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Selecione um veículo primeiro'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(
            GasometerDesignTokens.radiusInput,
          ),
        ),
      ),
    );
  }


  void _addOdometer() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OdometerFormProvider()),
          ChangeNotifierProvider.value(
              value: Provider.of<VehiclesProvider>(context, listen: false)),
        ],
        builder: (context, child) =>
            AddOdometerPage(vehicleId: _selectedVehicleId),
      ),
    );

    if (result != null && mounted) {
      // Refresh data from provider instead of managing local state
      _loadOdometerData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registro cadastrado com sucesso'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusInput,
            ),
          ),
        ),
      );
    }
  }

  void _editOdometer(OdometerEntity odometer) async {
    Map<String, dynamic>? result;
    try {
      result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => OdometerFormProvider()),
            ChangeNotifierProvider.value(
                value: Provider.of<VehiclesProvider>(context, listen: false)),
          ],
          builder: (context, child) => AddOdometerPage(odometer: odometer),
        ),
      );
    } catch (e) {
      // Tratamento de erro adequado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir editor: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      debugPrint('Error editing odometer: $e');
      return;
    }

    if (result != null && mounted) {
      // Refresh data from provider instead of managing local state
      _loadOdometerData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registro editado com sucesso'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusInput,
            ),
          ),
        ),
      );
    }
  }
}
