import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../models/stat_data.dart';
import '../providers/reports_provider.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String? _selectedVehicleId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehiclesProvider = Provider.of<VehiclesProvider>(context, listen: false);
      final reportsProvider = Provider.of<ReportsProvider>(context, listen: false);
      
      if (vehiclesProvider.vehicles.isNotEmpty) {
        final vehicleId = vehiclesProvider.vehicles.first.id;
        setState(() {
          _selectedVehicleId = vehicleId;
        });
        
        // Load reports data for the selected vehicle
        reportsProvider.loadAllReportsForVehicle(vehicleId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      EnhancedVehicleSelector(
                        selectedVehicleId: _selectedVehicleId,
                        onVehicleChanged: (String? vehicleId) {
                          setState(() {
                            _selectedVehicleId = vehicleId;
                          });
                          
                          // Load new reports data when vehicle changes
                          if (vehicleId != null) {
                            final reportsProvider = Provider.of<ReportsProvider>(context, listen: false);
                            reportsProvider.loadAllReportsForVehicle(vehicleId);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildFuelSection(context),
                      const SizedBox(height: 24),
                      _buildConsumptionSection(context),
                      const SizedBox(height: 24),
                      _buildDistanceSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
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
                Icons.bar_chart,
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
                    'Estatísticas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Acompanhe o desempenho dos seus veículos',
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


  Widget _buildFuelSection(BuildContext context) {
    return Consumer<ReportsProvider>(
      builder: (context, reportsProvider, child) {
        final currentMonthStats = reportsProvider.getCurrentMonthStats();
        final currentYearStats = reportsProvider.getCurrentYearStats();
        final monthlyComparisons = reportsProvider.getMonthlyComparisons();
        final yearlyComparisons = reportsProvider.getYearlyComparisons();
        
        return _buildStatSection(
          context,
          title: 'Abastecimento',
          icon: Icons.local_gas_station,
          iconColor: const Color(0xFF4299E1),
          stats: [
            StatData(
              label: 'Este Ano',
              value: currentYearStats['fuel_spent'] ?? 'R\$ 0,00',
              comparison: 'Ano Anterior',
              comparisonValue: yearlyComparisons['fuel_spent'] ?? 'R\$ 0,00',
              percentage: yearlyComparisons['fuel_spent_growth'] != '0%' ? yearlyComparisons['fuel_spent_growth'] : null,
              isPositive: _isPositiveGrowth(yearlyComparisons['fuel_spent_growth']),
            ),
            StatData(
              label: 'Este Mês',
              value: currentMonthStats['fuel_spent'] ?? 'R\$ 0,00',
              comparison: 'Mês Anterior',
              comparisonValue: monthlyComparisons['fuel_spent'] ?? 'R\$ 0,00',
              percentage: monthlyComparisons['fuel_spent_growth'] != '0%' ? monthlyComparisons['fuel_spent_growth'] : null,
              isPositive: _isPositiveGrowth(monthlyComparisons['fuel_spent_growth']),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConsumptionSection(BuildContext context) {
    return Consumer<ReportsProvider>(
      builder: (context, reportsProvider, child) {
        final currentMonthStats = reportsProvider.getCurrentMonthStats();
        final currentYearStats = reportsProvider.getCurrentYearStats();
        final monthlyComparisons = reportsProvider.getMonthlyComparisons();
        final yearlyComparisons = reportsProvider.getYearlyComparisons();
        
        return _buildStatSection(
          context,
          title: 'Combustível',
          icon: Icons.local_gas_station,
          iconColor: const Color(0xFF48BB78),
          stats: [
            StatData(
              label: 'Este Ano',
              value: currentYearStats['fuel_liters'] ?? '0,0L',
              comparison: 'Ano Anterior',
              comparisonValue: yearlyComparisons['fuel_liters'] ?? '0,0L',
            ),
            StatData(
              label: 'Este Mês',
              value: currentMonthStats['fuel_liters'] ?? '0,0L',
              comparison: 'Mês Anterior',
              comparisonValue: monthlyComparisons['fuel_liters'] ?? '0,0L',
            ),
          ],
        );
      },
    );
  }

  Widget _buildDistanceSection(BuildContext context) {
    return Consumer<ReportsProvider>(
      builder: (context, reportsProvider, child) {
        final currentMonthStats = reportsProvider.getCurrentMonthStats();
        final currentYearStats = reportsProvider.getCurrentYearStats();
        final monthlyComparisons = reportsProvider.getMonthlyComparisons();
        final yearlyComparisons = reportsProvider.getYearlyComparisons();
        
        return _buildStatSection(
          context,
          title: 'Distância',
          icon: Icons.speed,
          iconColor: const Color(0xFF9F7AEA),
          stats: [
            StatData(
              label: 'Este Ano',
              value: currentYearStats['distance'] ?? '0 km',
              comparison: 'Ano Anterior',
              comparisonValue: yearlyComparisons['distance'] ?? '0 km',
              percentage: yearlyComparisons['distance_growth'] != '0%' ? yearlyComparisons['distance_growth'] : null,
              isPositive: _isPositiveGrowth(yearlyComparisons['distance_growth']),
            ),
            StatData(
              label: 'Este Mês',
              value: currentMonthStats['distance'] ?? '0 km',
              comparison: 'Mês Anterior',
              comparisonValue: monthlyComparisons['distance'] ?? '0 km',
              percentage: monthlyComparisons['distance_growth'] != '0%' ? monthlyComparisons['distance_growth'] : null,
              isPositive: _isPositiveGrowth(monthlyComparisons['distance_growth']),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<StatData> stats,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...stats.map((stat) => _buildStatRow(context, stat)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, StatData stat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          stat.value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (stat.percentage != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: stat.isPositive! 
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  stat.isPositive! 
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                  size: 12,
                                  color: stat.isPositive! 
                                    ? Colors.green
                                    : Colors.red,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  stat.percentage!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: stat.isPositive! 
                                      ? Colors.green
                                      : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.comparison,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.comparisonValue,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool? _isPositiveGrowth(String? percentage) {
    if (percentage == null || percentage == '0%') return null;
    final cleanPercentage = percentage.replaceAll('%', '').replaceAll('+', '');
    final growth = double.tryParse(cleanPercentage);
    return growth != null ? growth > 0 : null;
  }

}

