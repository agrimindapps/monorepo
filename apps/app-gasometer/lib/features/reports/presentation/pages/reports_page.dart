import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/widgets/semantic_widgets.dart';
import '../../../../core/presentation/widgets/standard_loading_view.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../models/stat_data.dart';
import '../providers/reports_provider.dart';
import 'optimized_reports_widgets.dart';

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
      // Verificar se o widget ainda está montado antes de acessar o context
      if (!mounted) return;
      
      final vehiclesProvider = Provider.of<VehiclesProvider>(context, listen: false);
      final reportsProvider = Provider.of<ReportsProvider>(context, listen: false);
      
      if (vehiclesProvider.vehicles.isNotEmpty) {
        final vehicleId = vehiclesProvider.vehicles.first.id;
        
        // Verificar novamente se ainda está montado antes do setState
        if (mounted) {
          setState(() {
            _selectedVehicleId = vehicleId;
          });
          
          // Load reports data for the selected vehicle
          reportsProvider.loadAllReportsForVehicle(vehicleId);
        }
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
                  child: OptimizedReportsContent(
                    selectedVehicleId: _selectedVehicleId,
                    onVehicleChanged: (String? vehicleId) {
                      setState(() {
                        _selectedVehicleId = vehicleId;
                      });
                    },
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
          color: GasometerDesignTokens.colorHeaderBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Semantics(
                label: 'Seção de relatórios',
                hint: 'Página principal para visualizar estatísticas e gráficos',
                child: const Icon(
                  Icons.bar_chart,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemanticText.heading(
                    'Estatísticas',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SemanticText.subtitle(
                    'Acompanhe o desempenho dos seus veículos',
                    style: const TextStyle(
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
          iconColor: GasometerDesignTokens.colorAnalyticsBlue,
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
          iconColor: GasometerDesignTokens.colorAnalyticsGreen,
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
          iconColor: GasometerDesignTokens.colorAnalyticsPurple,
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
    return SemanticCard(
      semanticLabel: 'Seção de estatísticas: $title',
      semanticHint: 'Contém dados estatísticos sobre $title do veículo selecionado',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                label: 'Ícone da categoria $title',
                hint: 'Indicador visual para estatísticas de $title',
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SemanticText.heading(
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
    );
  }

  Widget _buildStatRow(BuildContext context, StatData stat) {
    final semanticLabel = '${stat.label}: ${stat.value}. ${stat.comparison}: ${stat.comparisonValue}';
    final growthDescription = stat.percentage != null 
        ? ', ${stat.isPositive! ? 'crescimento' : 'decréscimo'} de ${stat.percentage}'
        : '';
    
    return Semantics(
      label: semanticLabel + growthDescription,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Row(
              children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SemanticText.label(
                      stat.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SemanticText(
                          stat.value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (stat.percentage != null) ...[
                          const SizedBox(width: 8),
                          SemanticStatusIndicator(
                            status: stat.isPositive! ? 'Crescimento' : 'Decréscimo',
                            description: '${stat.isPositive! ? 'Aumento' : 'Diminuição'} de ${stat.percentage}',
                            isSuccess: stat.isPositive!,
                            isError: !stat.isPositive!,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: stat.isPositive! 
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
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
                                  SemanticText(
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
                    SemanticText.label(
                      stat.comparison,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SemanticText(
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
      ),
    );
  }

  bool? _isPositiveGrowth(String? percentage) {
    if (percentage == null || percentage == '0%') return null;
    final cleanPercentage = percentage.replaceAll('%', '').replaceAll('+', '');
    final growth = double.tryParse(cleanPercentage);
    return growth != null ? growth > 0 : null;
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: 'Erro de carregamento',
              hint: 'Ícone indicando erro no carregamento das estatísticas',
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            SemanticText.heading(
              'Erro ao carregar estatísticas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            SemanticText(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SemanticButton(
              semanticLabel: 'Tentar carregar estatísticas novamente',
              semanticHint: 'Tenta recarregar os dados das estatísticas após o erro',
              type: ButtonType.elevated,
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

}

