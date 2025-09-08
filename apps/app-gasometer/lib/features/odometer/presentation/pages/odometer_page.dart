import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/enhanced_empty_state.dart';
import '../../../../core/presentation/widgets/standard_card.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
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
  int _currentMonthIndex = 0;
  bool _showStatistics = true;

  final List<String> _months = [
    'Jan 25',
    'Fev 25',
    'Mar 25',
    'Abr 25',
    'Mai 25',
    'Jun 25',
    'Jul 25',
    'Ago 25',
  ];

  // Get odometers from the provider instead of maintaining local state
  List<OdometerEntity> get _odometers {
    final provider = Provider.of<OdometerProvider>(context, listen: false);
    if (_selectedVehicleId != null) {
      return provider.getOdometersByVehicle(_selectedVehicleId!);
    }
    return provider.odometers;
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Consumer<OdometerProvider>(
          builder: (context, odometerProvider, child) {
            return Column(
              children: [
                _buildHeader(),
                _buildControls(),
                Expanded(child: _buildContent()),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: GasometerDesignTokens.colorHeaderBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: GasometerDesignTokens.colorHeaderBackground.withValues(alpha: 0.2),
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
    );
  }

  Widget _buildControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GasometerDesignTokens.maxWidthContent),
          child: Column(
            children: [
              EnhancedVehicleSelector(
                selectedVehicleId: _selectedVehicleId,
                onVehicleChanged: (String? vehicleId) {
                  setState(() {
                    _selectedVehicleId = vehicleId;
                  });
                },
              ),
              if (_selectedVehicleId != null) ...[
                SizedBox(height: GasometerDesignTokens.spacingLg),
                _buildMonthsBar(),
              ],
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMonthsBar() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentMonthIndex;
          return GestureDetector(
            onTap: () => setState(() => _currentMonthIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Text(
                _months[index],
                style: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedVehicleId == null) {
      return _buildNoVehicleSelected();
    }

    // Se não há registros de odômetro, mostrar empty state
    if (_odometers.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GasometerDesignTokens.maxWidthContent),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (_showStatistics && _odometers.isNotEmpty) ...[
                  _buildStatisticsCard(),
                  SizedBox(height: GasometerDesignTokens.spacingLg),
                ],
                _buildOdometerList(),
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
        description: 'Escolha um veículo para visualizar os registros de odômetro',
        height: MediaQuery.of(context).size.height * 0.6,
      ),
    );
  }

  Widget _buildStatisticsCard() {
    // Calcular estatísticas reais baseadas nos registros
    final statistics = _calculateStatistics();
    
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
              Expanded(child: _buildStatisticItem('Km Inicial', statistics['kmInicial'] ?? '-', Icons.trip_origin)),
              Expanded(child: _buildStatisticItem('Km Final', statistics['kmFinal'] ?? '-', Icons.flag)),
              Expanded(child: _buildStatisticItem('Total Rodado', statistics['totalRodado'] ?? '-', Icons.trending_up)),
              Expanded(child: _buildStatisticItem('Média/Dia', statistics['mediaDia'] ?? '-', Icons.timeline)),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, String> _calculateStatistics() {
    if (_odometers.isEmpty) {
      return {
        'kmInicial': '-',
        'kmFinal': '-', 
        'totalRodado': '-',
        'mediaDia': '-',
      };
    }

    // Ordenar por data para calcular estatísticas do mês atual
    final sortedOdometers = List<OdometerEntity>.from(_odometers);
    sortedOdometers.sort((a, b) => a.registrationDate.compareTo(b.registrationDate));

    // Filtrar registros do mês atual
    final now = DateTime.now();
    final currentMonthOdometers = sortedOdometers.where((o) => 
      o.registrationDate.year == now.year && o.registrationDate.month == now.month
    ).toList();

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
    final diasNoMes = currentMonthOdometers.last.registrationDate.difference(currentMonthOdometers.first.registrationDate).inDays;
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOdometerList() {
    if (_odometers.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _odometers.map((odometer) => _buildOdometerItem(odometer)).toList(),
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
    final date = odometer.registrationDate;
    final dayOfMonth = date.day.toString().padLeft(2, '0');
    final weekday = _getWeekdayName(date.weekday);

    return StandardCard.standard(
      margin: const EdgeInsets.only(bottom: 4.0),
      onTap: () => _editOdometer(odometer),
      child: Row(
        children: [
          // Data
          Column(
            children: [
              Text(
                weekday,
                style: TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeSm,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
                  fontWeight: GasometerDesignTokens.fontWeightMedium,
                ),
              ),
              SizedBox(height: GasometerDesignTokens.spacingXs),
              Text(
                dayOfMonth,
                style: TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeXxxl,
                  fontWeight: GasometerDesignTokens.fontWeightBold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(width: GasometerDesignTokens.spacingLg),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          SizedBox(width: GasometerDesignTokens.spacingLg),
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardInfoRow(
                  icon: Icons.speed,
                  label: 'Odômetro',
                  value: '${odometer.value.toStringAsFixed(1)} km',
                  iconColor: Theme.of(context).colorScheme.primary,
                ),
                if (odometer.description.isNotEmpty) ...[
                  SizedBox(height: GasometerDesignTokens.spacingSm),
                  Text(
                    odometer.description,
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeSm,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacitySecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(GasometerDesignTokens.opacityHint),
          ),
        ],
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

  String _getWeekdayName(int weekday) {
    const weekdays = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];
    return weekdays[weekday - 1];
  }

  void _addOdometer() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OdometerFormProvider()),
          ChangeNotifierProvider.value(value: Provider.of<VehiclesProvider>(context, listen: false)),
        ],
        builder: (context, child) => AddOdometerPage(vehicleId: _selectedVehicleId),
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
            ChangeNotifierProvider.value(value: Provider.of<VehiclesProvider>(context, listen: false)),
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