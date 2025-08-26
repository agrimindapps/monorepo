import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/enhanced_empty_state.dart';
import '../../../../core/presentation/widgets/standard_card.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../domain/entities/odometer_entity.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOdometerData();
    });
  }

  void _loadOdometerData() {
    if (_selectedVehicleId != null && _selectedVehicleId!.isNotEmpty) {
      Provider.of<OdometerProvider>(context, listen: false)
          .loadOdometerReadings(_selectedVehicleId!);
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
                Expanded(child: _buildContent(odometerProvider)),
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
      padding: const EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.speed,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Odômetro',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Controle da quilometragem dos seus veículos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
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

  Widget _buildControls() {
    return Container(
      width: double.infinity,
      padding: GasometerDesignTokens.paddingAll(
        GasometerDesignTokens.spacingPagePadding,
      ),
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
                  color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GasometerDesignTokens.maxWidthContent),
          child: Padding(
            padding: GasometerDesignTokens.paddingAll(
              GasometerDesignTokens.spacingPagePadding,
            ),
            child: Column(
              children: [
                if (_showStatistics) ...[
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
    return EnhancedEmptyState.generic(
      icon: Icons.directions_car_outlined,
      title: 'Selecione um veículo',
      description: 'Escolha um veículo para visualizar os registros de odômetro',
      height: 350,
    );
  }

  Widget _buildStatisticsCard() {
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
              Expanded(child: _buildStatisticItem('Km Inicial', '25.169,4', Icons.trip_origin)),
              Expanded(child: _buildStatisticItem('Km Final', '25.420,5', Icons.flag)),
              Expanded(child: _buildStatisticItem('Total Rodado', '251,1', Icons.trending_up)),
              Expanded(child: _buildStatisticItem('Média/Dia', '16,7', Icons.timeline)),
            ],
          ),
        ],
      ),
    );
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
            color: Theme.of(context).colorScheme.onSurface.withValues(
              alpha: GasometerDesignTokens.opacitySecondary,
            ),
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
    return EnhancedEmptyState.generic(
      icon: Icons.speed_outlined,
      title: 'Nenhum registro encontrado',
      description: 'Não há registros de odômetro para este período',
      height: 300,
    );
  }

  Widget _buildOdometerItem(Map<String, dynamic> odometer) {
    final date = odometer['date'] as DateTime;
    final dayOfMonth = date.day.toString().padLeft(2, '0');
    final weekday = _getWeekdayName(date.weekday);

    return StandardCard.standard(
      margin: EdgeInsets.only(bottom: GasometerDesignTokens.spacingMd),
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: GasometerDesignTokens.opacitySecondary,
                  ),
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
                  value: '${odometer['odometer'].toStringAsFixed(1)} km',
                  iconColor: Theme.of(context).colorScheme.primary,
                ),
                if ((odometer['difference'] as num? ?? 0) > 0)
                  CardInfoRow(
                    icon: Icons.trending_up,
                    label: 'Diferença',
                    value: '${odometer['difference'].toStringAsFixed(1)} km',
                  ),
                if ((odometer['description'] as String? ?? '').isNotEmpty) ...[
                  SizedBox(height: GasometerDesignTokens.spacingSm),
                  Text(
                    odometer['description'] as String? ?? '',
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeSm,
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: GasometerDesignTokens.opacitySecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(
              alpha: GasometerDesignTokens.opacityHint,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFloatingActionButton() {
    final hasSelectedVehicle = _selectedVehicleId != null;
    
    return FloatingActionButton(
      onPressed: hasSelectedVehicle ? _addOdometer : _showSelectVehicleMessage,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
      builder: (context) => const AddOdometerPage(),
    );
    
    if (result != null && mounted) {
      setState(() {
        _odometers.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch,
          ...result,
        });
      });
      
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

  void _editOdometer(Map<String, dynamic> odometer) async {
    try {
      // Usar provider para converter e validar dados
      final provider = Provider.of<OdometerProvider>(context, listen: false);
      final odometerEntity = await provider.convertMapToEntity(odometer);
      
      if (odometerEntity == null) {
        // Mostrar erro se conversão falhar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Erro ao carregar dados do odômetro'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }
      
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AddOdometerPage(odometer: odometerEntity),
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
      setState(() {
        final index = _odometers.indexWhere((o) => o['id'] == odometer['id']);
        if (index >= 0) {
          _odometers[index] = {
            'id': odometer['id'],
            ...result,
          };
        }
      });
      
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