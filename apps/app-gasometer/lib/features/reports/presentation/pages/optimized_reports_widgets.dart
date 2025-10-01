import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/standard_loading_view.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../shared/widgets/enhanced_vehicle_selector.dart';
import '../providers/reports_provider.dart';
import '../widgets/enhanced_stats_card.dart';

/// ✅ PERFORMANCE FIX: Single Consumer with optimized sections
class OptimizedReportsContent extends StatelessWidget {

  const OptimizedReportsContent({
    super.key,
    required this.selectedVehicleId,
    required this.onVehicleChanged,
  });
  final String? selectedVehicleId;
  final void Function(String?) onVehicleChanged;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsProvider>(
      builder: (context, reportsProvider, child) {
        return Column(
          children: [
            EnhancedVehicleSelector(
              selectedVehicleId: selectedVehicleId,
              onVehicleChanged: (String? vehicleId) {
                onVehicleChanged(vehicleId);
                
                // Load new reports data when vehicle changes
                if (vehicleId != null) {
                  reportsProvider.loadAllReportsForVehicle(vehicleId);
                }
              },
            ),
            const SizedBox(height: 24),
            
            if (reportsProvider.isLoading)
              StandardLoadingView.initial(
                message: 'Carregando estatísticas...',
                height: 400,
              )
            else if (reportsProvider.hasError)
              _buildErrorState(
                context,
                reportsProvider.errorMessage!,
                () => reportsProvider.loadAllReportsForVehicle(selectedVehicleId!),
              )
            else ...[
              EnhancedFuelSection(provider: reportsProvider),
              const SizedBox(height: 16),
              EnhancedConsumptionSection(provider: reportsProvider),
              const SizedBox(height: 16),
              EnhancedDistanceSection(provider: reportsProvider),
            ],
          ],
        );
      },
    );
  }
  
  Widget _buildErrorState(BuildContext context, String message, VoidCallback onRetry) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar dados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced fuel section with performance indicators
class EnhancedFuelSection extends StatelessWidget {
  
  const EnhancedFuelSection({super.key, required this.provider});
  final ReportsProvider provider;
  
  @override
  Widget build(BuildContext context) {
    final currentMonthStats = provider.getCurrentMonthStats();
    final currentYearStats = provider.getCurrentYearStats();
    final monthlyComparisons = provider.getMonthlyComparisons();
    final yearlyComparisons = provider.getYearlyComparisons();
    
    return EnhancedStatsCard(
      title: 'Abastecimento',
      icon: Icons.local_gas_station,
      iconColor: GasometerDesignTokens.colorAnalyticsBlue,
      currentMonthValue: currentMonthStats['fuel_spent'] ?? 'R\$ 0,00',
      previousMonthValue: monthlyComparisons['fuel_spent'] ?? 'R\$ 0,00',
      currentYearValue: currentYearStats['fuel_spent'] ?? 'R\$ 0,00',
      previousYearValue: yearlyComparisons['fuel_spent'] ?? 'R\$ 0,00',
      currentMonthPercentageChange: _parsePercentage(monthlyComparisons['fuel_spent_growth']),
      previousMonthPercentageChange: null, // Mês anterior não tem comparação
      currentYearPercentageChange: _parsePercentage(yearlyComparisons['fuel_spent_growth']),
      previousYearPercentageChange: null, // Ano anterior não tem comparação
      isEmpty: false, // Always show data, even if zero
    );
  }
  
  double? _parsePercentage(String? percentage) {
    if (percentage == null || percentage == '0%') return null;
    final cleanPercentage = percentage.replaceAll('%', '').replaceAll('+', '');
    return double.tryParse(cleanPercentage);
  }
}

/// Enhanced consumption section with performance indicators
class EnhancedConsumptionSection extends StatelessWidget {
  
  const EnhancedConsumptionSection({super.key, required this.provider});
  final ReportsProvider provider;
  
  @override
  Widget build(BuildContext context) {
    final currentMonthStats = provider.getCurrentMonthStats();
    final currentYearStats = provider.getCurrentYearStats();
    final monthlyComparisons = provider.getMonthlyComparisons();
    final yearlyComparisons = provider.getYearlyComparisons();
    
    return EnhancedStatsCard(
      title: 'Combustível',
      icon: Icons.local_gas_station,
      iconColor: GasometerDesignTokens.colorAnalyticsGreen,
      currentMonthValue: currentMonthStats['fuel_liters'] ?? '0,0L',
      previousMonthValue: monthlyComparisons['fuel_liters'] ?? '0,0L',
      currentYearValue: currentYearStats['fuel_liters'] ?? '0,0L',
      previousYearValue: yearlyComparisons['fuel_liters'] ?? '0,0L',
      currentMonthPercentageChange: _parsePercentage(monthlyComparisons['fuel_liters_growth']),
      previousMonthPercentageChange: null, // Mês anterior não tem comparação
      currentYearPercentageChange: _parsePercentage(yearlyComparisons['fuel_liters_growth']),
      previousYearPercentageChange: null, // Ano anterior não tem comparação
      isEmpty: false, // Always show data, even if zero
    );
  }
  
  double? _parsePercentage(String? percentage) {
    if (percentage == null || percentage == '0%') return null;
    final cleanPercentage = percentage.replaceAll('%', '').replaceAll('+', '');
    return double.tryParse(cleanPercentage);
  }
}

/// Enhanced distance section with performance indicators
class EnhancedDistanceSection extends StatelessWidget {
  
  const EnhancedDistanceSection({super.key, required this.provider});
  final ReportsProvider provider;
  
  @override
  Widget build(BuildContext context) {
    final currentMonthStats = provider.getCurrentMonthStats();
    final currentYearStats = provider.getCurrentYearStats();
    final monthlyComparisons = provider.getMonthlyComparisons();
    final yearlyComparisons = provider.getYearlyComparisons();
    
    return EnhancedStatsCard(
      title: 'Distância',
      icon: Icons.speed,
      iconColor: GasometerDesignTokens.colorAnalyticsPurple,
      currentMonthValue: currentMonthStats['distance'] ?? '0 km',
      previousMonthValue: monthlyComparisons['distance'] ?? '0 km',
      currentYearValue: currentYearStats['distance'] ?? '0 km',
      previousYearValue: yearlyComparisons['distance'] ?? '0 km',
      currentMonthPercentageChange: _parsePercentage(monthlyComparisons['distance_growth']),
      previousMonthPercentageChange: null, // Mês anterior não tem comparação
      currentYearPercentageChange: _parsePercentage(yearlyComparisons['distance_growth']),
      previousYearPercentageChange: null, // Ano anterior não tem comparação
      isEmpty: false, // Always show data, even if zero
    );
  }
  
  double? _parsePercentage(String? percentage) {
    if (percentage == null || percentage == '0%') return null;
    final cleanPercentage = percentage.replaceAll('%', '').replaceAll('+', '');
    return double.tryParse(cleanPercentage);
  }
}

/// Helper widget for statistics cards
class StatCard extends StatelessWidget {

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
  });
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}